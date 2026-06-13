-- =====================================================
-- QUESTION 4: REBALANCING RECOMMENDATIONS
-- =====================================================
-- Purpose: Provide buy/sell recommendations based on:
--   1. Sharpe Ratio (return per unit of risk)
--   2. Current holdings vs optimal allocation
--   3. Correlation benefits for diversification
--   4. Risk-adjusted returns

-- =====================================================
-- QUERY 4.1: Sharpe Ratio Analysis for Each Security
-- =====================================================
-- Sharpe Ratio = (Expected Return - Risk-Free Rate) / Volatility
-- Using current 2% as risk-free rate
WITH security_metrics AS (
    SELECT
        sml.ticker,
        sml.security_name,
        sml.major_asset_class,
        hd.portfolio_weight as current_weight,
        AVG(daily_return_pct) * 252 as annualized_return,
        STDDEV_POP(daily_return_pct) * SQRT(252) as annual_volatility,
        hd.market_value_million
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
    GROUP BY sml.ticker, sml.security_name, sml.major_asset_class, hd.portfolio_weight, hd.market_value_million
)
SELECT
    ticker,
    security_name,
    major_asset_class,
    ROUND(current_weight, 2) as current_allocation_pct,
    ROUND(market_value_million, 2) as current_market_value_mm,
    ROUND(annualized_return, 2) as annual_return_pct,
    ROUND(annual_volatility, 2) as annual_volatility_sigma,
    ROUND((annualized_return - 2) / annual_volatility, 4) as sharpe_ratio,
    CASE
        WHEN (annualized_return - 2) / annual_volatility > 0.5 THEN 'Attractive - HOLD/BUY'
        WHEN (annualized_return - 2) / annual_volatility > 0.2 THEN 'Moderate - HOLD'
        ELSE 'Underperforming - CONSIDER SELLING'
    END as recommendation
FROM security_metrics
ORDER BY sharpe_ratio DESC;

-- =====================================================
-- QUERY 4.2: Current vs Benchmark Allocation Analysis
-- =====================================================
-- Compare current allocation to optimal allocation based on risk/return
WITH allocation_analysis AS (
    SELECT
        sml.ticker,
        sml.security_name,
        sml.major_asset_class,
        COALESCE(hd.portfolio_weight, 0) as current_weight,
        COALESCE(hd.market_value_million, 0) as current_market_value,
        ROUND(STDDEV_POP(daily_return_pct) * SQRT(252), 4) as annual_volatility
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
    GROUP BY sml.ticker, sml.security_name, sml.major_asset_class, hd.portfolio_weight, hd.market_value_million
)
SELECT
    ticker,
    security_name,
    major_asset_class,
    ROUND(current_weight, 2) as current_allocation_pct,
    ROUND(current_market_value, 2) as current_market_value_mm,
    ROUND(annual_volatility, 2) as volatility,
    ROUND(
        CASE
            WHEN annual_volatility > 25 THEN 10
            WHEN annual_volatility > 15 THEN 15
            WHEN annual_volatility > 10 THEN 20
            ELSE 25
        END,
        2
    ) as optimal_allocation_pct,
    ROUND(
        CASE
            WHEN annual_volatility > 25 THEN 10
            WHEN annual_volatility > 15 THEN 15
            WHEN annual_volatility > 10 THEN 20
            ELSE 25
        END - current_weight,
        2
    ) as allocation_adjustment_pct,
    ROUND(
        95 * (
            CASE
                WHEN annual_volatility > 25 THEN 10
                WHEN annual_volatility > 15 THEN 15
                WHEN annual_volatility > 10 THEN 20
                ELSE 25
            END - current_weight
        ) / 100,
        2
    ) as adjustment_value_millions,
    CASE
        WHEN (CASE
            WHEN annual_volatility > 25 THEN 10
            WHEN annual_volatility > 15 THEN 15
            WHEN annual_volatility > 10 THEN 20
            ELSE 25
        END) > current_weight THEN 'BUY/INCREASE'
        WHEN (CASE
            WHEN annual_volatility > 25 THEN 10
            WHEN annual_volatility > 15 THEN 15
            WHEN annual_volatility > 10 THEN 20
            ELSE 25
        END) < current_weight THEN 'SELL/REDUCE'
        ELSE 'HOLD'
    END as action
FROM allocation_analysis
ORDER BY major_asset_class, ticker;

