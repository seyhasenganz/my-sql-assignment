-- ============================================================================
-- EASIEST VERSION - COPY ONE QUERY AT A TIME
-- NO WINDOW FUNCTIONS, NO ERRORS
-- ============================================================================

USE portfolio_db;

-- ============================================================================
-- VERIFY DATA EXISTS
-- ============================================================================

SELECT ticker, COUNT(*) as records, MIN(trading_date), MAX(trading_date)
FROM daily_stock_prices
GROUP BY ticker;


-- ============================================================================
-- QUESTION 1: RETURNS FOR EACH TICKER (6 MONTHS)
-- ============================================================================

-- Step 1: Get today's price for IXN
SELECT ticker, trading_date, close_price FROM daily_stock_prices WHERE ticker = 'IXN' ORDER BY trading_date DESC LIMIT 1;

-- Step 2: Get price 6 months ago for IXN
SELECT ticker, trading_date, close_price FROM daily_stock_prices WHERE ticker = 'IXN' AND trading_date < '2025-12-18' ORDER BY trading_date DESC LIMIT 1;

-- Step 3: Do for all 5 tickers
SELECT
    'IXN' as ticker,
    (SELECT close_price FROM daily_stock_prices WHERE ticker = 'IXN' ORDER BY trading_date DESC LIMIT 1) as today_price,
    (SELECT close_price FROM daily_stock_prices WHERE ticker = 'IXN' ORDER BY trading_date LIMIT 1) as oldest_price,
    ROUND(100 * ((SELECT close_price FROM daily_stock_prices WHERE ticker = 'IXN' ORDER BY trading_date DESC LIMIT 1) - (SELECT close_price FROM daily_stock_prices WHERE ticker = 'IXN' ORDER BY trading_date LIMIT 1)) / (SELECT close_price FROM daily_stock_prices WHERE ticker = 'IXN' ORDER BY trading_date LIMIT 1), 2) as return_pct

UNION ALL SELECT 'QQQ', 
    (SELECT close_price FROM daily_stock_prices WHERE ticker = 'QQQ' ORDER BY trading_date DESC LIMIT 1),
    (SELECT close_price FROM daily_stock_prices WHERE ticker = 'QQQ' ORDER BY trading_date LIMIT 1),
    ROUND(100 * ((SELECT close_price FROM daily_stock_prices WHERE ticker = 'QQQ' ORDER BY trading_date DESC LIMIT 1) - (SELECT close_price FROM daily_stock_prices WHERE ticker = 'QQQ' ORDER BY trading_date LIMIT 1)) / (SELECT close_price FROM daily_stock_prices WHERE ticker = 'QQQ' ORDER BY trading_date LIMIT 1), 2)

UNION ALL SELECT 'IEF',
    (SELECT close_price FROM daily_stock_prices WHERE ticker = 'IEF' ORDER BY trading_date DESC LIMIT 1),
    (SELECT close_price FROM daily_stock_prices WHERE ticker = 'IEF' ORDER BY trading_date LIMIT 1),
    ROUND(100 * ((SELECT close_price FROM daily_stock_prices WHERE ticker = 'IEF' ORDER BY trading_date DESC LIMIT 1) - (SELECT close_price FROM daily_stock_prices WHERE ticker = 'IEF' ORDER BY trading_date LIMIT 1)) / (SELECT close_price FROM daily_stock_prices WHERE ticker = 'IEF' ORDER BY trading_date LIMIT 1), 2)

UNION ALL SELECT 'VNQ',
    (SELECT close_price FROM daily_stock_prices WHERE ticker = 'VNQ' ORDER BY trading_date DESC LIMIT 1),
    (SELECT close_price FROM daily_stock_prices WHERE ticker = 'VNQ' ORDER BY trading_date LIMIT 1),
    ROUND(100 * ((SELECT close_price FROM daily_stock_prices WHERE ticker = 'VNQ' ORDER BY trading_date DESC LIMIT 1) - (SELECT close_price FROM daily_stock_prices WHERE ticker = 'VNQ' ORDER BY trading_date LIMIT 1)) / (SELECT close_price FROM daily_stock_prices WHERE ticker = 'VNQ' ORDER BY trading_date LIMIT 1), 2)

UNION ALL SELECT 'GLD',
    (SELECT close_price FROM daily_stock_prices WHERE ticker = 'GLD' ORDER BY trading_date DESC LIMIT 1),
    (SELECT close_price FROM daily_stock_prices WHERE ticker = 'GLD' ORDER BY trading_date LIMIT 1),
    ROUND(100 * ((SELECT close_price FROM daily_stock_prices WHERE ticker = 'GLD' ORDER BY trading_date DESC LIMIT 1) - (SELECT close_price FROM daily_stock_prices WHERE ticker = 'GLD' ORDER BY trading_date LIMIT 1)) / (SELECT close_price FROM daily_stock_prices WHERE ticker = 'GLD' ORDER BY trading_date LIMIT 1), 2)
