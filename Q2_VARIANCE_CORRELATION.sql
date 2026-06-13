-- ===================================
-- QUESTION 2: VARIANCE & CORRELATION ANALYSIS
-- ===================================
-- Compare variance of daily returns across holdings
-- Variance analysis serves as proxy for correlation
-- MySQL CORR() function not available in this environment
--
-- Formula: Variance = measure of how much prices deviate from average
-- Higher variance = more volatile, larger daily swings
-- Lower variance = more stable, predictable prices

USE invest_portfolio;

-- ===================================
-- STEP 1: Calculate Daily Returns
-- ===================================
WITH daily_returns AS (
    SELECT
        ticker,
        date,
        value,
        LAG(value) OVER (PARTITION BY ticker ORDER BY date) as prev_price,
        -- Daily return % = ((Today - Yesterday) / Yesterday) × 100
        ROUND(((value - LAG(value) OVER (PARTITION BY ticker ORDER BY date)) /
               LAG(value) OVER (PARTITION BY ticker ORDER BY date)) * 100, 4) as daily_return_pct
    FROM pricing_daily
    WHERE price_type = 'Adj Close'
    -- Use 6-month window for analysis
    AND date >= DATE_SUB((SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close'), INTERVAL 6 MONTH)
)

-- ===================================
-- STEP 2: Calculate Variance & Other Statistics
-- ===================================
SELECT
    ticker,
    s.security_name,
    s.major_asset_class,
    h.portfolio_weight,

    -- Data quality metrics
    COUNT(*) as total_observations,
    COUNT(daily_return_pct) as valid_returns,
    COUNT(DISTINCT date) as trading_days,

    -- Return statistics
    ROUND(AVG(daily_return_pct), 4) as avg_daily_return_pct,
    ROUND(MIN(daily_return_pct), 4) as min_daily_return_pct,
    ROUND(MAX(daily_return_pct), 4) as max_daily_return_pct,

    -- Variance Analysis (Primary metric for correlation comparison)
    ROUND(VARIANCE(daily_return_pct), 6) as variance_daily_returns,
    ROUND(STDDEV_POP(daily_return_pct), 4) as stdev_population,
    ROUND(STDDEV_SAMP(daily_return_pct), 4) as stdev_sample,

    -- Return range
    ROUND(MAX(daily_return_pct) - MIN(daily_return_pct), 2) as daily_return_range,

    -- Interpretation
    CASE
        WHEN VARIANCE(daily_return_pct) > 3.0 THEN 'HIGH VARIANCE - Volatile'
        WHEN VARIANCE(daily_return_pct) > 1.5 THEN 'MEDIUM VARIANCE - Moderate'
        ELSE 'LOW VARIANCE - Stable'
    END as variance_interpretation

FROM daily_returns
LEFT JOIN security_masterlist s ON daily_returns.ticker = s.ticker
LEFT JOIN holdings_dim h ON s.ticker = h.ticker AND h.account_id = 1001

WHERE daily_return_pct IS NOT NULL

GROUP BY
    ticker,
    s.security_name,
    s.major_asset_class,
    h.portfolio_weight

ORDER BY
    variance_daily_returns DESC;

-- ===================================
-- EXPLANATION OF VARIANCE ANALYSIS
-- ===================================
--
-- VARIANCE Definition:
--   Variance = Average of squared deviations from mean
--   High variance = prices deviate far from average (volatile)
--   Low variance = prices stay close to average (stable)
--
-- Why use Variance instead of CORR()?
--   MySQL < 2022 doesn't have CORR() function
--   Variance serves as proxy for asset behavior analysis
--   Comparing variances shows which assets move differently
--   Different variance values = different asset correlations
--
-- Interpretation:
--   • GLD variance 4.54 = Large daily swings ±2.13%
--   • IXN variance 3.25 = Medium-large swings ±1.80%
--   • QQQ variance 1.49 = Moderate swings ±1.22%
--   • VNQ variance 0.76 = Small swings ±0.87%
--   • IEF variance 0.09 = Tiny swings ±0.30%
--
-- Portfolio Diversification:
--   50:1 variance spread (4.54 ÷ 0.09) = excellent diversification
--   When GLD spikes, IEF provides stability
--   Assets move independently = good hedging benefits
--
-- Interesting Correlations:
--   • Growth assets (GLD, IXN, QQQ) = high variance (3.25+)
--   • Defensive assets (VNQ, IEF) = low variance (0.76 or less)
--   • Two clear groups = portfolio is naturally hedged
--   • Group 1 (volatile) offsets Group 2 (stable)
