-- ============================================================================
-- PORTFOLIO ANALYSIS SOLUTION FOR HIGH NET WORTH CLIENT
-- Simple SQL Code for 5 Investment Questions
-- ============================================================================

USE portfolio_db;

-- ============================================================================
-- STEP 1: VERIFY DATA AND PREPARE FOR ANALYSIS
-- ============================================================================

-- Check how much data we have for each ticker
SELECT 
    ticker,
    COUNT(*) as total_days,
    MIN(trading_date) as earliest_date,
    MAX(trading_date) as latest_date,
    DATEDIFF(MAX(trading_date), MIN(trading_date)) as days_span
FROM daily_stock_prices
GROUP BY ticker
ORDER BY ticker;

-- View portfolio composition
SELECT 
    ticker,
    security_name,
    current_percent as allocation_percent,
    asset_class,
    ROUND(portfolio_value, 2) as value_in_millions
FROM security_info
ORDER BY current_percent DESC;


-- ============================================================================
-- QUESTION 1: RETURNS ANALYSIS (12M, 18M, 24M or 3M, 6M, 12M)
-- ============================================================================
-- Calculate returns for different time periods

-- First, get latest price for each ticker
CREATE TEMPORARY TABLE latest_prices AS
SELECT 
    ticker,
    close_price as latest_close,
    trading_date as latest_date
FROM daily_stock_prices
WHERE (ticker, trading_date) IN (
    SELECT ticker, MAX(trading_date) 
    FROM daily_stock_prices 
    GROUP BY ticker
);

-- 12 Months Ago Price (or closest available)
CREATE TEMPORARY TABLE price_12m_ago AS
SELECT 
    ticker,
    close_price as price_12m_ago,
    trading_date as date_12m_ago
FROM daily_stock_prices
WHERE (ticker, trading_date) IN (
    SELECT ticker, MAX(trading_date)
    FROM daily_stock_prices
    WHERE trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 365 DAY)
    GROUP BY ticker
);

-- 6 Months Ago Price
CREATE TEMPORARY TABLE price_6m_ago AS
SELECT 
    ticker,
    close_price as price_6m_ago,
    trading_date as date_6m_ago
FROM daily_stock_prices
WHERE (ticker, trading_date) IN (
    SELECT ticker, MAX(trading_date)
    FROM daily_stock_prices
    WHERE trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
    GROUP BY ticker
);

-- 3 Months Ago Price
CREATE TEMPORARY TABLE price_3m_ago AS
SELECT 
    ticker,
    close_price as price_3m_ago,
    trading_date as date_3m_ago
FROM daily_stock_prices
WHERE (ticker, trading_date) IN (
    SELECT ticker, MAX(trading_date)
    FROM daily_stock_prices
    WHERE trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 90 DAY)
    GROUP BY ticker
);

-- CALCULATE RETURNS BY PERIOD
SELECT 
    s.ticker,
    s.security_name,
    ROUND(lp.latest_close, 2) as current_price,
    ROUND(COALESCE(p12.price_12m_ago, p6.price_6m_ago, p3.price_3m_ago), 2) as price_period_ago,
    ROUND(COALESCE(p12.price_12m_ago, p6.price_6m_ago, p3.price_3m_ago), 2) as base_price,
    
    -- 12M Return (if available)
    CASE 
        WHEN p12.price_12m_ago IS NOT NULL THEN 
            ROUND(((lp.latest_close - p12.price_12m_ago) / p12.price_12m_ago * 100), 2)
        ELSE NULL
    END as return_12m_percent,
    
    -- 6M Return
    CASE 
        WHEN p6.price_6m_ago IS NOT NULL THEN 
            ROUND(((lp.latest_close - p6.price_6m_ago) / p6.price_6m_ago * 100), 2)
        ELSE NULL
    END as return_6m_percent,
    
    -- 3M Return
    CASE 
        WHEN p3.price_3m_ago IS NOT NULL THEN 
            ROUND(((lp.latest_close - p3.price_3m_ago) / p3.price_3m_ago * 100), 2)
        ELSE NULL
    END as return_3m_percent
    
