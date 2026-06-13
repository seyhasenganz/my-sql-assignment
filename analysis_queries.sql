-- ===================================
-- UHNW PORTFOLIO ANALYSIS QUERIES
-- 5 Question Groups
-- ===================================

USE investment_portfolio;

-- ===================================
-- QUESTION 1: RETURNS (12M, 18M, 24M)
-- ===================================

SELECT
    sml.ticker,
    sml.security_name,
    ROUND(((end_12m.adjusted_close - start_12m.adjusted_close) / start_12m.adjusted_close) * 100, 2) as return_12m_pct,
    ROUND(((end_18m.adjusted_close - start_18m.adjusted_close) / start_18m.adjusted_close) * 100, 2) as return_18m_pct,
    ROUND(((end_24m.adjusted_close - start_24m.adjusted_close) / start_24m.adjusted_close) * 100, 2) as return_24m_pct
FROM security_masterlist sml
LEFT JOIN (SELECT ticker, adjusted_close FROM pricing_daily WHERE price_date = CURDATE() ORDER BY price_date DESC LIMIT 1) end_12m ON sml.ticker = end_12m.ticker
LEFT JOIN (SELECT ticker, adjusted_close FROM pricing_daily WHERE price_date <= DATE_SUB(CURDATE(), INTERVAL 12 MONTH) ORDER BY price_date DESC LIMIT 1) start_12m ON sml.ticker = start_12m.ticker
LEFT JOIN (SELECT ticker, adjusted_close FROM pricing_daily WHERE price_date <= CURDATE() ORDER BY price_date DESC LIMIT 1) end_18m ON sml.ticker = end_18m.ticker
LEFT JOIN (SELECT ticker, adjusted_close FROM pricing_daily WHERE price_date <= DATE_SUB(CURDATE(), INTERVAL 18 MONTH) ORDER BY price_date DESC LIMIT 1) start_18m ON sml.ticker = start_18m.ticker
LEFT JOIN (SELECT ticker, adjusted_close FROM pricing_daily WHERE price_date <= CURDATE() ORDER BY price_date DESC LIMIT 1) end_24m ON sml.ticker = end_24m.ticker
LEFT JOIN (SELECT ticker, adjusted_close FROM pricing_daily WHERE price_date <= DATE_SUB(CURDATE(), INTERVAL 24 MONTH) ORDER BY price_date DESC LIMIT 1) start_24m ON sml.ticker = start_24m.ticker
ORDER BY sml.ticker;

-- ===================================
-- QUESTION 2: CORRELATIONS & VARIANCE
-- ===================================

SELECT
    sml.ticker,
    sml.security_name,
    ROUND(AVG(daily_return), 4) as avg_daily_return_pct,
    ROUND(STDDEV_POP(daily_return), 4) as daily_sigma,
    ROUND(VARIANCE(daily_return), 6) as variance
FROM security_masterlist sml
LEFT JOIN (
    SELECT
        ticker,
        ROUND(((adjusted_close - LAG(adjusted_close) OVER (PARTITION BY ticker ORDER BY price_date))
               / LAG(adjusted_close) OVER (PARTITION BY ticker ORDER BY price_date)) * 100, 4) as daily_return
    FROM pricing_daily
    WHERE price_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
) returns ON sml.ticker = returns.ticker
WHERE returns.daily_return IS NOT NULL
GROUP BY sml.ticker, sml.security_name
ORDER BY variance DESC;

-- ===================================
-- QUESTION 3: VOLATILITY (12M & 6M)
-- ===================================

SELECT
    sml.ticker,
    sml.security_name,
    sml.major_asset_class,
    ROUND(STDDEV_POP(r12.daily_return) * SQRT(252), 2) as annual_volatility_12m,
    ROUND(STDDEV_POP(r6.daily_return) * SQRT(252), 2) as annual_volatility_6m
FROM security_masterlist sml
LEFT JOIN (
    SELECT
        ticker,
        ROUND(((adjusted_close - LAG(adjusted_close) OVER (PARTITION BY ticker ORDER BY price_date))
               / LAG(adjusted_close) OVER (PARTITION BY ticker ORDER BY price_date)) * 100, 4) as daily_return
    FROM pricing_daily
    WHERE price_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
) r12 ON sml.ticker = r12.ticker
LEFT JOIN (
    SELECT
        ticker,
        ROUND(((adjusted_close - LAG(adjusted_close) OVER (PARTITION BY ticker ORDER BY price_date))
               / LAG(adjusted_close) OVER (PARTITION BY ticker ORDER BY price_date)) * 100, 4) as daily_return
    FROM pricing_daily
    WHERE price_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
) r6 ON sml.ticker = r6.ticker
WHERE r12.daily_return IS NOT NULL AND r6.daily_return IS NOT NULL
GROUP BY sml.ticker, sml.security_name, sml.major_asset_class
ORDER BY annual_volatility_12m DESC;

-- ===================================
-- QUESTION 4: SHARPE RATIO & RECOMMENDATIONS
-- ===================================

