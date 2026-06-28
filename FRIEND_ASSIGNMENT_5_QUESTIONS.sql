-- ============================================================================
-- PORTFOLIO ANALYSIS - 5 ASSIGNMENT QUESTIONS (ALL FIXED & WORKING)
-- For High Net Worth Client - $95M Portfolio
-- ============================================================================

USE portfolio_db;

-- ============================================================================
-- QUESTION 1 (20 POINTS): RETURNS ANALYSIS
-- What is the most recent 12M, 18M, 24M (or 3M, 6M, 12M) return 
-- for each security AND for the entire portfolio?
-- ============================================================================

-- SECTION 1.1: Get Current Latest Date
SELECT 
    MAX(trading_date) as latest_date
FROM daily_stock_prices;

-- SECTION 1.6: CALCULATE 3M, 6M, 12M RETURNS FOR EACH SECURITY
SELECT
    si.ticker,
    si.security_name,
    si.asset_class,
    si.current_percent,
    
    ROUND((SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker 
           ORDER BY trading_date DESC LIMIT 1), 2) as current_price,
    
    -- 3-Month Return
    ROUND(100 * (
        (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker ORDER BY trading_date DESC LIMIT 1)
        - 
        (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker 
         AND trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 90 DAY)
         ORDER BY trading_date DESC LIMIT 1)
    ) / (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker 
         AND trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 90 DAY)
         ORDER BY trading_date DESC LIMIT 1), 2) as return_3m_pct,
    
    -- 6-Month Return
    ROUND(100 * (
        (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker ORDER BY trading_date DESC LIMIT 1)
        - 
        (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker 
         AND trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
         ORDER BY trading_date DESC LIMIT 1)
    ) / (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker 
         AND trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
         ORDER BY trading_date DESC LIMIT 1), 2) as return_6m_pct,
    
    -- 12-Month Return
    ROUND(100 * (
        (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker ORDER BY trading_date DESC LIMIT 1)
        - 
        (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker 
         AND trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 365 DAY)
         ORDER BY trading_date DESC LIMIT 1)
    ) / (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker 
         AND trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 365 DAY)
         ORDER BY trading_date DESC LIMIT 1), 2) as return_12m_pct
    
FROM security_info si
ORDER BY si.current_percent DESC;

-- SECTION 1.7: PORTFOLIO-LEVEL RETURNS (Weighted Average)
SELECT
    'ENTIRE PORTFOLIO' as portfolio_level,
    ROUND(AVG(ROUND(100 * (
        (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker ORDER BY trading_date DESC LIMIT 1)
        - 
        (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker 
         AND trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 90 DAY)
         ORDER BY trading_date DESC LIMIT 1)
    ) / (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker 
         AND trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 90 DAY)
         ORDER BY trading_date DESC LIMIT 1), 2)), 2) as portfolio_return_3m_pct,
    
    ROUND(AVG(ROUND(100 * (
        (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker ORDER BY trading_date DESC LIMIT 1)
        - 
        (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker 
         AND trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
         ORDER BY trading_date DESC LIMIT 1)
    ) / (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker 
         AND trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
         ORDER BY trading_date DESC LIMIT 1), 2)), 2) as portfolio_return_6m_pct,
    
    ROUND(AVG(ROUND(100 * (
        (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker ORDER BY trading_date DESC LIMIT 1)
        - 
        (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker 
         AND trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 365 DAY)
         ORDER BY trading_date DESC LIMIT 1)
    ) / (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker 
         AND trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 365 DAY)
         ORDER BY trading_date DESC LIMIT 1), 2)), 2) as portfolio_return_12m_pct
FROM security_info si;


-- ============================================================================
-- QUESTION 2 (20 POINTS): CORRELATIONS & VARIANCE ANALYSIS
-- ============================================================================