-- =====================================================
-- QUERY 4.3: Asset Class Concentration Risk
-- =====================================================
SELECT
    sml.major_asset_class,
    COUNT(DISTINCT sml.ticker) as num_holdings,
    ROUND(SUM(hd.portfolio_weight), 2) as total_class_allocation_pct,
    ROUND(SUM(hd.market_value_million), 2) as total_class_market_value_mm,
    CASE
        WHEN SUM(hd.portfolio_weight) > 40 THEN 'HIGH CONCENTRATION - Consider Diversifying'
        WHEN SUM(hd.portfolio_weight) > 25 THEN 'MODERATE CONCENTRATION - Monitor'
        ELSE 'WELL DIVERSIFIED'
    END as diversification_status
FROM security_masterlist sml
LEFT JOIN holdings_dim hd ON sml.ticker = hd.ticker AND hd.account_id = 1001
GROUP BY sml.major_asset_class
ORDER BY total_class_allocation_pct DESC;

-- =====================================================
-- QUERY 4.4: Sector Rotation Opportunities
-- =====================================================
-- Identify underperforming and outperforming sectors
WITH sector_performance AS (
    SELECT
        sml.major_asset_class,
        sml.ticker,
        sml.security_name,
        ROUND(((end_price.adjusted_close - start_price.adjusted_close) / start_price.adjusted_close) * 100, 2) as return_12m,
        ROUND(STDDEV_POP(daily_returns.daily_return_pct) * SQRT(252), 2) as volatility_12m
    FROM security_masterlist sml
    LEFT JOIN (
        SELECT ticker, adjusted_close
        FROM pricing_daily
        WHERE price_date = (
            SELECT MAX(price_date)
            FROM pricing_daily pd2
            WHERE pd2.ticker = pricing_daily.ticker
            AND pd2.price_date <= CURDATE()
        )
    ) end_price ON sml.ticker = end_price.ticker
    LEFT JOIN (
        SELECT ticker, adjusted_close
        FROM pricing_daily
        WHERE price_date = (
            SELECT MIN(price_date)
            FROM pricing_daily pd3
            WHERE pd3.ticker = pricing_daily.ticker
            AND pd3.price_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
        )
    ) start_price ON sml.ticker = start_price.ticker
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
    ) daily_returns ON sml.ticker = daily_returns.ticker
    WHERE daily_returns.daily_return_pct IS NOT NULL
    GROUP BY sml.major_asset_class, sml.ticker, sml.security_name, end_price.adjusted_close, start_price.adjusted_close
)
SELECT
    major_asset_class,
    ticker,
    security_name,
    return_12m as sector_return_12m,
    volatility_12m,
    ROUND(return_12m / volatility_12m, 4) as return_per_risk,
    CASE
        WHEN return_12m > 15 AND volatility_12m < 20 THEN 'STRONG PERFORMER - INCREASE'
        WHEN return_12m < -5 THEN 'UNDERPERFORMER - REDUCE'
        ELSE 'NEUTRAL - MONITOR'
    END as sector_action
FROM sector_performance
WHERE return_12m IS NOT NULL AND volatility_12m IS NOT NULL
ORDER BY major_asset_class, return_per_risk DESC;

-- =====================================================
-- QUERY 4.5: Diversification Score and Recommendations
-- =====================================================
-- Calculate diversification benefits and complementary positions
SELECT
    'Portfolio Diversification Assessment' as analysis_type,
    COUNT(DISTINCT major_asset_class) as num_asset_classes,
    COUNT(DISTINCT ticker) as num_securities,
    ROUND(SUM(portfolio_weight), 2) as total_allocation,
    CASE
        WHEN COUNT(DISTINCT major_asset_class) >= 4 AND COUNT(DISTINCT ticker) >= 5 THEN 'WELL DIVERSIFIED - Hold Current Structure'
        WHEN COUNT(DISTINCT major_asset_class) >= 3 THEN 'MODERATELY DIVERSIFIED - Consider Adding Commodities or Alternatives'
        ELSE 'INSUFFICIENT DIVERSIFICATION - Add Complementary Assets'
    END as diversification_recommendation,
    'Key Recommendations:
    1. EQUITY (Tech+Large Cap): IXN (17.5%) + QQQ (22.1%) = 39.6% - Consider reducing if risk tolerance decreases
    2. FIXED INCOME: IEF (28.5%) - Good defensive positioning, provides stability
    3. COMMODITIES: GLD (23%) - Excellent hedge against inflation and equity downturns
    4. REAL ESTATE: VNQ (8.9%) - Underweight real assets, consider increasing for diversification
    5. Portfolio shows strong diversification with exposure to equities, bonds, commodities, and real estate' as strategic_recommendation
FROM holdings_dim hd
JOIN security_masterlist sml ON hd.ticker = sml.ticker
WHERE hd.account_id = 1001
GROUP BY hd.account_id;
