-- ============================================================================
-- FIXED Q3 AND Q4 - NO WINDOW FUNCTION ERRORS
-- ============================================================================

USE portfolio_db;

-- ============================================================================
-- QUESTION 3 (20 POINTS): VOLATILITY/SIGMA - FIXED VERSION
-- ============================================================================

-- SECTION 3.2A: SIMPLE VOLATILITY FOR EACH SECURITY (NO WINDOW FUNCTIONS)
SELECT
    si.ticker,
    si.security_name,
    si.asset_class,
    si.current_percent,
    
    -- Simple Volatility = (Max - Min) / Average * 100
    ROUND(100 * (MAX(dp.close_price) - MIN(dp.close_price)) / AVG(dp.close_price), 2) as volatility_6m_pct,
    
    -- Price Range
    ROUND(MAX(dp.close_price) - MIN(dp.close_price), 2) as price_range,
    
    -- Average Price
    ROUND(AVG(dp.close_price), 2) as avg_price,
    
    ROUND(MIN(dp.close_price), 2) as min_price,
    ROUND(MAX(dp.close_price), 2) as max_price,
    
    -- Data points
    COUNT(DISTINCT dp.trading_date) as num_days
    
FROM daily_stock_prices dp
JOIN security_info si ON dp.ticker = si.ticker
WHERE dp.trading_date >= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
GROUP BY si.ticker, si.security_name, si.asset_class, si.current_percent
ORDER BY volatility_6m_pct DESC;


-- SECTION 3.3A: PORTFOLIO-LEVEL VOLATILITY (SIMPLE - NO WINDOW FUNCTIONS)
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
-- QUESTION 4 (20 POINTS): RECOMMENDATIONS - FIXED VERSION
-- ============================================================================

-- SECTION 4.1A: COMPREHENSIVE ANALYSIS FOR RECOMMENDATIONS (SIMPLIFIED)
SELECT
    si.ticker,
    si.security_name,
    si.asset_class,
    si.current_percent as current_allocation_pct,
    
    -- Returns (from Q1)
    ROUND(100 * (
        (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker ORDER BY trading_date DESC LIMIT 1)
        - 
        (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker 
         AND trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
         ORDER BY trading_date DESC LIMIT 1)
    ) / (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker 
         AND trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
         ORDER BY trading_date DESC LIMIT 1), 2) as return_6m_pct,
    
    -- Volatility (from Q3)
    ROUND(100 * (
        (SELECT MAX(close_price) FROM daily_stock_prices WHERE ticker = si.ticker 
         AND trading_date >= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY))
        - 
        (SELECT MIN(close_price) FROM daily_stock_prices WHERE ticker = si.ticker 
         AND trading_date >= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY))
    ) / (SELECT AVG(close_price) FROM daily_stock_prices WHERE ticker = si.ticker 
         AND trading_date >= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)), 2) as volatility_6m_pct
    
FROM security_info si
ORDER BY current_allocation_pct DESC;


-- SECTION 4.2A: RECOMMENDATION DECISION MATRIX (SIMPLIFIED)
SELECT
    si.ticker,
    si.security_name,
    si.current_percent as current_allocation,
    
    -- Get return value
    ROUND(100 * (
        (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker ORDER BY trading_date DESC LIMIT 1)
        - 
        (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker 
         AND trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
         ORDER BY trading_date DESC LIMIT 1)
    ) / (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker 
         AND trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
         ORDER BY trading_date DESC LIMIT 1), 2) as return_6m_pct,
    
    -- Decision Logic
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


-- SECTION 4.3A: NEW SECURITY SUGGESTIONS (UNCHANGED - Already Works)
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

