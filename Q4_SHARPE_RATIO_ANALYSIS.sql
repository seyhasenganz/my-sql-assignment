-- ===================================
-- QUESTION 4: SHARPE RATIO ANALYSIS
-- ===================================
-- Calculate risk-adjusted returns and make buy/sell recommendations
-- Based on REAL data from Q1-Q3 analysis

USE invest_portfolio;

-- ===================================
-- Step 1: Calculate daily returns (12-month window)
-- ===================================
WITH daily_returns AS (
    SELECT
        ticker,
        ROUND(((value - LAG(value) OVER (PARTITION BY ticker ORDER BY date)) /
               LAG(value) OVER (PARTITION BY ticker ORDER BY date)) * 100, 4) as daily_return
    FROM pricing_daily
    WHERE price_type = 'Adj Close'
    AND date >= DATE_SUB((SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close'), INTERVAL 12 MONTH)
)

-- ===================================
-- Step 2: Calculate Sharpe Ratio for each security
-- ===================================
-- Formula: Sharpe = (Expected Annual Return - Risk-Free Rate) / Annual Volatility
-- Risk-Free Rate = 2% (US Treasury baseline)
-- ===================================

SELECT
    s.ticker,
    s.security_name,
    h.portfolio_weight as current_allocation,

    -- Expected Annual Return
    ROUND(AVG(dr.daily_return) * 252, 2) as expected_annual_return,

    -- Annual Volatility (Sigma)
    ROUND(STDDEV_POP(dr.daily_return) * SQRT(252), 2) as annual_volatility,

    -- Sharpe Ratio
    ROUND((AVG(dr.daily_return) * 252 - 2) / (STDDEV_POP(dr.daily_return) * SQRT(252)), 4) as sharpe_ratio,

    -- Recommendation based on Sharpe Ratio
    CASE
        WHEN (AVG(dr.daily_return) * 252 - 2) / (STDDEV_POP(dr.daily_return) * SQRT(252)) > 0.8 THEN 'STRONG BUY'
        WHEN (AVG(dr.daily_return) * 252 - 2) / (STDDEV_POP(dr.daily_return) * SQRT(252)) > 0.5 THEN 'BUY'
        WHEN (AVG(dr.daily_return) * 252 - 2) / (STDDEV_POP(dr.daily_return) * SQRT(252)) > 0.2 THEN 'HOLD'
        ELSE 'SELL'
    END as recommendation

FROM daily_returns dr
JOIN security_masterlist s ON dr.ticker = s.ticker
LEFT JOIN holdings_dim h ON s.ticker = h.ticker AND h.account_id = 1001

WHERE dr.daily_return IS NOT NULL

GROUP BY
    s.ticker,
    s.security_name,
    h.portfolio_weight

ORDER BY sharpe_ratio DESC;

-- ===================================
-- EXPLANATION
-- ===================================
/*
SHARPE RATIO INTERPRETATION:

Sharpe Ratio = (Annual Return - Risk-Free Rate) / Annual Volatility

What it means:
- Higher Sharpe = Better risk-adjusted return
- For every 1% of risk (volatility), how much excess return do you earn?
- Compares "bang for buck" - return per unit of risk

Recommendation Thresholds:
- Sharpe > 0.8  : STRONG BUY (excellent risk-adjusted return)
- Sharpe > 0.5  : BUY (good risk-adjusted return)
- Sharpe > 0.2  : HOLD (acceptable risk-adjusted return)
- Sharpe ≤ 0.2  : SELL (poor risk-adjusted return)

Example Calculation:
For IXN with:
  - Expected Annual Return: 34.51%
  - Annual Volatility: 28.60%
  - Sharpe = (34.51% - 2%) / 28.60% = 32.51% / 28.60% = 1.137

Interpretation: For every 1% of volatility, you earn 1.137% excess return
This is EXCELLENT - Strong Buy recommendation

For IEF with:
  - Expected Annual Return: 0.21%
  - Annual Volatility: 4.84%
  - Sharpe = (0.21% - 2%) / 4.84% = -1.79% / 4.84% = -0.370

Interpretation: You're LOSING money after adjusting for risk
This is POOR - Sell recommendation
*/
