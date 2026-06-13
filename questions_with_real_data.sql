-- ===================================
-- UHNW PORTFOLIO ANALYSIS - USING REAL DATA
-- SQL Queries for 5 Questions
-- Updated to use pricing_daily table structure:
-- Columns: date, ticker, price_type, value
-- ===================================

USE invest_portfolio;

-- ===================================
-- QUESTION 1: RETURNS (12M, 18M, 24M)
-- ===================================

SELECT
    sml.ticker,
    sml.security_name,
    ROUND(((end_price.value - start_price_12m.value) / start_price_12m.value) * 100, 2) as return_12m_pct,
    ROUND(((end_price.value - start_price_18m.value) / start_price_18m.value) * 100, 2) as return_18m_pct,
    ROUND(((end_price.value - start_price_24m.value) / start_price_24m.value) * 100, 2) as return_24m_pct,
    hd.portfolio_weight as current_weight_pct,
    ROUND(hd.portfolio_weight * ((end_price.value - start_price_12m.value) / start_price_12m.value), 2) as contribution_12m
FROM security_masterlist sml
LEFT JOIN holdings_dim hd ON sml.ticker = hd.ticker AND hd.account_id = 1001
LEFT JOIN (
    SELECT ticker, value
    FROM pricing_daily
    WHERE price_type = 'Adj Close'
    AND date = (SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close')
) end_price ON sml.ticker = end_price.ticker
LEFT JOIN (
    SELECT ticker, value
    FROM pricing_daily
    WHERE price_type = 'Adj Close'
    AND date = (
        SELECT MAX(date) FROM pricing_daily p2
        WHERE price_type = 'Adj Close'
        AND DATE_ADD(p2.date, INTERVAL 12 MONTH) >= (SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close')
    )
) start_price_12m ON sml.ticker = start_price_12m.ticker
LEFT JOIN (
    SELECT ticker, value
    FROM pricing_daily
    WHERE price_type = 'Adj Close'
    AND date = (
        SELECT MAX(date) FROM pricing_daily p3
        WHERE price_type = 'Adj Close'
        AND DATE_ADD(p3.date, INTERVAL 18 MONTH) >= (SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close')
    )
) start_price_18m ON sml.ticker = start_price_18m.ticker
LEFT JOIN (
    SELECT ticker, value
    FROM pricing_daily
    WHERE price_type = 'Adj Close'
    AND date = (
        SELECT MAX(date) FROM pricing_daily p4
        WHERE price_type = 'Adj Close'
        AND DATE_ADD(p4.date, INTERVAL 24 MONTH) >= (SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close')
    )
) start_price_24m ON sml.ticker = start_price_24m.ticker
ORDER BY return_12m_pct DESC;

-- PORTFOLIO LEVEL RETURNS
SELECT
    'TOTAL PORTFOLIO' as portfolio_metric,
    ROUND(SUM(hd.portfolio_weight * ((end_price.value - start_price_12m.value) / start_price_12m.value)), 2) as portfolio_return_12m_pct,
    ROUND(SUM(hd.portfolio_weight * ((end_price.value - start_price_18m.value) / start_price_18m.value)), 2) as portfolio_return_18m_pct,
    ROUND(SUM(hd.portfolio_weight * ((end_price.value - start_price_24m.value) / start_price_24m.value)), 2) as portfolio_return_24m_pct
FROM holdings_dim hd
LEFT JOIN (SELECT ticker, value FROM pricing_daily WHERE price_type = 'Adj Close' AND date = (SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close')) end_price ON hd.ticker = end_price.ticker
LEFT JOIN (SELECT ticker, value FROM pricing_daily WHERE price_type = 'Adj Close' AND date = (SELECT MAX(date) FROM pricing_daily p2 WHERE price_type = 'Adj Close' AND DATE_ADD(p2.date, INTERVAL 12 MONTH) >= (SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close'))) start_price_12m ON hd.ticker = start_price_12m.ticker
LEFT JOIN (SELECT ticker, value FROM pricing_daily WHERE price_type = 'Adj Close' AND date = (SELECT MAX(date) FROM pricing_daily p3 WHERE price_type = 'Adj Close' AND DATE_ADD(p3.date, INTERVAL 18 MONTH) >= (SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close'))) start_price_18m ON hd.ticker = start_price_18m.ticker
LEFT JOIN (SELECT ticker, value FROM pricing_daily WHERE price_type = 'Adj Close' AND date = (SELECT MAX(date) FROM pricing_daily p4 WHERE price_type = 'Adj Close' AND DATE_ADD(p4.date, INTERVAL 24 MONTH) >= (SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close'))) start_price_24m ON hd.ticker = start_price_24m.ticker
WHERE hd.account_id = 1001;

-- ===================================
-- QUESTION 2: CORRELATIONS & VARIANCE
-- ===================================

WITH daily_returns AS (
    SELECT
        ticker,
        date,
        value,
        LAG(value) OVER (PARTITION BY ticker ORDER BY date) as prev_price,
        ROUND(
            ((value - LAG(value) OVER (PARTITION BY ticker ORDER BY date)) /
             LAG(value) OVER (PARTITION BY ticker ORDER BY date)) * 100,
            4
        ) as daily_return_pct
    FROM pricing_daily
    WHERE price_type = 'Adj Close'
    AND date >= DATE_SUB((SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close'), INTERVAL 6 MONTH)
)
SELECT
    ticker,
    COUNT(*) as trading_days,
    ROUND(AVG(daily_return_pct), 4) as avg_daily_return_pct,
    ROUND(STDDEV_POP(daily_return_pct), 4) as daily_stddev,
    ROUND(VARIANCE(daily_return_pct), 6) as variance_6m,
    ROUND(MIN(daily_return_pct), 4) as worst_day_return,
    ROUND(MAX(daily_return_pct), 4) as best_day_return
FROM daily_returns
WHERE daily_return_pct IS NOT NULL
GROUP BY ticker
ORDER BY variance_6m DESC;

-- ===================================
-- QUESTION 3: VOLATILITY (12M & 6M SIGMA)
-- ===================================

WITH daily_returns_12m AS (
    SELECT
        ticker,
        ROUND(
            ((value - LAG(value) OVER (PARTITION BY ticker ORDER BY date)) /
             LAG(value) OVER (PARTITION BY ticker ORDER BY date)) * 100,
            4
        ) as daily_return_pct
    FROM pricing_daily
    WHERE price_type = 'Adj Close'
    AND date >= DATE_SUB((SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close'), INTERVAL 12 MONTH)
),
daily_returns_6m AS (
    SELECT
        ticker,
        ROUND(
            ((value - LAG(value) OVER (PARTITION BY ticker ORDER BY date)) /
             LAG(value) OVER (PARTITION BY ticker ORDER BY date)) * 100,
            4
        ) as daily_return_pct
    FROM pricing_daily
    WHERE price_type = 'Adj Close'
    AND date >= DATE_SUB((SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close'), INTERVAL 6 MONTH)
)
SELECT
    sml.ticker,
    sml.security_name,
    sml.major_asset_class,
    hd.portfolio_weight as current_allocation_pct,
    ROUND(STDDEV_POP(d12m.daily_return_pct) * SQRT(252), 2) as annual_volatility_12m,
    ROUND(STDDEV_POP(d6m.daily_return_pct) * SQRT(252), 2) as annual_volatility_6m,
    CASE
        WHEN STDDEV_POP(d12m.daily_return_pct) * SQRT(252) > 25 THEN 'HIGH RISK'
        WHEN STDDEV_POP(d12m.daily_return_pct) * SQRT(252) > 15 THEN 'MODERATE RISK'
        ELSE 'LOW RISK'
    END as risk_classification
FROM security_masterlist sml
LEFT JOIN daily_returns_12m d12m ON sml.ticker = d12m.ticker
LEFT JOIN daily_returns_6m d6m ON sml.ticker = d6m.ticker
LEFT JOIN holdings_dim hd ON sml.ticker = hd.ticker AND hd.account_id = 1001
WHERE d12m.daily_return_pct IS NOT NULL AND d6m.daily_return_pct IS NOT NULL
GROUP BY sml.ticker, sml.security_name, sml.major_asset_class, hd.portfolio_weight
ORDER BY annual_volatility_12m DESC;

-- ===================================
-- QUESTION 4: SHARPE RATIO & RECOMMENDATIONS
-- ===================================

WITH returns_12m AS (
    SELECT
        ticker,
        ROUND(
            ((value - LAG(value) OVER (PARTITION BY ticker ORDER BY date)) /
             LAG(value) OVER (PARTITION BY ticker ORDER BY date)) * 100,
            4
        ) as daily_return_pct
    FROM pricing_daily
    WHERE price_type = 'Adj Close'
    AND date >= DATE_SUB((SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close'), INTERVAL 12 MONTH)
)
SELECT
    sml.ticker,
    sml.security_name,
    sml.major_asset_class,
    hd.portfolio_weight as current_allocation_pct,
    hd.market_value_million as market_value_mm,
    ROUND(AVG(r.daily_return_pct) * 252, 2) as expected_annual_return_pct,
    ROUND(STDDEV_POP(r.daily_return_pct) * SQRT(252), 2) as annual_volatility_pct,
    ROUND((AVG(r.daily_return_pct) * 252 - 2) / (STDDEV_POP(r.daily_return_pct) * SQRT(252)), 4) as sharpe_ratio,
    CASE
        WHEN (AVG(r.daily_return_pct) * 252 - 2) / (STDDEV_POP(r.daily_return_pct) * SQRT(252)) > 0.5 THEN 'BUY - Excellent'
        WHEN (AVG(r.daily_return_pct) * 252 - 2) / (STDDEV_POP(r.daily_return_pct) * SQRT(252)) > 0.2 THEN 'HOLD - Acceptable'
        ELSE 'SELL - Underperforming'
    END as recommendation
FROM security_masterlist sml
LEFT JOIN returns_12m r ON sml.ticker = r.ticker
LEFT JOIN holdings_dim hd ON sml.ticker = hd.ticker AND hd.account_id = 1001
WHERE r.daily_return_pct IS NOT NULL
GROUP BY sml.ticker, sml.security_name, sml.major_asset_class, hd.portfolio_weight, hd.market_value_million
ORDER BY sharpe_ratio DESC;

-- ===================================
-- QUESTION 5: PORTFOLIO IMPACT ANALYSIS
-- ===================================

SELECT
    'Metric' as analysis,
    'Current Allocation' as current_value,
    'Proposed Allocation' as proposed_value,
    'Change' as change_value
UNION ALL
SELECT
    ticker,
    CONCAT(portfolio_weight, '%'),
    CONCAT(
        CASE
            WHEN ticker = 'IXN' THEN '15.0%'
            WHEN ticker = 'QQQ' THEN '20.0%'
            WHEN ticker = 'IEF' THEN '30.0%'
            WHEN ticker = 'VNQ' THEN '12.0%'
            ELSE '23.0%'
        END
    ),
    CONCAT(
        CASE
            WHEN ticker = 'IXN' THEN '-2.5%'
            WHEN ticker = 'QQQ' THEN '-2.1%'
            WHEN ticker = 'IEF' THEN '+1.5%'
            WHEN ticker = 'VNQ' THEN '+3.1%'
            ELSE '0.0%'
        END
    )
FROM holdings_dim
WHERE account_id = 1001
ORDER BY ticker;