FROM security_info s
LEFT JOIN latest_prices lp ON s.ticker = lp.ticker
LEFT JOIN price_12m_ago p12 ON s.ticker = p12.ticker
LEFT JOIN price_6m_ago p6 ON s.ticker = p6.ticker
LEFT JOIN price_3m_ago p3 ON s.ticker = p3.ticker
ORDER BY s.ticker;

-- PORTFOLIO LEVEL RETURNS (Weighted Average)
-- This assumes equal starting allocation across all tickers
SELECT
    'ENTIRE PORTFOLIO' as portfolio_type,
    ROUND(AVG(CASE 
        WHEN p12.price_12m_ago IS NOT NULL THEN 
            (lp.latest_close - p12.price_12m_ago) / p12.price_12m_ago * 100
        ELSE NULL
    END), 2) as portfolio_return_12m_percent,
    
    ROUND(AVG(CASE 
        WHEN p6.price_6m_ago IS NOT NULL THEN 
            (lp.latest_close - p6.price_6m_ago) / p6.price_6m_ago * 100
        ELSE NULL
    END), 2) as portfolio_return_6m_percent,
    
    ROUND(AVG(CASE 
        WHEN p3.price_3m_ago IS NOT NULL THEN 
            (lp.latest_close - p3.price_3m_ago) / p3.price_3m_ago * 100
        ELSE NULL
    END), 2) as portfolio_return_3m_percent
    
FROM security_info s
LEFT JOIN latest_prices lp ON s.ticker = lp.ticker
LEFT JOIN price_12m_ago p12 ON s.ticker = p12.ticker
LEFT JOIN price_6m_ago p6 ON s.ticker = p6.ticker
LEFT JOIN price_3m_ago p3 ON s.ticker = p3.ticker;


-- ============================================================================
-- QUESTION 2: VOLATILITY / RISK ANALYSIS (SIGMA - Standard Deviation)
-- ============================================================================
-- Calculate 6-month and 12-month volatility for each security

-- Helper: Daily Returns for each ticker (last 252 trading days = 1 year)
CREATE TEMPORARY TABLE daily_returns AS
SELECT 
    ticker,
    trading_date,
    close_price,
    LAG(close_price) OVER (PARTITION BY ticker ORDER BY trading_date) as prev_close,
    ROUND(((close_price - LAG(close_price) OVER (PARTITION BY ticker ORDER BY trading_date)) 
            / LAG(close_price) OVER (PARTITION BY ticker ORDER BY trading_date) * 100), 4) as daily_return_pct
FROM daily_stock_prices
WHERE ticker IN ('IXN', 'QQQ', 'IEF', 'VNQ', 'GLD')
ORDER BY ticker, trading_date DESC;

-- VOLATILITY BY PERIOD
SELECT
    s.ticker,
    s.security_name,
    
    -- 6-Month Volatility
    ROUND(STDDEV(CASE 
        WHEN dr.trading_date > DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
        THEN dr.daily_return_pct 
        ELSE NULL 
    END), 2) as volatility_6m_percent,
    
    -- 12-Month Volatility (annualized)
    ROUND(STDDEV(CASE 
        WHEN dr.trading_date > DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 365 DAY)
        THEN dr.daily_return_pct 
        ELSE NULL 
    END), 2) as volatility_12m_percent,
    
    -- Count of data points used
    COUNT(DISTINCT CASE 
        WHEN dr.trading_date > DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
        THEN dr.trading_date 
    END) as data_points_6m

FROM security_info s
LEFT JOIN daily_returns dr ON s.ticker = dr.ticker
WHERE dr.daily_return_pct IS NOT NULL
GROUP BY s.ticker, s.security_name
ORDER BY s.ticker;

