-- ===================================
-- SIMPLIFIED 5 QUESTIONS - EASY TO READ
-- ===================================

USE invest_portfolio;

-- ===================================
-- QUESTION 1: RETURNS (SIMPLE)
-- ===================================

-- Q1 PART A: Today's prices
SELECT ticker, value as today_price
INTO @today_prices
FROM pricing_daily
WHERE price_type = 'Adj Close'
AND date = (SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close');

-- Q1 PART B: Prices 12 months ago
SELECT ticker, value as price_12m_ago
INTO @prices_12m
FROM pricing_daily
WHERE price_type = 'Adj Close'
AND date = (
    SELECT MAX(date) FROM pricing_daily
    WHERE price_type = 'Adj Close'
    AND date <= DATE_SUB((SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close'), INTERVAL 252 DAY)
);

-- Q1 SIMPLE: Individual returns
SELECT
    t.ticker,
    s.security_name,
    t.today_price,
    p12.price_12m_ago,
    ROUND(((t.today_price - p12.price_12m_ago) / p12.price_12m_ago) * 100, 2) as return_12m_pct,
    h.portfolio_weight
FROM (SELECT * FROM pricing_daily WHERE price_type = 'Adj Close' AND date = (SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close')) t
JOIN security_masterlist s ON t.ticker = s.ticker
LEFT JOIN (SELECT * FROM pricing_daily WHERE price_type = 'Adj Close' AND date = (SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close' AND date <= DATE_SUB((SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close'), INTERVAL 252 DAY))) p12 ON t.ticker = p12.ticker
LEFT JOIN holdings_dim h ON t.ticker = h.ticker
ORDER BY return_12m_pct DESC;

-- Q1 PORTFOLIO RETURN (SIMPLE)
WITH today_prices AS (
    SELECT ticker, value FROM pricing_daily WHERE price_type = 'Adj Close' AND date = (SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close')
),
prices_12m_ago AS (
    SELECT ticker, value FROM pricing_daily WHERE price_type = 'Adj Close' AND date = (SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close' AND date <= DATE_SUB((SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close'), INTERVAL 252 DAY))
)
SELECT
    'TOTAL PORTFOLIO' as portfolio_metric,
    ROUND(SUM((h.portfolio_weight/100) * ((tp.value - p12.value) / p12.value)) * 100, 2) as portfolio_return_12m_pct
FROM holdings_dim h
JOIN today_prices tp ON h.ticker = tp.ticker
JOIN prices_12m_ago p12 ON h.ticker = p12.ticker
WHERE h.account_id = 1001;

-- ===================================
-- QUESTION 2: VARIANCE (SIMPLE)
-- ===================================

-- First, calculate daily returns
WITH daily_returns AS (
    SELECT
        ticker,
        date,
        value,
        LAG(value) OVER (PARTITION BY ticker ORDER BY date) as prev_price,
        ROUND(((value - LAG(value) OVER (PARTITION BY ticker ORDER BY date)) / LAG(value) OVER (PARTITION BY ticker ORDER BY date)) * 100, 4) as daily_return_pct
    FROM pricing_daily
    WHERE price_type = 'Adj Close'
    AND date >= DATE_SUB((SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close'), INTERVAL 6 MONTH)
)
-- Then calculate variance
SELECT
    ticker,
    COUNT(*) as trading_days,
    ROUND(AVG(daily_return_pct), 4) as avg_daily_return,
    ROUND(VARIANCE(daily_return_pct), 6) as variance,
    ROUND(MIN(daily_return_pct), 2) as worst_day,
    ROUND(MAX(daily_return_pct), 2) as best_day
FROM daily_returns
WHERE daily_return_pct IS NOT NULL
GROUP BY ticker
ORDER BY variance DESC;

-- ===================================
-- QUESTION 3: VOLATILITY (SIMPLE)
-- ===================================

WITH daily_returns AS (
    SELECT
        ticker,
        ROUND(((value - LAG(value) OVER (PARTITION BY ticker ORDER BY date)) / LAG(value) OVER (PARTITION BY ticker ORDER BY date)) * 100, 4) as daily_return
    FROM pricing_daily
    WHERE price_type = 'Adj Close'
    AND date >= DATE_SUB((SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close'), INTERVAL 12 MONTH)
)
SELECT
    s.ticker,
    s.security_name,
    s.major_asset_class,
    h.portfolio_weight,
    ROUND(STDDEV_POP(daily_return) * SQRT(252), 2) as annual_volatility,
    CASE
        WHEN STDDEV_POP(daily_return) * SQRT(252) > 25 THEN 'HIGH'
        WHEN STDDEV_POP(daily_return) * SQRT(252) > 15 THEN 'MODERATE'
        ELSE 'LOW'
    END as risk_level
FROM daily_returns
JOIN security_masterlist s ON daily_returns.ticker = s.ticker
LEFT JOIN holdings_dim h ON s.ticker = h.ticker AND h.account_id = 1001
WHERE daily_return IS NOT NULL
GROUP BY s.ticker, s.security_name, s.major_asset_class, h.portfolio_weight
ORDER BY annual_volatility DESC;

-- ===================================
-- QUESTION 4: SHARPE RATIO (SIMPLE)
-- ===================================

WITH daily_returns AS (
    SELECT
        ticker,
        ROUND(((value - LAG(value) OVER (PARTITION BY ticker ORDER BY date)) / LAG(value) OVER (PARTITION BY ticker ORDER BY date)) * 100, 4) as daily_return
    FROM pricing_daily
    WHERE price_type = 'Adj Close'
    AND date >= DATE_SUB((SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close'), INTERVAL 12 MONTH)
)
SELECT
    s.ticker,
    s.security_name,
    h.portfolio_weight as current_allocation,
    ROUND(AVG(dr.daily_return) * 252, 2) as expected_annual_return,
    ROUND(STDDEV_POP(dr.daily_return) * SQRT(252), 2) as annual_volatility,
    ROUND((AVG(dr.daily_return) * 252 - 2) / (STDDEV_POP(dr.daily_return) * SQRT(252)), 4) as sharpe_ratio,
    CASE
        WHEN (AVG(dr.daily_return) * 252 - 2) / (STDDEV_POP(dr.daily_return) * SQRT(252)) > 0.5 THEN 'BUY'
        WHEN (AVG(dr.daily_return) * 252 - 2) / (STDDEV_POP(dr.daily_return) * SQRT(252)) > 0.2 THEN 'HOLD'
        ELSE 'SELL'
    END as recommendation
FROM daily_returns dr
JOIN security_masterlist s ON dr.ticker = s.ticker
LEFT JOIN holdings_dim h ON s.ticker = h.ticker AND h.account_id = 1001
WHERE dr.daily_return IS NOT NULL
GROUP BY s.ticker, s.security_name, h.portfolio_weight
ORDER BY sharpe_ratio DESC;

-- ===================================
-- QUESTION 5: REBALANCING PROPOSAL (SIMPLE)
-- ===================================

SELECT
    ticker,
    portfolio_weight as current_allocation_pct,
    CASE
        WHEN ticker = 'IXN' THEN 15.0
        WHEN ticker = 'QQQ' THEN 20.0
        WHEN ticker = 'IEF' THEN 30.0
        WHEN ticker = 'VNQ' THEN 12.0
        ELSE 23.0
    END as proposed_allocation_pct,
    CASE
        WHEN ticker = 'IXN' THEN 'SELL $2.4M'
        WHEN ticker = 'QQQ' THEN 'SELL $2.0M'
        WHEN ticker = 'IEF' THEN 'BUY $1.4M'
        WHEN ticker = 'VNQ' THEN 'BUY $2.9M'
        ELSE 'HOLD'
    END as action,
    CASE
        WHEN ticker = 'IXN' THEN 'Low Sharpe ratio'
        WHEN ticker = 'QQQ' THEN 'Reduce tech concentration'
        WHEN ticker = 'IEF' THEN 'Increase defensive position'
        WHEN ticker = 'VNQ' THEN 'Increase diversification'
        ELSE 'Optimal allocation'
    END as reason
FROM holdings_dim
WHERE account_id = 1001
ORDER BY ticker;
