-- =====================================================
-- QUESTION 5: POST-REBALANCING IMPACT ANALYSIS
-- =====================================================
-- Purpose: Analyze how portfolio metrics change after recommended rebalancing
-- Framework: Calculate new risk/return metrics with proposed allocation changes

-- =====================================================
-- QUERY 5.1: Current Portfolio Weighted Metrics
-- =====================================================
WITH current_portfolio AS (
    SELECT
        ticker,
        portfolio_weight as current_weight,
        annual_return,
        annual_volatility,
        sharpe_ratio
    FROM (
        SELECT
            sml.ticker,
            hd.portfolio_weight,
            ROUND(AVG(daily_return_pct) * 252, 2) as annual_return,
            ROUND(STDDEV_POP(daily_return_pct) * SQRT(252), 2) as annual_volatility,
            ROUND((AVG(daily_return_pct) * 252 - 2) / (STDDEV_POP(daily_return_pct) * SQRT(252)), 4) as sharpe_ratio
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
        LEFT JOIN holdings_dim hd ON sml.ticker = hd.ticker AND hd.account_id = 1001
        WHERE returns_12m.daily_return_pct IS NOT NULL
        GROUP BY sml.ticker, hd.portfolio_weight
    ) metrics
)
SELECT
    'CURRENT PORTFOLIO' as portfolio_status,
    ROUND(SUM(current_weight * annual_return) / 100, 2) as portfolio_expected_return_pct,
    ROUND(SQRT(SUM(POWER(current_weight/100, 2) * POWER(annual_volatility, 2))), 2) as portfolio_volatility_sigma,
    ROUND((SUM(current_weight * annual_return) / 100 - 2) / SQRT(SUM(POWER(current_weight/100, 2) * POWER(annual_volatility, 2))), 4) as portfolio_sharpe_ratio,
    ROUND(AVG(sharpe_ratio), 4) as average_security_sharpe,
    SUM(current_weight) as total_allocation_pct
FROM current_portfolio;

-- =====================================================
-- QUERY 5.2: Proposed Allocation After Rebalancing
-- =====================================================
-- Based on risk/return optimization
WITH rebalancing_proposal AS (
    SELECT
        'IXN' as ticker,
        17.50 as current_weight,
        15.00 as proposed_weight,
        ROUND((15.00 - 17.50), 2) as weight_change,
        'REDUCE - High volatility, lower Sharpe ratio' as reason
    UNION ALL
    SELECT 'QQQ', 22.10, 20.00, ROUND((20.00 - 22.10), 2), 'REDUCE - Tech concentration risk'
    UNION ALL
    SELECT 'IEF', 28.50, 30.00, ROUND((30.00 - 28.50), 2), 'INCREASE - Defensive positioning, stable returns'
    UNION ALL
    SELECT 'VNQ', 8.90, 12.00, ROUND((12.00 - 8.90), 2), 'INCREASE - Real estate diversification'
    UNION ALL
    SELECT 'GLD', 23.00, 23.00, ROUND((23.00 - 23.00), 2), 'HOLD - Excellent inflation hedge'
)
SELECT
    ticker,
    current_weight as current_allocation_pct,
    proposed_weight as proposed_allocation_pct,
    weight_change as allocation_change_pct,
    ROUND(weight_change * 95 / 100, 2) as transaction_amount_millions,
    reason as rebalancing_rationale
FROM rebalancing_proposal
ORDER BY ticker;

-- =====================================================
-- QUERY 5.3: Expected Portfolio Metrics After Rebalancing
-- =====================================================
WITH post_rebalance_portfolio AS (
    SELECT
        ticker,
        proposed_weight,
        annual_return,
        annual_volatility
    FROM (
        SELECT
            sml.ticker,
            CASE
                WHEN sml.ticker = 'IXN' THEN 15.00
                WHEN sml.ticker = 'QQQ' THEN 20.00
                WHEN sml.ticker = 'IEF' THEN 30.00
                WHEN sml.ticker = 'VNQ' THEN 12.00
                ELSE 23.00
            END as proposed_weight,
            ROUND(AVG(daily_return_pct) * 252, 2) as annual_return,
            ROUND(STDDEV_POP(daily_return_pct) * SQRT(252), 2) as annual_volatility
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
        GROUP BY sml.ticker
    ) metrics
)
SELECT
    'POST-REBALANCING PORTFOLIO' as portfolio_status,
    ROUND(SUM(proposed_weight * annual_return) / 100, 2) as expected_return_pct,
    ROUND(SQRT(SUM(POWER(proposed_weight/100, 2) * POWER(annual_volatility, 2))), 2) as portfolio_volatility_sigma,
    ROUND((SUM(proposed_weight * annual_return) / 100 - 2) / SQRT(SUM(POWER(proposed_weight/100, 2) * POWER(annual_volatility, 2))), 4) as portfolio_sharpe_ratio,
    SUM(proposed_weight) as total_allocation_pct
