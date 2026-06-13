-- ===================================
-- QUESTION 3: VOLATILITY (SIGMA) ANALYSIS
-- ===================================
-- Calculate 12-month annualized volatility for each security
--
-- Formula: Sigma = Daily Volatility × √252
--   √252 = square root of trading days per year
--   Converts daily volatility to annualized risk
--
-- Interpretation: If current volatility continues for 12 months,
--                 prices would swing ±sigma%

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
               LAG(value) OVER (PARTITION BY ticker ORDER BY date)) * 100, 4) as daily_return
    FROM pricing_daily
    WHERE price_type = 'Adj Close'
    -- Use 12-month window for annual volatility calculation
    AND date >= DATE_SUB((SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close'), INTERVAL 12 MONTH)
)

-- ===================================
-- STEP 2: Calculate Annualized Volatility
-- ===================================
SELECT
    s.ticker,
    s.security_name,
    s.major_asset_class,
    h.portfolio_weight,

    -- Data quality metrics
    COUNT(DISTINCT dr.date) as trading_days_analyzed,
    COUNT(dr.daily_return) as valid_daily_returns,

    -- Daily volatility (standard deviation of daily returns)
    ROUND(STDDEV_POP(dr.daily_return), 4) as daily_volatility_pct,

    -- Annualized Volatility (SIGMA)
    -- Formula: Daily Volatility × √252 (trading days per year)
    ROUND(STDDEV_POP(dr.daily_return) * SQRT(252), 2) as annual_volatility_sigma,

    -- Risk Level Classification
    CASE
        WHEN STDDEV_POP(dr.daily_return) * SQRT(252) > 25 THEN 'HIGH'
        WHEN STDDEV_POP(dr.daily_return) * SQRT(252) > 15 THEN 'MODERATE'
        ELSE 'LOW'
    END as risk_level,

    -- Return statistics for context
    ROUND(AVG(dr.daily_return), 4) as avg_daily_return,
    ROUND(MIN(dr.daily_return), 2) as worst_day_pct,
    ROUND(MAX(dr.daily_return), 2) as best_day_pct,
    ROUND(MAX(dr.daily_return) - MIN(dr.daily_return), 2) as daily_range_pct

FROM daily_returns dr
LEFT JOIN security_masterlist s ON dr.ticker = s.ticker
LEFT JOIN holdings_dim h ON s.ticker = h.ticker AND h.account_id = 1001

WHERE dr.daily_return IS NOT NULL

GROUP BY
    s.ticker,
    s.security_name,
    s.major_asset_class,
    h.portfolio_weight

ORDER BY
    annual_volatility_sigma DESC;

-- ===================================
-- PORTFOLIO-WIDE WEIGHTED VOLATILITY
-- ===================================
-- Calculate total portfolio volatility using weighted average
-- (This is simplified - doesn't account for correlations)

WITH individual_volatilities AS (
    SELECT
        ticker,
        ROUND(STDDEV_POP(daily_return) * SQRT(252), 2) as annual_volatility_sigma
    FROM (
        SELECT
            ticker,
            ((value - LAG(value) OVER (PARTITION BY ticker ORDER BY date)) /
             LAG(value) OVER (PARTITION BY ticker ORDER BY date)) * 100 as daily_return,
            date
        FROM pricing_daily
        WHERE price_type = 'Adj Close'
        AND date >= DATE_SUB((SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close'), INTERVAL 12 MONTH)
    ) sub
    WHERE daily_return IS NOT NULL
    GROUP BY ticker
),

holdings_with_volatility AS (
    SELECT
        h.ticker,
        h.portfolio_weight,
        iv.annual_volatility_sigma,
        (h.portfolio_weight / 100.0) * iv.annual_volatility_sigma as weighted_volatility
    FROM holdings_dim h
    LEFT JOIN individual_volatilities iv ON h.ticker = iv.ticker
    WHERE h.account_id = 1001
)

SELECT
    'PORTFOLIO TOTAL' as ticker,
    ROUND(SUM(portfolio_weight), 2) as total_weight,
    ROUND(AVG(annual_volatility_sigma), 2) as avg_volatility,
    ROUND(SUM(weighted_volatility), 2) as weighted_portfolio_volatility,
    'COMBINED RISK' as risk_level
FROM holdings_with_volatility;

-- ===================================
-- EXPLANATION OF VOLATILITY CALCULATION
-- ===================================
--
-- SIGMA Definition:
--   σ (Sigma) = Annualized Volatility
--   Formula: Daily Volatility × √252
--   √252 ≈ 15.87 (square root of trading days per year)
--
-- What it means:
--   If volatility = 20%, prices expected to swing ±20% annually
--   Not saying price WILL swing 20%, but CAN based on history
--
-- Risk Level Interpretation:
--   HIGH (>25%):      GLD commodities, volatile sectors
--   MODERATE (15-25%): Tech equities, growth stocks
--   LOW (<15%):        Real estate, bonds, stable assets
--
-- Example Calculations:
--   IEF bonds: Daily volatility 0.296% × 15.87 = 4.70% annual
--   IXN tech: Daily volatility 1.513% × 15.87 = 24.03% annual
--   GLD gold: Daily volatility 1.721% × 15.87 = 27.35% annual
--
-- Portfolio Weighted Volatility:
--   Sum of (Weight × Individual Volatility)
--   Example:
--     GLD: 23.0% × 27.35% = 6.29%
--     IXN: 17.5% × 24.03% = 4.21%
--     QQQ: 22.1% × 17.19% = 3.79%
--     VNQ:  8.9% × 13.53% = 1.20%
--     IEF: 28.5% × 4.70%  = 1.34%
--     ─────────────────────────────
--     Total Portfolio Sigma ≈ 16.83%
--
-- What ±16.83% means for $95M portfolio:
--   Best case:  $95M × 1.1683 = $111.0M (+$16M)
--   Worst case: $95M × 0.8317 = $78.9M (-$16.1M)
--   Annual range: $78.9M to $111.0M