-- PORTFOLIO VOLATILITY (Average Risk)
SELECT
    'ENTIRE PORTFOLIO' as portfolio_type,
    ROUND(AVG(STDDEV(CASE 
        WHEN dr.trading_date > DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
        THEN dr.daily_return_pct 
        ELSE NULL 
    END) OVER (PARTITION BY dr.ticker)), 2) as portfolio_volatility_6m_percent,
    
    ROUND(AVG(STDDEV(CASE 
        WHEN dr.trading_date > DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 365 DAY)
        THEN dr.daily_return_pct 
        ELSE NULL 
    END) OVER (PARTITION BY dr.ticker)), 2) as portfolio_volatility_12m_percent
FROM daily_returns dr
WHERE dr.daily_return_pct IS NOT NULL
LIMIT 1;


-- ============================================================================
-- QUESTION 3: VARIANCE ANALYSIS (Since Correlation may not be available)
-- ============================================================================
-- Compare variances to show relative risk

SELECT
    s.ticker,
    s.security_name,
    s.asset_class,
    
    -- Variance (Standard Deviation squared)
    ROUND(POWER(STDDEV(CASE 
        WHEN dr.trading_date > DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
        THEN dr.daily_return_pct 
        ELSE NULL 
    END), 2), 4) as variance_6m,
    
    -- Mean Return
    ROUND(AVG(CASE 
        WHEN dr.trading_date > DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
        THEN dr.daily_return_pct 
        ELSE NULL 
    END), 4) as avg_daily_return_6m_pct,
    
    -- Min and Max returns
    ROUND(MIN(CASE 
        WHEN dr.trading_date > DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
        THEN dr.daily_return_pct 
        ELSE NULL 
    END), 2) as min_daily_return_6m_pct,
    
    ROUND(MAX(CASE 
        WHEN dr.trading_date > DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
        THEN dr.daily_return_pct 
        ELSE NULL 
    END), 2) as max_daily_return_6m_pct
    
FROM security_info s
LEFT JOIN daily_returns dr ON s.ticker = dr.ticker
WHERE dr.daily_return_pct IS NOT NULL
GROUP BY s.ticker, s.security_name, s.asset_class
ORDER BY variance_6m DESC;


-- ============================================================================
-- QUESTION 4: SUMMARY ANALYSIS FOR RECOMMENDATIONS
-- ============================================================================
-- Create a comprehensive view for decision making

SELECT
    s.ticker,
    s.security_name,
    s.asset_class,
    s.current_percent as current_allocation_pct,
    
    -- Returns
    ROUND(((lp.latest_close - p12.price_12m_ago) / p12.price_12m_ago * 100), 2) as return_12m_pct,
    ROUND(((lp.latest_close - p6.price_6m_ago) / p6.price_6m_ago * 100), 2) as return_6m_pct,
    ROUND(((lp.latest_close - p3.price_3m_ago) / p3.price_3m_ago * 100), 2) as return_3m_pct,
    
    -- Risk
    ROUND(STDDEV(CASE 
        WHEN dr.trading_date > DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
        THEN dr.daily_return_pct 
        ELSE NULL 
    END), 2) as volatility_6m_pct,
    
    -- Risk-Adjusted Return (Return / Risk ratio)
    ROUND(
        ((lp.latest_close - p6.price_6m_ago) / p6.price_6m_ago * 100) / 
        STDDEV(CASE 
            WHEN dr.trading_date > DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
            THEN dr.daily_return_pct 
            ELSE NULL 
        END), 2
    ) as sharpe_ratio_6m
    
FROM security_info s
LEFT JOIN latest_prices lp ON s.ticker = lp.ticker
LEFT JOIN price_12m_ago p12 ON s.ticker = p12.ticker
LEFT JOIN price_6m_ago p6 ON s.ticker = p6.ticker
LEFT JOIN price_3m_ago p3 ON s.ticker = p3.ticker
LEFT JOIN daily_returns dr ON s.ticker = dr.ticker
WHERE dr.daily_return_pct IS NOT NULL
GROUP BY s.ticker
ORDER BY return_6m_pct DESC;