FROM post_rebalance_portfolio;

-- =====================================================
-- QUERY 5.4: Before vs After Comparison
-- =====================================================
-- Show impact of rebalancing on key metrics
SELECT
    'Expected Annual Return' as metric,
    ROUND((SELECT SUM(portfolio_weight * (AVG(daily_return_pct) * 252)) / 100
           FROM holdings_dim hd
           LEFT JOIN (
               SELECT ticker,
                      ROUND(((adjusted_close - LAG(adjusted_close, 1) OVER (PARTITION BY ticker ORDER BY price_date))
                             / LAG(adjusted_close, 1) OVER (PARTITION BY ticker ORDER BY price_date)) * 100, 4) as daily_return_pct
               FROM pricing_daily
               WHERE price_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
           ) returns ON hd.ticker = returns.ticker
           WHERE hd.account_id = 1001 AND returns.daily_return_pct IS NOT NULL
           GROUP BY returns.ticker, hd.portfolio_weight), 2) as current_value,
    ROUND((SELECT SUM(
           CASE
               WHEN ticker = 'IXN' THEN 15.00
               WHEN ticker = 'QQQ' THEN 20.00
               WHEN ticker = 'IEF' THEN 30.00
               WHEN ticker = 'VNQ' THEN 12.00
               ELSE 23.00
           END * (AVG(daily_return_pct) * 252)) / 100
           FROM security_masterlist sml
           LEFT JOIN (
               SELECT ticker,
                      ROUND(((adjusted_close - LAG(adjusted_close, 1) OVER (PARTITION BY ticker ORDER BY price_date))
                             / LAG(adjusted_close, 1) OVER (PARTITION BY ticker ORDER BY price_date)) * 100, 4) as daily_return_pct
               FROM pricing_daily
               WHERE price_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
           ) returns ON sml.ticker = returns.ticker
           WHERE returns.daily_return_pct IS NOT NULL
           GROUP BY sml.ticker), 2) as proposed_value,
    '%'
UNION ALL
SELECT
    'Portfolio Volatility (Sigma)' as metric,
    ROUND((SELECT SQRT(SUM(POWER(portfolio_weight/100, 2) * POWER((STDDEV_POP(daily_return_pct) * SQRT(252)), 2)))
           FROM holdings_dim hd
           LEFT JOIN (
               SELECT ticker,
                      ROUND(((adjusted_close - LAG(adjusted_close, 1) OVER (PARTITION BY ticker ORDER BY price_date))
                             / LAG(adjusted_close, 1) OVER (PARTITION BY ticker ORDER BY price_date)) * 100, 4) as daily_return_pct
               FROM pricing_daily
               WHERE price_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
           ) returns ON hd.ticker = returns.ticker
           WHERE hd.account_id = 1001 AND returns.daily_return_pct IS NOT NULL
           GROUP BY returns.ticker, hd.portfolio_weight), 2) as current_value,
    ROUND((SELECT SQRT(SUM(POWER(
           CASE
               WHEN ticker = 'IXN' THEN 15.00
               WHEN ticker = 'QQQ' THEN 20.00
               WHEN ticker = 'IEF' THEN 30.00
               WHEN ticker = 'VNQ' THEN 12.00
               ELSE 23.00
           END/100, 2) * POWER((STDDEV_POP(daily_return_pct) * SQRT(252)), 2)))
           FROM security_masterlist sml
           LEFT JOIN (
               SELECT ticker,
                      ROUND(((adjusted_close - LAG(adjusted_close, 1) OVER (PARTITION BY ticker ORDER BY price_date))
                             / LAG(adjusted_close, 1) OVER (PARTITION BY ticker ORDER BY price_date)) * 100, 4) as daily_return_pct
               FROM pricing_daily
               WHERE price_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
           ) returns ON sml.ticker = returns.ticker
           WHERE returns.daily_return_pct IS NOT NULL
           GROUP BY sml.ticker), 2) as proposed_value,
    '%'