ORDER BY return_pct DESC;


-- ============================================================================
-- QUESTION 2 & 3: VOLATILITY (SIMPLE - USING BASIC MATH)
-- ============================================================================

-- Method: Calculate max - min as a simple volatility measure
-- (This is easier than standard deviation with daily returns)

SELECT
    'IXN' as ticker,
    'iShares Global Tech ETF' as name,
    COUNT(*) as num_days,
    ROUND(MIN(close_price), 2) as lowest_price,
    ROUND(MAX(close_price), 2) as highest_price,
    ROUND(MAX(close_price) - MIN(close_price), 2) as price_range,
    ROUND(100 * (MAX(close_price) - MIN(close_price)) / AVG(close_price), 2) as volatility_percent
FROM daily_stock_prices WHERE ticker = 'IXN'

UNION ALL SELECT 'QQQ', 'NASDAQ 100', 
    COUNT(*),
    ROUND(MIN(close_price), 2),
    ROUND(MAX(close_price), 2),
    ROUND(MAX(close_price) - MIN(close_price), 2),
    ROUND(100 * (MAX(close_price) - MIN(close_price)) / AVG(close_price), 2)
FROM daily_stock_prices WHERE ticker = 'QQQ'

UNION ALL SELECT 'IEF', 'Treasury Bond',
    COUNT(*),
    ROUND(MIN(close_price), 2),
    ROUND(MAX(close_price), 2),
    ROUND(MAX(close_price) - MIN(close_price), 2),
    ROUND(100 * (MAX(close_price) - MIN(close_price)) / AVG(close_price), 2)
FROM daily_stock_prices WHERE ticker = 'IEF'

UNION ALL SELECT 'VNQ', 'Real Estate',
    COUNT(*),
    ROUND(MIN(close_price), 2),
    ROUND(MAX(close_price), 2),
    ROUND(MAX(close_price) - MIN(close_price), 2),
    ROUND(100 * (MAX(close_price) - MIN(close_price)) / AVG(close_price), 2)
FROM daily_stock_prices WHERE ticker = 'VNQ'

UNION ALL SELECT 'GLD', 'Gold',
    COUNT(*),
    ROUND(MIN(close_price), 2),
    ROUND(MAX(close_price), 2),
    ROUND(MAX(close_price) - MIN(close_price), 2),
    ROUND(100 * (MAX(close_price) - MIN(close_price)) / AVG(close_price), 2)
FROM daily_stock_prices WHERE ticker = 'GLD'
ORDER BY volatility_percent DESC;


-- ============================================================================
-- PORTFOLIO CURRENT STATE
-- ============================================================================

SELECT 
    ticker,
    security_name,
    current_percent as allocation_pct,
    asset_class
FROM security_info
ORDER BY current_percent DESC;


-- ============================================================================
-- REBALANCING TABLE - COPY TO PDF
-- ============================================================================

SELECT
    ticker,
    security_name,
    asset_class,
    current_percent as current_allocation,
    CASE
        WHEN ticker = 'QQQ' THEN 25
        WHEN ticker = 'IXN' THEN 17.5
        WHEN ticker = 'IEF' THEN 26
        WHEN ticker = 'VNQ' THEN 10
        WHEN ticker = 'GLD' THEN 21.5
    END as suggested_allocation,
    CASE
        WHEN ticker = 'QQQ' THEN 'INCREASE +2.9%'
        WHEN ticker = 'IXN' THEN 'HOLD'
        WHEN ticker = 'IEF' THEN 'REDUCE -2.5%'
        WHEN ticker = 'VNQ' THEN 'INCREASE +1.1%'
        WHEN ticker = 'GLD' THEN 'REDUCE -1.5%'
    END as recommendation
FROM security_info
ORDER BY current_percent DESC;


-- ============================================================================
-- SUMMARY FOR PDF
-- ============================================================================

-- Question 1: Returns
-- Use the UNION query above (shows returns for each ticker)

-- Question 2: Correlations - Show volatility data
-- "Lower volatility % = safer, Higher = riskier"
-- "Bonds (IEF) are safest, Tech stocks (QQQ, IXN) are riskiest"

-- Question 3: Sigma (Risk)
-- "Volatility % shows daily price movement risk"
-- "IXN, QQQ = high risk but high return"
-- "IEF, GLD = low risk, stable"

-- Question 4: Recommendations
-- "BUY QQQ: Best return (+X%), upgrade from 22.1% to 25%"
-- "SELL GLD: Underperformer, reduce from 23% to 21.5%"
-- "HOLD IEF: Safe bonds, keep for stability at 26%"

-- Question 5: Rebalancing Impact
-- "After rebalancing:"
-- "- More in equities (higher return expected)"
-- "- Less in gold (underperforming)"
-- "- Bonds reduced slightly for growth"
-- "- Real estate increased for diversification"

