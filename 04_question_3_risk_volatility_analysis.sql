-- =====================================================
-- QUESTION 3: RISK (VOLATILITY/SIGMA) ANALYSIS
-- =====================================================
-- Purpose: Calculate 12-month and 6-month volatility (standard deviation)
-- Framework: Sigma = SQRT(Variance of returns)
--           Annualized Sigma = Daily Sigma * SQRT(252) [252 trading days]

-- =====================================================
-- QUERY 3.1: 12-Month Volatility (Sigma) for Each Security
-- =====================================================
SELECT
    sml.ticker,
    sml.security_name,
    sml.major_asset_class,
    '12-Month Volatility' as period,
    COUNT(DISTINCT price_date) as trading_days,
    ROUND(AVG(daily_return_pct), 4) as avg_daily_return_pct,
    ROUND(STDDEV_POP(daily_return_pct), 4) as daily_volatility_sigma,
    ROUND(STDDEV_POP(daily_return_pct) * SQRT(252), 4) as annualized_volatility_12m,
    ROUND(VARIANCE(daily_return_pct), 6) as variance_12m,
    ROUND(MIN(daily_return_pct), 4) as min_daily_return_12m,
    ROUND(MAX(daily_return_pct), 4) as max_daily_return_12m
FROM security_masterlist sml
LEFT JOIN (
    SELECT
        ticker,
        price_date,
        ROUND(
            ((adjusted_close - LAG(adjusted_close, 1) OVER (PARTITION BY ticker ORDER BY price_date))
             / LAG(adjusted_close, 1) OVER (PARTITION BY ticker ORDER BY price_date)) * 100,
            4
        ) as daily_return_pct
    FROM pricing_daily
    WHERE price_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
) returns_12m ON sml.ticker = returns_12m.ticker
WHERE returns_12m.daily_return_pct IS NOT NULL
GROUP BY sml.ticker, sml.security_name, sml.major_asset_class
ORDER BY annualized_volatility_12m DESC;

-- =====================================================
-- QUERY 3.2: 6-Month Volatility (Sigma) for Each Security
-- =====================================================
SELECT
    sml.ticker,
    sml.security_name,
    sml.major_asset_class,
    '6-Month Volatility' as period,
    COUNT(DISTINCT price_date) as trading_days,
    ROUND(AVG(daily_return_pct), 4) as avg_daily_return_pct,
    ROUND(STDDEV_POP(daily_return_pct), 4) as daily_volatility_sigma,
    ROUND(STDDEV_POP(daily_return_pct) * SQRT(252), 4) as annualized_volatility_6m,
    ROUND(VARIANCE(daily_return_pct), 6) as variance_6m,
    ROUND(MIN(daily_return_pct), 4) as min_daily_return_6m,
    ROUND(MAX(daily_return_pct), 4) as max_daily_return_6m
FROM security_masterlist sml
LEFT JOIN (
    SELECT
        ticker,
        price_date,
        ROUND(
            ((adjusted_close - LAG(adjusted_close, 1) OVER (PARTITION BY ticker ORDER BY price_date))
             / LAG(adjusted_close, 1) OVER (PARTITION BY ticker ORDER BY price_date)) * 100,
            4
        ) as daily_return_pct
    FROM pricing_daily
    WHERE price_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
) returns_6m ON sml.ticker = returns_6m.ticker
WHERE returns_6m.daily_return_pct IS NOT NULL
GROUP BY sml.ticker, sml.security_name, sml.major_asset_class
ORDER BY annualized_volatility_6m DESC;

-- =====================================================
-- QUERY 3.3: Portfolio Risk (Weighted Volatility)
-- =====================================================
-- Portfolio Risk = SQRT(SUM of (weight^2 * sigma^2) + 2 * SUM(correlations))
-- For simplicity, we'll calculate weighted average volatility
SELECT
    'PORTFOLIO - Weighted Risk Analysis' as portfolio_metric,
    ROUND(
        SUM(hd.portfolio_weight * vol.annualized_volatility_12m) / 100,
        4
    ) as weighted_volatility_12m,
    ROUND(
        SUM(hd.portfolio_weight * vol.annualized_volatility_6m) / 100,
        4
    ) as weighted_volatility_6m,
    COUNT(DISTINCT hd.ticker) as number_of_holdings,
    ROUND(SUM(hd.portfolio_weight), 2) as total_allocation_pct
