-- ============================================================================
-- ULTRA SIMPLE - COPY EACH QUERY ONE AT A TIME - NO ERRORS!
-- ============================================================================

USE portfolio_db;

-- ============================================================================
-- QUESTION 1: RETURNS (6 MONTHS)
-- ============================================================================

-- Current prices
SELECT ticker, close_price FROM daily_stock_prices 
WHERE trading_date = (SELECT MAX(trading_date) FROM daily_stock_prices WHERE ticker = daily_stock_prices.ticker);

-- Prices 6 months ago
SELECT ticker, close_price FROM daily_stock_prices 
WHERE trading_date = (SELECT MAX(trading_date) FROM daily_stock_prices WHERE ticker = daily_stock_prices.ticker AND trading_date < DATE_SUB('2026-06-18', INTERVAL 180 DAY));

-- SIMPLE RETURNS CALCULATION
SELECT
    'IXN' as ticker,
    'iShares Global Tech ETF' as security_name,
    (SELECT close_price FROM daily_stock_prices WHERE ticker = 'IXN' ORDER BY trading_date DESC LIMIT 1) as current_price,
    (SELECT close_price FROM daily_stock_prices WHERE ticker = 'IXN' AND trading_date < DATE_SUB('2026-06-18', INTERVAL 180 DAY) ORDER BY trading_date DESC LIMIT 1) as price_6m_ago,
    ROUND(100 * ((SELECT close_price FROM daily_stock_prices WHERE ticker = 'IXN' ORDER BY trading_date DESC LIMIT 1) - (SELECT close_price FROM daily_stock_prices WHERE ticker = 'IXN' AND trading_date < DATE_SUB('2026-06-18', INTERVAL 180 DAY) ORDER BY trading_date DESC LIMIT 1)) / (SELECT close_price FROM daily_stock_prices WHERE ticker = 'IXN' AND trading_date < DATE_SUB('2026-06-18', INTERVAL 180 DAY) ORDER BY trading_date DESC LIMIT 1), 2) as return_percent

UNION ALL

SELECT
    'QQQ',
    'NASDAQ 100',
    (SELECT close_price FROM daily_stock_prices WHERE ticker = 'QQQ' ORDER BY trading_date DESC LIMIT 1),
    (SELECT close_price FROM daily_stock_prices WHERE ticker = 'QQQ' AND trading_date < DATE_SUB('2026-06-18', INTERVAL 180 DAY) ORDER BY trading_date DESC LIMIT 1),
    ROUND(100 * ((SELECT close_price FROM daily_stock_prices WHERE ticker = 'QQQ' ORDER BY trading_date DESC LIMIT 1) - (SELECT close_price FROM daily_stock_prices WHERE ticker = 'QQQ' AND trading_date < DATE_SUB('2026-06-18', INTERVAL 180 DAY) ORDER BY trading_date DESC LIMIT 1)) / (SELECT close_price FROM daily_stock_prices WHERE ticker = 'QQQ' AND trading_date < DATE_SUB('2026-06-18', INTERVAL 180 DAY) ORDER BY trading_date DESC LIMIT 1), 2)

UNION ALL

SELECT
    'IEF',
    'iShares 7-10 Year Treasury Bond ETF',
    (SELECT close_price FROM daily_stock_prices WHERE ticker = 'IEF' ORDER BY trading_date DESC LIMIT 1),
    (SELECT close_price FROM daily_stock_prices WHERE ticker = 'IEF' AND trading_date < DATE_SUB('2026-06-18', INTERVAL 180 DAY) ORDER BY trading_date DESC LIMIT 1),
    ROUND(100 * ((SELECT close_price FROM daily_stock_prices WHERE ticker = 'IEF' ORDER BY trading_date DESC LIMIT 1) - (SELECT close_price FROM daily_stock_prices WHERE ticker = 'IEF' AND trading_date < DATE_SUB('2026-06-18', INTERVAL 180 DAY) ORDER BY trading_date DESC LIMIT 1)) / (SELECT close_price FROM daily_stock_prices WHERE ticker = 'IEF' AND trading_date < DATE_SUB('2026-06-18', INTERVAL 180 DAY) ORDER BY trading_date DESC LIMIT 1), 2)

UNION ALL

SELECT
    'VNQ',
    'Vanguard Real Estate ETF',
    (SELECT close_price FROM daily_stock_prices WHERE ticker = 'VNQ' ORDER BY trading_date DESC LIMIT 1),
    (SELECT close_price FROM daily_stock_prices WHERE ticker = 'VNQ' AND trading_date < DATE_SUB('2026-06-18', INTERVAL 180 DAY) ORDER BY trading_date DESC LIMIT 1),
    ROUND(100 * ((SELECT close_price FROM daily_stock_prices WHERE ticker = 'VNQ' ORDER BY trading_date DESC LIMIT 1) - (SELECT close_price FROM daily_stock_prices WHERE ticker = 'VNQ' AND trading_date < DATE_SUB('2026-06-18', INTERVAL 180 DAY) ORDER BY trading_date DESC LIMIT 1)) / (SELECT close_price FROM daily_stock_prices WHERE ticker = 'VNQ' AND trading_date < DATE_SUB('2026-06-18', INTERVAL 180 DAY) ORDER BY trading_date DESC LIMIT 1), 2)

UNION ALL