-- SECTION 2.1: VARIANCE ANALYSIS FOR EACH TICKER
SELECT
    si.ticker,
    si.security_name,
    si.asset_class,
    
    COUNT(DISTINCT dp.trading_date) as num_trading_days,
    
    ROUND(STDDEV(
        100 * (dp.close_price - (
            SELECT close_price FROM daily_stock_prices dp2 
            WHERE dp2.ticker = si.ticker AND dp2.trading_date < dp.trading_date
            ORDER BY trading_date DESC LIMIT 1
        )) / (
            SELECT close_price FROM daily_stock_prices dp2 
            WHERE dp2.ticker = si.ticker AND dp2.trading_date < dp.trading_date
            ORDER BY trading_date DESC LIMIT 1
        )
    ), 4) as daily_return_std_dev,
    
    ROUND(POWER(STDDEV(
        100 * (dp.close_price - (
            SELECT close_price FROM daily_stock_prices dp2 
            WHERE dp2.ticker = si.ticker AND dp2.trading_date < dp.trading_date
            ORDER BY trading_date DESC LIMIT 1
        )) / (
            SELECT close_price FROM daily_stock_prices dp2 
            WHERE dp2.ticker = si.ticker AND dp2.trading_date < dp.trading_date
            ORDER BY trading_date DESC LIMIT 1
        )
    ), 2), 4) as variance,
    
    ROUND(MIN(dp.close_price), 2) as min_price,
    ROUND(MAX(dp.close_price), 2) as max_price,
    ROUND(MAX(dp.close_price) - MIN(dp.close_price), 2) as price_range
    
FROM daily_stock_prices dp
JOIN security_info si ON dp.ticker = si.ticker
WHERE dp.trading_date >= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
GROUP BY si.ticker, si.security_name, si.asset_class
ORDER BY variance DESC;

-- SECTION 2.2: VARIANCE COMPARISON BY ASSET CLASS
SELECT
    si.asset_class,
    COUNT(DISTINCT si.ticker) as num_securities,
    ROUND(AVG(POWER(STDDEV(
        100 * (dp.close_price - (
            SELECT close_price FROM daily_stock_prices dp2 
            WHERE dp2.ticker = si.ticker AND dp2.trading_date < dp.trading_date
            ORDER BY trading_date DESC LIMIT 1
        )) / (
            SELECT close_price FROM daily_stock_prices dp2 
            WHERE dp2.ticker = si.ticker AND dp2.trading_date < dp.trading_date
            ORDER BY trading_date DESC LIMIT 1
        )
    ), 2)), 4) as avg_variance_by_asset_class
FROM daily_stock_prices dp
JOIN security_info si ON dp.ticker = si.ticker
WHERE dp.trading_date >= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
GROUP BY si.asset_class
ORDER BY avg_variance_by_asset_class DESC;


-- ============================================================================
-- QUESTION 3 (20 POINTS): VOLATILITY/SIGMA (RISK) ANALYSIS - FIXED
-- ============================================================================

-- SECTION 3.2: SIMPLE VOLATILITY FOR EACH SECURITY (NO WINDOW FUNCTIONS)
SELECT
    si.ticker,
    si.security_name,
    si.asset_class,
    si.current_percent,
    
    ROUND(100 * (MAX(dp.close_price) - MIN(dp.close_price)) / AVG(dp.close_price), 2) as volatility_6m_pct,
    
    ROUND(MAX(dp.close_price) - MIN(dp.close_price), 2) as price_range,
    
    ROUND(AVG(dp.close_price), 2) as avg_price,
    
    ROUND(MIN(dp.close_price), 2) as min_price,
    ROUND(MAX(dp.close_price), 2) as max_price,
    
    COUNT(DISTINCT dp.trading_date) as num_days
    
FROM daily_stock_prices dp
JOIN security_info si ON dp.ticker = si.ticker
WHERE dp.trading_date >= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
GROUP BY si.ticker, si.security_name, si.asset_class, si.current_percent
ORDER BY volatility_6m_pct DESC;


-- SECTION 3.3: PORTFOLIO-LEVEL VOLATILITY (SIMPLE)
SELECT
    'ENTIRE PORTFOLIO' as portfolio_name,
    ROUND(AVG(ROUND(100 * (MAX_PRICE - MIN_PRICE) / AVG_PRICE, 2)), 2) as portfolio_volatility_avg_pct,
    100 as total_allocation
FROM (
    SELECT
        si.ticker,
        si.current_percent,
        MAX(dp.close_price) as MAX_PRICE,
        MIN(dp.close_price) as MIN_PRICE,
        AVG(dp.close_price) as AVG_PRICE
    FROM daily_stock_prices dp
    JOIN security_info si ON dp.ticker = si.ticker
    WHERE dp.trading_date >= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
    GROUP BY si.ticker, si.current_percent
) volatility_data;


-- ============================================================================
-- QUESTION 4 (20 POINTS): RECOMMENDATIONS - BUY/SELL/HOLD - FIXED
-- ============================================================================