FROM holdings_dim hd
LEFT JOIN (
    SELECT
        sml.ticker,
        ROUND(STDDEV_POP(daily_return_pct) * SQRT(252), 4) as annualized_volatility_12m,
        ROUND(STDDEV_POP(daily_return_pct_6m) * SQRT(252), 4) as annualized_volatility_6m
    FROM security_masterlist sml
    LEFT JOIN (
        SELECT
            ticker,
            ROUND(
                ((adjusted_close - LAG(adjusted_close, 1) OVER (PARTITION BY ticker ORDER BY price_date))
                 / LAG(adjusted_close, 1) OVER (PARTITION BY ticker ORDER BY price_date)) * 100,
                4
            ) as daily_return_pct
        FROM pricing_daily
        WHERE price_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
    ) returns_12m ON sml.ticker = returns_12m.ticker
    LEFT JOIN (
        SELECT
            ticker,
            ROUND(
                ((adjusted_close - LAG(adjusted_close, 1) OVER (PARTITION BY ticker ORDER BY price_date))
                 / LAG(adjusted_close, 1) OVER (PARTITION BY ticker ORDER BY price_date)) * 100,
                4
            ) as daily_return_pct_6m
        FROM pricing_daily
        WHERE price_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
    ) returns_6m ON sml.ticker = returns_6m.ticker
    WHERE returns_12m.daily_return_pct IS NOT NULL AND returns_6m.daily_return_pct_6m IS NOT NULL
    GROUP BY sml.ticker
) vol ON hd.ticker = vol.ticker
WHERE hd.account_id = 1001
GROUP BY hd.account_id;

-- =====================================================
-- QUERY 3.4: Volatility Comparison - Risk Ranking
-- =====================================================
SELECT
    ROW_NUMBER() OVER (ORDER BY annualized_volatility_12m DESC) as risk_rank,
    ticker,
    security_name,
    major_asset_class,
    ROUND(annualized_volatility_12m, 4) as volatility_12m,
    ROUND(annualized_volatility_6m, 4) as volatility_6m,
    ROUND((annualized_volatility_6m - annualized_volatility_12m), 4) as volatility_trend,
    CASE
        WHEN annualized_volatility_12m > 30 THEN 'High Risk'
        WHEN annualized_volatility_12m > 15 THEN 'Moderate Risk'
        ELSE 'Low Risk'
    END as risk_classification
FROM (
    SELECT
        sml.ticker,
        sml.security_name,
        sml.major_asset_class,
        ROUND(STDDEV_POP(r12.daily_return_pct) * SQRT(252), 4) as annualized_volatility_12m,
        ROUND(STDDEV_POP(r6.daily_return_pct) * SQRT(252), 4) as annualized_volatility_6m
    FROM security_masterlist sml
    LEFT JOIN (
        SELECT
            ticker,
            ROUND(
                ((adjusted_close - LAG(adjusted_close, 1) OVER (PARTITION BY ticker ORDER BY price_date))
                 / LAG(adjusted_close, 1) OVER (PARTITION BY ticker ORDER BY price_date)) * 100,
                4
            ) as daily_return_pct
        FROM pricing_daily
        WHERE price_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
    ) r12 ON sml.ticker = r12.ticker
    LEFT JOIN (
        SELECT
            ticker,
            ROUND(
                ((adjusted_close - LAG(adjusted_close, 1) OVER (PARTITION BY ticker ORDER BY price_date))
                 / LAG(adjusted_close, 1) OVER (PARTITION BY ticker ORDER BY price_date)) * 100,
                4
            ) as daily_return_pct
        FROM pricing_daily
        WHERE price_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
    ) r6 ON sml.ticker = r6.ticker
    WHERE r12.daily_return_pct IS NOT NULL AND r6.daily_return_pct IS NOT NULL
    GROUP BY sml.ticker, sml.security_name, sml.major_asset_class
) volatility_analysis
ORDER BY risk_rank;

-- =====================================================
-- QUERY 3.5: Value at Risk (VaR) Analysis - 95% Confidence Level
-- =====================================================
-- VaR at 95% confidence = Mean Return - (1.645 * Sigma)
-- This shows the worst expected loss with 95% confidence
WITH returns_analysis AS (
    SELECT
        sml.ticker,
        sml.security_name,
        AVG(daily_return_pct) as mean_return,
        STDDEV_POP(daily_return_pct) as daily_sigma,
        STDDEV_POP(daily_return_pct) * SQRT(252) as annual_sigma,
        MIN(daily_return_pct) as worst_case_daily,
        MAX(daily_return_pct) as best_case_daily
    FROM security_masterlist sml
    LEFT JOIN (
        SELECT
            ticker,
            ROUND(
                ((adjusted_close - LAG(adjusted_close, 1) OVER (PARTITION BY ticker ORDER BY price_date))
                 / LAG(adjusted_close, 1) OVER (PARTITION BY ticker ORDER BY price_date)) * 100,
                4
            ) as daily_return_pct
        FROM pricing_daily
        WHERE price_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
    ) returns_12m ON sml.ticker = returns_12m.ticker
    WHERE returns_12m.daily_return_pct IS NOT NULL
    GROUP BY sml.ticker, sml.security_name
)
SELECT
    ticker,
    security_name,
    ROUND(mean_return, 4) as mean_daily_return,
    ROUND(daily_sigma, 4) as daily_sigma,
    ROUND(annual_sigma, 4) as annual_sigma,
    ROUND(mean_return - (1.645 * daily_sigma), 4) as var_95_daily,
    ROUND((mean_return * 252) - (1.645 * annual_sigma), 4) as var_95_annual,
    ROUND(worst_case_daily, 4) as historical_worst_day,
    ROUND(best_case_daily, 4) as historical_best_day
FROM returns_analysis
ORDER BY annual_sigma DESC;
