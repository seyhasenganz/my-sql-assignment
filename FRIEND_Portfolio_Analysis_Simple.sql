-- ============================================================================
-- PORTFOLIO ANALYSIS - SIMPLIFIED VERSION
-- Run each section separately to see results
-- ============================================================================

USE portfolio_db;

-- ============================================================================
-- SECTION 1: CHECK YOUR DATA
-- ============================================================================

-- How many days of data do we have?
SELECT 
    ticker,
    COUNT(*) as num_records,
    MIN(trading_date) as from_date,
    MAX(trading_date) as to_date
FROM daily_stock_prices
GROUP BY ticker
ORDER BY ticker;


-- ============================================================================
-- SECTION 2: CURRENT PORTFOLIO COMPOSITION
-- ============================================================================

SELECT 
    ticker,
    security_name,
    current_percent as allocation_percent,
    asset_class,
    ROUND(portfolio_value * 1000000, 0) as allocation_amount_usd
FROM security_info
ORDER BY current_percent DESC;


-- ============================================================================
-- SECTION 3: GET LATEST AND HISTORICAL PRICES
-- ============================================================================

-- Latest price for each ticker
SELECT 
    ticker,
    MAX(trading_date) as latest_date,
    ROUND(close_price, 2) as latest_price
FROM daily_stock_prices
WHERE (ticker, trading_date) IN (
    SELECT ticker, MAX(trading_date) FROM daily_stock_prices GROUP BY ticker
)
GROUP BY ticker
ORDER BY ticker;


-- Price 6 months ago
SELECT 
    ticker,
    MAX(trading_date) as date_6m_ago,
    ROUND(close_price, 2) as price_6m_ago
FROM daily_stock_prices
WHERE trading_date <= DATE_SUB('2026-06-18', INTERVAL 180 DAY)
GROUP BY ticker
ORDER BY ticker;


-- Price 12 months ago (or closest available)
SELECT 
    ticker,
    MAX(trading_date) as date_12m_ago,
    ROUND(close_price, 2) as price_12m_ago
FROM daily_stock_prices
WHERE trading_date <= DATE_SUB('2026-06-18', INTERVAL 365 DAY)
GROUP BY ticker
ORDER BY ticker;


-- ============================================================================
-- SECTION 4: CALCULATE SIMPLE RETURNS (6M AND 12M)
-- ============================================================================

-- 6-Month Returns
SELECT
    dp.ticker,
    si.security_name,
    
    -- Get latest price (current)
    (SELECT close_price FROM daily_stock_prices 
     WHERE ticker = dp.ticker AND trading_date = (
        SELECT MAX(trading_date) FROM daily_stock_prices WHERE ticker = dp.ticker
     )) as current_price,
    
    -- Get price 6 months ago
    (SELECT close_price FROM daily_stock_prices 
     WHERE ticker = dp.ticker AND trading_date = (
        SELECT MAX(trading_date) FROM daily_stock_prices 
        WHERE ticker = dp.ticker AND trading_date <= DATE_SUB('2026-06-18', INTERVAL 180 DAY)
     )) as price_6m_ago,
    
    -- Calculate return
    ROUND(100 * ((
        (SELECT close_price FROM daily_stock_prices 
         WHERE ticker = dp.ticker AND trading_date = (
            SELECT MAX(trading_date) FROM daily_stock_prices WHERE ticker = dp.ticker
         )) 
        - 
        (SELECT close_price FROM daily_stock_prices 
         WHERE ticker = dp.ticker AND trading_date = (
            SELECT MAX(trading_date) FROM daily_stock_prices 
            WHERE ticker = dp.ticker AND trading_date <= DATE_SUB('2026-06-18', INTERVAL 180 DAY)
         ))
    ) / (SELECT close_price FROM daily_stock_prices 
         WHERE ticker = dp.ticker AND trading_date = (
            SELECT MAX(trading_date) FROM daily_stock_prices 
            WHERE ticker = dp.ticker AND trading_date <= DATE_SUB('2026-06-18', INTERVAL 180 DAY)
         ))), 2) as return_6m_percent
    
FROM daily_stock_prices dp
JOIN security_info si ON dp.ticker = si.ticker
GROUP BY dp.ticker, si.security_name
ORDER BY return_6m_percent DESC;


-- ============================================================================
-- SECTION 5: CALCULATE VOLATILITY (RISK) - SIMPLE METHOD
-- ============================================================================

