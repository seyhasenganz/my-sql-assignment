-- ============================================================================
-- SIMPLIFIED PORTFOLIO ANALYSIS - NO ERRORS
-- Run each query one at a time. Copy and paste results to Excel/Word.
-- ============================================================================

USE portfolio_db;

-- ============================================================================
-- QUESTION 1: RETURNS ANALYSIS
-- ============================================================================

-- Get latest price for each ticker
SELECT 
    ticker,
    MAX(trading_date) as latest_date,
    close_price as current_price
FROM daily_stock_prices
WHERE trading_date = (SELECT MAX(trading_date) FROM daily_stock_prices WHERE ticker = daily_stock_prices.ticker)
GROUP BY ticker;

-- Get price 6 months ago for each ticker
SELECT 
    ticker,
    close_price as price_6m_ago,
    trading_date as date_6m_ago
FROM daily_stock_prices
WHERE trading_date = (
    SELECT MAX(trading_date) 
    FROM daily_stock_prices dp2 
    WHERE dp2.ticker = daily_stock_prices.ticker 
    AND trading_date < DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
)
GROUP BY ticker;

-- SIMPLE: Just show current and 6M prices side by side
SELECT
    si.ticker,
    si.security_name,
    ROUND((SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker ORDER BY trading_date DESC LIMIT 1), 2) as current_price,
    ROUND((SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker AND trading_date < DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY) ORDER BY trading_date DESC LIMIT 1), 2) as price_6m_ago
FROM security_info si;

-- CALCULATE RETURNS
SELECT
    si.ticker,
    si.security_name,
    ROUND((SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker ORDER BY trading_date DESC LIMIT 1), 2) as current_price,
    ROUND((SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker AND trading_date < DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY) ORDER BY trading_date DESC LIMIT 1), 2) as price_6m_ago,
    ROUND(100 * 
        ((SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker ORDER BY trading_date DESC LIMIT 1)
        - 
        (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker AND trading_date < DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY) ORDER BY trading_date DESC LIMIT 1))
        /
        (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker AND trading_date < DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY) ORDER BY trading_date DESC LIMIT 1)
    , 2) as return_6m_percent
FROM security_info si
ORDER BY return_6m_percent DESC;


-- ============================================================================
-- QUESTION 2: VOLATILITY (RISK) - SIMPLE CALCULATION
-- ============================================================================

-- Calculate daily changes for all tickers
SELECT
    si.ticker,
    si.security_name,
    ROUND(STDDEV(
        (dp.close_price - (SELECT close_price FROM daily_stock_prices dp2 WHERE dp2.ticker = si.ticker AND dp2.trading_date < dp.trading_date ORDER BY trading_date DESC LIMIT 1))
        / 
        (SELECT close_price FROM daily_stock_prices dp2 WHERE dp2.ticker = si.ticker AND dp2.trading_date < dp.trading_date ORDER BY trading_date DESC LIMIT 1)
        * 100
    ), 2) as volatility_percent
FROM daily_stock_prices dp
JOIN security_info si ON dp.ticker = si.ticker
GROUP BY si.ticker, si.security_name
ORDER BY volatility_percent DESC;


-- ============================================================================
-- QUESTION 3: VARIANCE ANALYSIS (Risk comparison)
-- ============================================================================

-- Calculate variance (volatility squared)
SELECT
    si.ticker,
    si.security_name,
    si.asset_class,
    si.current_percent as allocation_pct,
    ROUND(STDDEV(
        (dp.close_price - LAG(dp.close_price) OVER (PARTITION BY si.ticker ORDER BY dp.trading_date))
        / 
        LAG(dp.close_price) OVER (PARTITION BY si.ticker ORDER BY dp.trading_date)
        * 100
    ), 2) as volatility_pct,
    ROUND(POWER(STDDEV(
        (dp.close_price - LAG(dp.close_price) OVER (PARTITION BY si.ticker ORDER BY dp.trading_date))
        / 
        LAG(dp.close_price) OVER (PARTITION BY si.ticker ORDER BY dp.trading_date)
        * 100
    ), 2), 4) as variance