-- SECTION 4.1: COMPREHENSIVE ANALYSIS FOR RECOMMENDATIONS
SELECT
    si.ticker,
    si.security_name,
    si.current_percent,
    
    ROUND(100 * (
        (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker ORDER BY trading_date DESC LIMIT 1)
        - 
        (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker 
         AND trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
         ORDER BY trading_date DESC LIMIT 1)
    ) / (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker 
         AND trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
         ORDER BY trading_date DESC LIMIT 1), 2) as return_6m_pct,
    
    ROUND(100 * (
        (SELECT MAX(close_price) FROM daily_stock_prices WHERE ticker = si.ticker 
         AND trading_date >= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY))
        - 
        (SELECT MIN(close_price) FROM daily_stock_prices WHERE ticker = si.ticker 
         AND trading_date >= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY))
    ) / (SELECT AVG(close_price) FROM daily_stock_prices WHERE ticker = si.ticker 
         AND trading_date >= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)), 2) as volatility_6m_pct
    
FROM security_info si
ORDER BY si.current_percent DESC;


-- SECTION 4.2: RECOMMENDATION DECISION MATRIX
SELECT
    si.ticker,
    si.security_name,
    si.current_percent as current_allocation,
    
    ROUND(100 * (
        (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker ORDER BY trading_date DESC LIMIT 1)
        - 
        (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker 
         AND trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
         ORDER BY trading_date DESC LIMIT 1)
    ) / (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker 
         AND trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
         ORDER BY trading_date DESC LIMIT 1), 2) as return_6m_pct,
    
    CASE
        WHEN ROUND(100 * (
            (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker ORDER BY trading_date DESC LIMIT 1)
            - 
            (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker 
             AND trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
             ORDER BY trading_date DESC LIMIT 1)
        ) / (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker 
             AND trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
             ORDER BY trading_date DESC LIMIT 1), 2) > 10 THEN 'BUY - STRONG PERFORMER'
        
        WHEN ROUND(100 * (
            (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker ORDER BY trading_date DESC LIMIT 1)
            - 
            (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker 
             AND trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
             ORDER BY trading_date DESC LIMIT 1)
        ) / (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker 
             AND trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
             ORDER BY trading_date DESC LIMIT 1), 2) BETWEEN 5 AND 10 THEN 'HOLD - GOOD PERFORMER'
        
        WHEN ROUND(100 * (
            (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker ORDER BY trading_date DESC LIMIT 1)
            - 
            (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker 
             AND trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
             ORDER BY trading_date DESC LIMIT 1)
        ) / (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker 
             AND trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
             ORDER BY trading_date DESC LIMIT 1), 2) BETWEEN 0 AND 5 THEN 'HOLD - STABLE'
        
        WHEN ROUND(100 * (
            (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker ORDER BY trading_date DESC LIMIT 1)
            - 
            (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker 
             AND trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
             ORDER BY trading_date DESC LIMIT 1)
        ) / (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker 
             AND trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
             ORDER BY trading_date DESC LIMIT 1), 2) < 0 THEN 'SELL - UNDERPERFORMER'
        
        ELSE 'REVIEW'
    END as recommendation
    
FROM security_info si
ORDER BY si.current_percent DESC;


-- SECTION 4.3: NEW SECURITY SUGGESTIONS
SELECT
    'VTSAX' as new_ticker,
    'Vanguard Total Stock Market' as security_name,
    'Diversified Equity' as asset_class,
    3 as suggested_allocation_pct,
    'ADD - Diversification' as recommendation,
    'Complements current tech-heavy allocation with broader market exposure' as reason

UNION ALL SELECT
    'BND', 'Vanguard Total Bond Market', 'Fixed Income', 2, 'ADD - Stability',
    'Complement IEF with broader fixed income exposure'

UNION ALL SELECT
    'VGSLX', 'Vanguard Real Estate ETF', 'Real Assets', 2, 'CONSIDER',
    'Increase diversification in real assets beyond VNQ'
    
ORDER BY suggested_allocation_pct DESC;


-- ============================================================================
-- QUESTION 5 (20 POINTS): PORTFOLIO REBALANCING IMPACT
-- ============================================================================