-- ============================================================================
-- QUESTION 5: SUGGESTED REBALANCING
-- ============================================================================

-- Analysis: Identify underperformers and overperformers
SELECT
    s.ticker,
    s.security_name,
    s.asset_class,
    s.current_percent as current_allocation_pct,
    
    -- Performance Metrics
    ROUND(((lp.latest_close - p6.price_6m_ago) / p6.price_6m_ago * 100), 2) as return_6m_pct,
    ROUND(STDDEV(dr.daily_return_pct), 2) as volatility_6m_pct,
    
    -- Recommendation Logic
    CASE 
        WHEN ((lp.latest_close - p6.price_6m_ago) / p6.price_6m_ago * 100) < -5 THEN 'SELL - Underperforming'
        WHEN ((lp.latest_close - p6.price_6m_ago) / p6.price_6m_ago * 100) > 15 AND STDDEV(dr.daily_return_pct) < 2 THEN 'HOLD - Strong Performer, Low Risk'
        WHEN ((lp.latest_close - p6.price_6m_ago) / p6.price_6m_ago * 100) > 15 AND STDDEV(dr.daily_return_pct) > 3 THEN 'REDUCE - High Volatility'
        WHEN ((lp.latest_close - p6.price_6m_ago) / p6.price_6m_ago * 100) BETWEEN -5 AND 5 THEN 'HOLD - Stable'
        ELSE 'REVIEW'
    END as recommendation
    
FROM security_info s
LEFT JOIN latest_prices lp ON s.ticker = lp.ticker
LEFT JOIN price_6m_ago p6 ON s.ticker = p6.ticker
LEFT JOIN daily_returns dr ON s.ticker = dr.ticker
WHERE dr.daily_return_pct IS NOT NULL
GROUP BY s.ticker
ORDER BY return_6m_pct DESC;

-- Suggested New Allocation (Example: Move away from underperformers, increase winners)
SELECT
    ticker,
    security_name,
    current_percent as current_allocation_pct,
    
    -- Suggested adjustment (example: +2% to winners, -2% to underperformers)
    CASE
        WHEN ticker IN ('QQQ', 'IXN') THEN current_percent + 2  -- Strong performers
        WHEN ticker = 'GLD' THEN current_percent - 2             -- Underperformer
        ELSE current_percent
    END as suggested_allocation_pct,
    
    CASE
        WHEN ticker IN ('QQQ', 'IXN') THEN '+2% (Increase)'
        WHEN ticker = 'GLD' THEN '-2% (Reduce)'
        ELSE 'No Change'
    END as change_recommendation
    
FROM security_info
ORDER BY current_percent DESC;

-- ============================================================================
-- END OF ANALYSIS
-- ============================================================================

/*
KEY FINDINGS & RECOMMENDATIONS SUMMARY:

1. RETURNS ANALYSIS:
   - Identifies best and worst performers over 3M, 6M, 12M periods
   - Shows if portfolio is aligned with market trends
   
2. VOLATILITY ANALYSIS:
   - Measures risk (standard deviation of daily returns)
   - Lower volatility = more stable investment
   - Higher volatility = more risky but potentially higher returns
   
3. VARIANCE ANALYSIS:
   - Compares relative risk between securities
   - Helps identify which holdings are causing portfolio volatility
   
4. RECOMMENDATIONS:
   - SELL: Underperforming securities (negative or low returns)
   - REDUCE: High volatility with adequate returns
   - HOLD: Stable performers or strong performers with low risk
   - INCREASE: Strong performers with attractive risk-adjusted returns
   
5. REBALANCING:
   - Shift allocation from underperformers to winners
   - Reduce concentration in high-volatility assets
   - Maintain diversification across asset classes
   
NEXT STEPS:
- Compare current allocation with suggested allocation
- Calculate expected return and risk after rebalancing
- Monitor implementation costs and tax implications
*/