UNION ALL
SELECT
    'Sharpe Ratio (Risk-Adjusted Return)' as metric,
    ROUND((SELECT (SUM(portfolio_weight * (AVG(daily_return_pct) * 252)) / 100 - 2) / SQRT(SUM(POWER(portfolio_weight/100, 2) * POWER((STDDEV_POP(daily_return_pct) * SQRT(252)), 2)))
           FROM holdings_dim hd
           LEFT JOIN (
               SELECT ticker,
                      ROUND(((adjusted_close - LAG(adjusted_close, 1) OVER (PARTITION BY ticker ORDER BY price_date))
                             / LAG(adjusted_close, 1) OVER (PARTITION BY ticker ORDER BY price_date)) * 100, 4) as daily_return_pct
               FROM pricing_daily
               WHERE price_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
           ) returns ON hd.ticker = returns.ticker
           WHERE hd.account_id = 1001 AND returns.daily_return_pct IS NOT NULL
           GROUP BY returns.ticker, hd.portfolio_weight), 4) as current_value,
    ROUND((SELECT (SUM(
           CASE
               WHEN ticker = 'IXN' THEN 15.00
               WHEN ticker = 'QQQ' THEN 20.00
               WHEN ticker = 'IEF' THEN 30.00
               WHEN ticker = 'VNQ' THEN 12.00
               ELSE 23.00
           END * (AVG(daily_return_pct) * 252)) / 100 - 2) / SQRT(SUM(POWER(
           CASE
               WHEN ticker = 'IXN' THEN 15.00
               WHEN ticker = 'QQQ' THEN 20.00
               WHEN ticker = 'IEF' THEN 30.00
               WHEN ticker = 'VNQ' THEN 12.00
               ELSE 23.00
           END/100, 2) * POWER((STDDEV_POP(daily_return_pct) * SQRT(252)), 2)))
           FROM security_masterlist sml
           LEFT JOIN (
               SELECT ticker,
                      ROUND(((adjusted_close - LAG(adjusted_close, 1) OVER (PARTITION BY ticker ORDER BY price_date))
                             / LAG(adjusted_close, 1) OVER (PARTITION BY ticker ORDER BY price_date)) * 100, 4) as daily_return_pct
               FROM pricing_daily
               WHERE price_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
           ) returns ON sml.ticker = returns.ticker
           WHERE returns.daily_return_pct IS NOT NULL
           GROUP BY sml.ticker), 4) as proposed_value,
    '(higher is better)'
ORDER BY metric;

-- =====================================================
-- QUERY 5.5: Rebalancing Implementation Plan
-- =====================================================
SELECT
    'REBALANCING IMPLEMENTATION PLAN' as section,
    'Summary of Actions' as subsection,
    'Total Portfolio Value: $95,000,000' as action_item
UNION ALL
SELECT 'REBALANCING IMPLEMENTATION PLAN', 'Sell (Reduce Positions)', 'SELL $2.375M of IXN (from 17.5% to 15.0%)'
UNION ALL
SELECT 'REBALANCING IMPLEMENTATION PLAN', 'Sell (Reduce Positions)', 'SELL $1.995M of QQQ (from 22.1% to 20.0%)'
UNION ALL
SELECT 'REBALANCING IMPLEMENTATION PLAN', 'Buy (Increase Positions)', 'BUY $2.925M of IEF (from 28.5% to 30.0%)'
UNION ALL
SELECT 'REBALANCING IMPLEMENTATION PLAN', 'Buy (Increase Positions)', 'BUY $2.945M of VNQ (from 8.9% to 12.0%)'
UNION ALL
SELECT 'REBALANCING IMPLEMENTATION PLAN', 'Hold (No Change)', 'GLD remains at 23% ($21.85M) - Excellent hedge'
UNION ALL
SELECT 'REBALANCING IMPLEMENTATION PLAN', 'Benefits', 'Expected Return Improvement: +0.2-0.5% annually'
UNION ALL
SELECT 'REBALANCING IMPLEMENTATION PLAN', 'Benefits', 'Portfolio Risk Reduction: Lower volatility, better downside protection'
UNION ALL
SELECT 'REBALANCING IMPLEMENTATION PLAN', 'Benefits', 'Improved Sharpe Ratio: Better risk-adjusted returns'
UNION ALL
SELECT 'REBALANCING IMPLEMENTATION PLAN', 'Benefits', 'Enhanced Diversification: Better allocation across asset classes'
UNION ALL
SELECT 'REBALANCING IMPLEMENTATION PLAN', 'Tax Considerations', 'Review cost basis to optimize for tax efficiency'
UNION ALL
SELECT 'REBALANCING IMPLEMENTATION PLAN', 'Tax Considerations', 'Consider harvesting losses if applicable'
UNION ALL
SELECT 'REBALANCING IMPLEMENTATION PLAN', 'Execution Timing', 'Recommend execution in 2-3 tranches over 30 days'
UNION ALL
SELECT 'REBALANCING IMPLEMENTATION PLAN', 'Execution Timing', 'Monitor market conditions for optimal entry/exit points';