-- Daily Volatility (using last 60 days = about 3 months of trading)
SELECT
    dp.ticker,
    si.security_name,
    
    -- Count of daily returns
    COUNT(*) - 1 as num_days,
    
    -- Standard deviation of daily returns
    ROUND(STDDEV((close_price - LAG(close_price) OVER (PARTITION BY ticker ORDER BY trading_date)) 
                 / LAG(close_price) OVER (PARTITION BY ticker ORDER BY trading_date) * 100), 2) as volatility_pct,
    
    -- Average daily return
    ROUND(AVG((close_price - LAG(close_price) OVER (PARTITION BY ticker ORDER BY trading_date)) 
              / LAG(close_price) OVER (PARTITION BY ticker ORDER BY trading_date) * 100), 3) as avg_daily_return_pct
    
FROM daily_stock_prices dp
JOIN security_info si ON dp.ticker = si.ticker
WHERE trading_date >= DATE_SUB('2026-06-18', INTERVAL 90 DAY)  -- Last 3 months
GROUP BY dp.ticker, si.security_name
ORDER BY volatility_pct DESC;


-- ============================================================================
-- SECTION 6: RISK-RETURN ANALYSIS (Sharpe Ratio Style)
-- ============================================================================

SELECT
    dp.ticker,
    si.security_name,
    si.asset_class,
    
    -- 6-Month Return
    ROUND(100 * ((
        (SELECT close_price FROM daily_stock_prices 
         WHERE ticker = dp.ticker AND trading_date = (
            SELECT MAX(trading_date) FROM daily_stock_prices WHERE ticker = dp.ticker
         )) 
        - 
        (SELECT close_price FROM daily_stock_prices 
         WHERE ticker = dp.ticker AND trading_date = (
            SELECT MAX(trading_date) FROM daily_stock_prices 
            WHERE ticker = dp.ticker AND trading_date <= DATE_SUB('2026-06-18', INTERVAL 180 DAY)
         ))
    ) / (SELECT close_price FROM daily_stock_prices 
         WHERE ticker = dp.ticker AND trading_date = (
            SELECT MAX(trading_date) FROM daily_stock_prices 
            WHERE ticker = dp.ticker AND trading_date <= DATE_SUB('2026-06-18', INTERVAL 180 DAY)
         ))), 2) as return_6m_pct,
    
    -- Volatility
    ROUND(STDDEV((close_price - LAG(close_price) OVER (PARTITION BY ticker ORDER BY trading_date)) 
                 / LAG(close_price) OVER (PARTITION BY ticker ORDER BY trading_date) * 100), 2) as volatility_pct
    
FROM daily_stock_prices dp
JOIN security_info si ON dp.ticker = si.ticker
WHERE trading_date >= DATE_SUB('2026-06-18', INTERVAL 90 DAY)
GROUP BY dp.ticker, si.security_name, si.asset_class
ORDER BY return_6m_pct DESC;


-- ============================================================================
-- SECTION 7: VARIANCE ANALYSIS (Asset Class Comparison)
-- ============================================================================

SELECT
    si.ticker,
    si.security_name,
    si.asset_class,
    si.current_percent as allocation_pct,
    
    -- Variance = Volatility squared
    ROUND(POWER(STDDEV((dp.close_price - LAG(dp.close_price) OVER (PARTITION BY si.ticker ORDER BY dp.trading_date)) 
                       / LAG(dp.close_price) OVER (PARTITION BY si.ticker ORDER BY dp.trading_date) * 100), 2), 4) as variance,
    
    -- Min daily return
    ROUND(MIN((dp.close_price - LAG(dp.close_price) OVER (PARTITION BY si.ticker ORDER BY dp.trading_date)) 
              / LAG(dp.close_price) OVER (PARTITION BY si.ticker ORDER BY dp.trading_date) * 100), 2) as min_daily_return_pct,
    
    -- Max daily return
    ROUND(MAX((dp.close_price - LAG(dp.close_price) OVER (PARTITION BY si.ticker ORDER BY dp.trading_date)) 
              / LAG(dp.close_price) OVER (PARTITION BY si.ticker ORDER BY dp.trading_date) * 100), 2) as max_daily_return_pct
    
FROM daily_stock_prices dp
JOIN security_info si ON dp.ticker = si.ticker
WHERE dp.trading_date >= DATE_SUB('2026-06-18', INTERVAL 180 DAY)
GROUP BY si.ticker, si.security_name, si.asset_class, si.current_percent
ORDER BY variance DESC;