SELECT
    sml.ticker,
    sml.security_name,
    hd.portfolio_weight,
    ROUND(AVG(ret.daily_return) * 252, 2) as annual_return,
    ROUND(STDDEV_POP(ret.daily_return) * SQRT(252), 2) as annual_volatility,
    ROUND((AVG(ret.daily_return) * 252 - 2) / (STDDEV_POP(ret.daily_return) * SQRT(252)), 4) as sharpe_ratio,
    CASE
        WHEN (AVG(ret.daily_return) * 252 - 2) / (STDDEV_POP(ret.daily_return) * SQRT(252)) > 0.5 THEN 'HOLD/BUY'
        WHEN (AVG(ret.daily_return) * 252 - 2) / (STDDEV_POP(ret.daily_return) * SQRT(252)) > 0.2 THEN 'HOLD'
        ELSE 'CONSIDER SELLING'
    END as recommendation
FROM security_masterlist sml
LEFT JOIN (
    SELECT
        ticker,
        ROUND(((adjusted_close - LAG(adjusted_close) OVER (PARTITION BY ticker ORDER BY price_date))
               / LAG(adjusted_close) OVER (PARTITION BY ticker ORDER BY price_date)) * 100, 4) as daily_return
    FROM pricing_daily
    WHERE price_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
) ret ON sml.ticker = ret.ticker
LEFT JOIN holdings_dim hd ON sml.ticker = hd.ticker AND hd.account_id = 1001
WHERE ret.daily_return IS NOT NULL
GROUP BY sml.ticker, sml.security_name, hd.portfolio_weight
ORDER BY sharpe_ratio DESC;

-- ===================================
-- QUESTION 5: POST-REBALANCING IMPACT
-- ===================================

-- CURRENT PORTFOLIO
SELECT 'CURRENT' as portfolio_status,
    ROUND(SUM(hd.portfolio_weight * (AVG(ret.daily_return) * 252)) / 100, 2) as expected_annual_return,
    ROUND(SQRT(SUM(POWER(hd.portfolio_weight/100, 2) * POWER(STDDEV_POP(ret.daily_return) * SQRT(252), 2))), 2) as portfolio_volatility,
    ROUND((SUM(hd.portfolio_weight * (AVG(ret.daily_return) * 252)) / 100 - 2) / SQRT(SUM(POWER(hd.portfolio_weight/100, 2) * POWER(STDDEV_POP(ret.daily_return) * SQRT(252), 2))), 4) as sharpe_ratio
FROM holdings_dim hd
LEFT JOIN (
    SELECT
        ticker,
        ROUND(((adjusted_close - LAG(adjusted_close) OVER (PARTITION BY ticker ORDER BY price_date))
               / LAG(adjusted_close) OVER (PARTITION BY ticker ORDER BY price_date)) * 100, 4) as daily_return
    FROM pricing_daily
    WHERE price_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
) ret ON hd.ticker = ret.ticker
WHERE hd.account_id = 1001 AND ret.daily_return IS NOT NULL
GROUP BY hd.account_id
UNION ALL
-- PROPOSED REBALANCING
SELECT 'PROPOSED' as portfolio_status,
    ROUND(SUM(
        CASE
            WHEN ticker = 'IXN' THEN 15.00
            WHEN ticker = 'QQQ' THEN 20.00
            WHEN ticker = 'IEF' THEN 30.00
            WHEN ticker = 'VNQ' THEN 12.00
            ELSE 23.00
        END * (AVG(ret.daily_return) * 252)
    ) / 100, 2) as expected_annual_return,
    ROUND(SQRT(SUM(POWER(
        CASE
            WHEN ticker = 'IXN' THEN 15.00
            WHEN ticker = 'QQQ' THEN 20.00
            WHEN ticker = 'IEF' THEN 30.00
            WHEN ticker = 'VNQ' THEN 12.00
            ELSE 23.00
        END/100, 2) * POWER(STDDEV_POP(ret.daily_return) * SQRT(252), 2)
    )), 2) as portfolio_volatility,
    ROUND((SUM(
        CASE
            WHEN ticker = 'IXN' THEN 15.00
            WHEN ticker = 'QQQ' THEN 20.00
            WHEN ticker = 'IEF' THEN 30.00
            WHEN ticker = 'VNQ' THEN 12.00
            ELSE 23.00
        END * (AVG(ret.daily_return) * 252)
    ) / 100 - 2) / SQRT(SUM(POWER(
        CASE
            WHEN ticker = 'IXN' THEN 15.00
            WHEN ticker = 'QQQ' THEN 20.00
            WHEN ticker = 'IEF' THEN 30.00
            WHEN ticker = 'VNQ' THEN 12.00
            ELSE 23.00
        END/100, 2) * POWER(STDDEV_POP(ret.daily_return) * SQRT(252), 2)
    )), 4) as sharpe_ratio
FROM security_masterlist
LEFT JOIN (
    SELECT
        ticker,
        ROUND(((adjusted_close - LAG(adjusted_close) OVER (PARTITION BY ticker ORDER BY price_date))
               / LAG(adjusted_close) OVER (PARTITION BY ticker ORDER BY price_date)) * 100, 4) as daily_return
    FROM pricing_daily
    WHERE price_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
) ret ON security_masterlist.ticker = ret.ticker
WHERE ret.daily_return IS NOT NULL
GROUP BY security_masterlist.ticker;