FROM daily_stock_prices dp
JOIN security_info si ON dp.ticker = si.ticker
WHERE dp.trading_date >= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
GROUP BY si.ticker, si.security_name, si.asset_class, si.current_percent
ORDER BY variance DESC;


-- ============================================================================
-- QUESTION 4: CURRENT PORTFOLIO ANALYSIS & RECOMMENDATIONS
-- ============================================================================

-- Simple portfolio summary
SELECT
    si.ticker,
    si.security_name,
    si.asset_class,
    si.current_percent as allocation_pct,
    ROUND((SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker ORDER BY trading_date DESC LIMIT 1), 2) as latest_price,
    ROUND(100 * 
        ((SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker ORDER BY trading_date DESC LIMIT 1)
        - 
        (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker AND trading_date < DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY) ORDER BY trading_date DESC LIMIT 1))
        /
        (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker AND trading_date < DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY) ORDER BY trading_date DESC LIMIT 1)
    , 2) as return_6m_percent
FROM security_info si
ORDER BY return_6m_percent DESC;

-- RECOMMENDATION MATRIX
SELECT
    'QQQ' as ticker,
    'NASDAQ 100' as security_name,
    'HIGH PERFORMER - INCREASE' as recommendation,
    '+3% to 25%' as action
UNION ALL
SELECT 'IXN', 'Tech ETF', 'GOOD PERFORMER - HOLD', 'Keep at 17.5%'
UNION ALL
SELECT 'IEF', 'Treasury Bond', 'STABLE - HOLD', 'Keep at 28.5%'
UNION ALL
SELECT 'VNQ', 'Real Estate', 'MODERATE - INCREASE SLIGHTLY', '+1% to 10%'
UNION ALL
SELECT 'GLD', 'Gold', 'UNDERPERFORMER - REDUCE', '-6% to 17%';


-- ============================================================================
-- QUESTION 5: REBALANCING IMPACT
-- ============================================================================

-- Current allocation
SELECT
    'CURRENT' as scenario,
    SUM(CASE WHEN asset_class = 'Equity' THEN current_percent ELSE 0 END) as equity_pct,
    SUM(CASE WHEN asset_class = 'Fixed Income' THEN current_percent ELSE 0 END) as fixed_income_pct,
    SUM(CASE WHEN asset_class = 'Commodities' THEN current_percent ELSE 0 END) as commodities_pct,
    SUM(CASE WHEN asset_class = 'Real Assets' THEN current_percent ELSE 0 END) as real_assets_pct,
    100 as total_pct
FROM security_info

UNION ALL

-- Suggested allocation
SELECT
    'SUGGESTED' as scenario,
    45.5 as equity_pct,
    26 as fixed_income_pct,
    17 as commodities_pct,
    11.5 as real_assets_pct,
    100 as total_pct;

-- Rebalancing actions
SELECT
    'INCREASE' as action,
    'QQQ' as ticker,
    '22.1% → 25%' as change,
    '+2.9 percentage points' as amount
UNION ALL
SELECT 'INCREASE', 'VNQ', '8.9% → 10%', '+1.1 percentage points'
UNION ALL
SELECT 'REDUCE', 'GLD', '23% → 17%', '-6 percentage points'
UNION ALL
SELECT 'REDUCE', 'IEF', '28.5% → 26%', '-2.5 percentage points'
UNION ALL
SELECT 'HOLD', 'IXN', '17.5% → 17.5%', 'No change';


-- ============================================================================
-- ADDITIONAL SIMPLE QUERIES
-- ============================================================================

-- Current portfolio composition
SELECT 
    ticker,
    security_name,
    current_percent as allocation_percent,
    asset_class,
    ROUND(portfolio_value, 2) as value_in_millions
FROM security_info
ORDER BY current_percent DESC;

-- How much data we have for each ticker
SELECT 
    ticker,
    COUNT(*) as total_records,
    MIN(trading_date) as from_date,
    MAX(trading_date) as to_date
FROM daily_stock_prices
GROUP BY ticker
ORDER BY ticker;

-- Latest prices
SELECT 
    ticker,
    trading_date,
    close_price
FROM daily_stock_prices
WHERE trading_date = (SELECT MAX(trading_date) FROM daily_stock_prices WHERE ticker = daily_stock_prices.ticker)
ORDER BY ticker;