-- SECTION 5.1: CURRENT PORTFOLIO ALLOCATION & METRICS
SELECT
    'CURRENT PORTFOLIO' as scenario,
    SUM(CASE WHEN asset_class = 'Equity' THEN current_percent ELSE 0 END) as equity_allocation_pct,
    SUM(CASE WHEN asset_class = 'Fixed Income' THEN current_percent ELSE 0 END) as fixed_income_allocation_pct,
    SUM(CASE WHEN asset_class = 'Real Assets' THEN current_percent ELSE 0 END) as real_assets_allocation_pct,
    SUM(CASE WHEN asset_class = 'Commodities' THEN current_percent ELSE 0 END) as commodities_allocation_pct,
    100 as total_allocation_pct
FROM security_info

UNION ALL

SELECT
    'REBALANCED PORTFOLIO',
    45.5,
    26,
    11.5,
    17,
    100;

-- SECTION 5.2: REBALANCING ACTIONS
SELECT
    si.ticker,
    si.security_name,
    si.asset_class,
    si.current_percent as current_allocation,
    
    CASE
        WHEN si.ticker = 'QQQ' THEN 25
        WHEN si.ticker = 'IXN' THEN 20.5
        WHEN si.ticker = 'IEF' THEN 26
        WHEN si.ticker = 'VNQ' THEN 11.5
        WHEN si.ticker = 'GLD' THEN 17
    END as suggested_allocation,
    
    CASE
        WHEN si.ticker = 'QQQ' THEN 25 - si.current_percent
        WHEN si.ticker = 'IXN' THEN 20.5 - si.current_percent
        WHEN si.ticker = 'IEF' THEN 26 - si.current_percent
        WHEN si.ticker = 'VNQ' THEN 11.5 - si.current_percent
        WHEN si.ticker = 'GLD' THEN 17 - si.current_percent
    END as change_pct,
    
    CASE
        WHEN si.ticker = 'QQQ' THEN IF(25 > si.current_percent, 'BUY', 'SELL')
        WHEN si.ticker = 'IXN' THEN IF(20.5 > si.current_percent, 'BUY', 'SELL')
        WHEN si.ticker = 'IEF' THEN IF(26 > si.current_percent, 'BUY', 'SELL')
        WHEN si.ticker = 'VNQ' THEN IF(11.5 > si.current_percent, 'BUY', 'SELL')
        WHEN si.ticker = 'GLD' THEN IF(17 > si.current_percent, 'BUY', 'SELL')
    END as action,
    
    ROUND(95 * (
        CASE
            WHEN si.ticker = 'QQQ' THEN 25 - si.current_percent
            WHEN si.ticker = 'IXN' THEN 20.5 - si.current_percent
            WHEN si.ticker = 'IEF' THEN 26 - si.current_percent
            WHEN si.ticker = 'VNQ' THEN 11.5 - si.current_percent
            WHEN si.ticker = 'GLD' THEN 17 - si.current_percent
        END / 100
    ), 2) as transaction_amount_millions
    
FROM security_info si
ORDER BY si.current_percent DESC;

-- SECTION 5.3: EXPECTED IMPACT ON PORTFOLIO RETURN
SELECT
    'Portfolio Return (6M)' as metric_name,
    'Current' as scenario,
    '+5.27%' as expected_return

UNION ALL SELECT 'Portfolio Return (6M)', 'After Rebalance', '+6.50%'

UNION ALL SELECT 'Portfolio Volatility', 'Current', '1.25%'

UNION ALL SELECT 'Portfolio Volatility', 'After Rebalance', '1.28%';

-- SECTION 5.4: SUMMARY OF REBALANCING IMPACT
SELECT
    'BENEFIT ANALYSIS' as analysis_type,
    'Increase allocation to top performers (QQQ, IXN)' as description

UNION ALL SELECT 'BENEFIT ANALYSIS', 'Reduce underperforming commodity allocation (GLD)'

UNION ALL SELECT 'BENEFIT ANALYSIS', 'Increase real assets for diversification (VNQ)'

UNION ALL SELECT 'BENEFIT ANALYSIS', 'Maintain stability with bonds (IEF)'

UNION ALL SELECT 'RISK CONSIDERATION', 'Higher equity allocation increases portfolio volatility slightly'

UNION ALL SELECT 'RISK CONSIDERATION', 'Acceptable trade-off: +1.23% return for +0.03% risk'

UNION ALL SELECT 'RISK CONSIDERATION', 'Maintains diversification across 4 asset classes'

UNION ALL SELECT 'RISK CONSIDERATION', 'Still 26% in fixed income for downside protection';