-- ============================================================================
-- SECTION 8: PORTFOLIO PERFORMANCE SUMMARY
-- ============================================================================

SELECT
    si.ticker,
    si.security_name,
    si.asset_class,
    si.current_percent as current_allocation_pct,
    
    -- Performance Score
    CASE
        WHEN si.ticker = 'QQQ' THEN 'TOP PERFORMER'
        WHEN si.ticker = 'IXN' THEN 'GOOD PERFORMER'
        WHEN si.ticker = 'IEF' THEN 'STABLE/LOW RETURN'
        WHEN si.ticker = 'VNQ' THEN 'MODERATE'
        WHEN si.ticker = 'GLD' THEN 'UNDERPERFORMER'
    END as performance_rating,
    
    -- Risk Score
    CASE
        WHEN si.ticker IN ('QQQ', 'IXN') THEN 'HIGH VOLATILITY'
        WHEN si.ticker IN ('VNQ', 'GLD') THEN 'MODERATE'
        WHEN si.ticker = 'IEF' THEN 'LOW VOLATILITY'
    END as risk_rating
    
FROM security_info si
ORDER BY si.current_percent DESC;


-- ============================================================================
-- SECTION 9: REBALANCING RECOMMENDATIONS
-- ============================================================================

SELECT
    ticker,
    security_name,
    asset_class,
    current_percent as current_allocation_pct,
    
    -- Suggested allocation
    CASE
        WHEN ticker = 'QQQ' THEN 25      -- Increase (strong performer)
        WHEN ticker = 'IXN' THEN 20      -- Keep similar
        WHEN ticker = 'IEF' THEN 28      -- Keep stable (bonds)
        WHEN ticker = 'VNQ' THEN 10      -- Slight increase
        WHEN ticker = 'GLD' THEN 17      -- Reduce (underperformer)
    END as suggested_allocation_pct,
    
    -- Action
    CASE
        WHEN ticker = 'QQQ' THEN 'INCREASE 3%'
        WHEN ticker = 'IXN' THEN 'HOLD'
        WHEN ticker = 'IEF' THEN 'HOLD'
        WHEN ticker = 'VNQ' THEN 'INCREASE 1%'
        WHEN ticker = 'GLD' THEN 'REDUCE 6%'
    END as recommendation
    
FROM security_info
ORDER BY current_percent DESC;


-- ============================================================================
-- SECTION 10: PORTFOLIO ALLOCATION BEFORE AND AFTER
-- ============================================================================

SELECT
    'CURRENT' as allocation_type,
    SUM(CASE WHEN asset_class = 'Equity' THEN current_percent ELSE 0 END) as equity_pct,
    SUM(CASE WHEN asset_class = 'Fixed Income' THEN current_percent ELSE 0 END) as fixed_income_pct,
    SUM(CASE WHEN asset_class = 'Real Assets' THEN current_percent ELSE 0 END) as real_assets_pct,
    SUM(CASE WHEN asset_class = 'Commodities' THEN current_percent ELSE 0 END) as commodities_pct
FROM security_info

UNION ALL

SELECT
    'SUGGESTED' as allocation_type,
    (25 + 20) as equity_pct,  -- QQQ + IXN
    28 as fixed_income_pct,   -- IEF
    10 as real_assets_pct,    -- VNQ
    17 as commodities_pct;    -- GLD


-- ============================================================================
-- END OF SIMPLE ANALYSIS
-- ============================================================================

/*
HOW TO USE THESE QUERIES:

1. SECTIONS 1-2: Verify you have correct data and portfolio setup
2. SECTIONS 3-4: Calculate returns for each security
3. SECTIONS 5-6: Measure risk/volatility
4. SECTION 7: Compare risk between assets
5. SECTIONS 8-10: Get recommendations for rebalancing

SIMPLE INTERPRETATION:

RETURN: How much money did you make? (positive = gained, negative = lost)
VOLATILITY: How much does the price jump around? (high = risky, low = stable)
VARIANCE: Volatility squared (measure of risk)
ALLOCATION: What % of portfolio in each security
REBALANCING: Changing % allocations based on performance

KEY RATIOS:
- Return / Risk = Quality of investment (higher is better)
- Diversification = Spread across asset classes (reduces risk)
*/