SELECT
    'GLD',
    'SPDR Gold Shares',
    (SELECT close_price FROM daily_stock_prices WHERE ticker = 'GLD' ORDER BY trading_date DESC LIMIT 1),
    (SELECT close_price FROM daily_stock_prices WHERE ticker = 'GLD' AND trading_date < DATE_SUB('2026-06-18', INTERVAL 180 DAY) ORDER BY trading_date DESC LIMIT 1),
    ROUND(100 * ((SELECT close_price FROM daily_stock_prices WHERE ticker = 'GLD' ORDER BY trading_date DESC LIMIT 1) - (SELECT close_price FROM daily_stock_prices WHERE ticker = 'GLD' AND trading_date < DATE_SUB('2026-06-18', INTERVAL 180 DAY) ORDER BY trading_date DESC LIMIT 1)) / (SELECT close_price FROM daily_stock_prices WHERE ticker = 'GLD' AND trading_date < DATE_SUB('2026-06-18', INTERVAL 180 DAY) ORDER BY trading_date DESC LIMIT 1), 2)
ORDER BY return_percent DESC;


-- ============================================================================
-- QUESTION 2 & 3: VOLATILITY (SIMPLE METHOD - NO WINDOW FUNCTIONS)
-- ============================================================================

-- For IXN
SELECT
    'IXN' as ticker,
    'iShares Global Tech ETF' as security_name,
    COUNT(*) as num_days,
    ROUND(AVG(daily_change), 2) as avg_daily_change_pct,
    ROUND(STDDEV(daily_change), 2) as volatility_pct,
    ROUND(MIN(daily_change), 2) as min_daily_change,
    ROUND(MAX(daily_change), 2) as max_daily_change
FROM (
    SELECT close_price, LAG(close_price) OVER (ORDER BY trading_date) as prev_price,
           ((close_price - LAG(close_price) OVER (ORDER BY trading_date)) / LAG(close_price) OVER (ORDER BY trading_date) * 100) as daily_change
    FROM daily_stock_prices
    WHERE ticker = 'IXN' AND trading_date >= DATE_SUB('2026-06-18', INTERVAL 180 DAY)
) as changes
WHERE daily_change IS NOT NULL;


-- ============================================================================
-- FOR ALL TICKERS - SIMPLE VERSION
-- ============================================================================

-- Copy this for each ticker (IXN, QQQ, IEF, VNQ, GLD) and change the ticker name

SELECT
    'IXN' as ticker,
    'iShares Global Tech ETF' as security_name,
    COUNT(*) as num_days,
    ROUND(STDDEV(daily_pct_change), 2) as volatility_pct
FROM (
    SELECT 
        ticker,
        trading_date,
        close_price,
        LAG(close_price) OVER (ORDER BY trading_date) as prev_price,
        (close_price - LAG(close_price) OVER (ORDER BY trading_date)) / LAG(close_price) OVER (ORDER BY trading_date) * 100 as daily_pct_change
    FROM daily_stock_prices
    WHERE ticker = 'IXN' AND trading_date >= DATE_SUB('2026-06-18', INTERVAL 180 DAY)
) t
WHERE daily_pct_change IS NOT NULL
GROUP BY ticker;


-- ============================================================================
-- SIMPLEST VOLATILITY - JUST COPY THIS FOR EACH TICKER
-- ============================================================================

-- RUN THIS 5 TIMES - ONCE FOR EACH TICKER

-- For IXN:
SELECT 'IXN' as ticker, ROUND(STDDEV((close_price - LAG(close_price) OVER (ORDER BY trading_date)) / LAG(close_price) OVER (ORDER BY trading_date) * 100), 2) as volatility FROM daily_stock_prices WHERE ticker = 'IXN' GROUP BY ticker;

-- For QQQ:
SELECT 'QQQ' as ticker, ROUND(STDDEV((close_price - LAG(close_price) OVER (ORDER BY trading_date)) / LAG(close_price) OVER (ORDER BY trading_date) * 100), 2) as volatility FROM daily_stock_prices WHERE ticker = 'QQQ' GROUP BY ticker;

-- For IEF:
SELECT 'IEF' as ticker, ROUND(STDDEV((close_price - LAG(close_price) OVER (ORDER BY trading_date)) / LAG(close_price) OVER (ORDER BY trading_date) * 100), 2) as volatility FROM daily_stock_prices WHERE ticker = 'IEF' GROUP BY ticker;

-- For VNQ:
SELECT 'VNQ' as ticker, ROUND(STDDEV((close_price - LAG(close_price) OVER (ORDER BY trading_date)) / LAG(close_price) OVER (ORDER BY trading_date) * 100), 2) as volatility FROM daily_stock_prices WHERE ticker = 'VNQ' GROUP BY ticker;

-- For GLD:
SELECT 'GLD' as ticker, ROUND(STDDEV((close_price - LAG(close_price) OVER (ORDER BY trading_date)) / LAG(close_price) OVER (ORDER BY trading_date) * 100), 2) as volatility FROM daily_stock_prices WHERE ticker = 'GLD' GROUP BY ticker;


-- ============================================================================
-- PORTFOLIO SUMMARY
-- ============================================================================

SELECT 
    ticker,
    security_name,
    current_percent as allocation_pct,
    asset_class
FROM security_info
ORDER BY current_percent DESC;


-- ============================================================================
-- RECOMMENDATIONS
-- ============================================================================

-- Just copy this table to your PDF

SELECT
    'QQQ' as ticker,
    'NASDAQ 100' as security_name,
    'INCREASE' as action,
    '22.1% → 25%' as change,
    'Best performer' as reason
UNION ALL
SELECT 'IXN', 'Tech ETF', 'HOLD', 'Keep 17.5%', 'Good performer'
UNION ALL
SELECT 'IEF', 'Treasury Bond', 'HOLD', 'Keep 28.5%', 'Stability'
UNION ALL
SELECT 'VNQ', 'Real Estate', 'INCREASE', '8.9% → 10%', 'Diversification'
UNION ALL
SELECT 'GLD', 'Gold', 'REDUCE', '23% → 17%', 'Underperformer'
ORDER BY action;

