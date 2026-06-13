-- ===================================
-- QUESTION 1: INDIVIDUAL SECURITY RETURNS
-- ===================================
-- Calculate 12M, 18M, 24M returns for EACH security
-- Formula: ((Current Price - Historical Price) / Historical Price) × 100

USE invest_portfolio;

-- ===================================
-- STEP 1: Get Today's Price
-- ===================================
WITH today_prices AS (
    SELECT
        ticker,
        value as today_price
    FROM pricing_daily
    WHERE price_type = 'Adj Close'
    AND date = (SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close')
),

-- ===================================
-- STEP 2: Get Prices 12 Months Ago (252 trading days)
-- ===================================
prices_12m_ago AS (
    SELECT
        ticker,
        value as price_12m_ago
    FROM pricing_daily
    WHERE price_type = 'Adj Close'
    AND date = (
        SELECT MAX(date) FROM pricing_daily
        WHERE price_type = 'Adj Close'
        AND date <= DATE_SUB((SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close'), INTERVAL 252 DAY)
    )
),

-- ===================================
-- STEP 3: Get Prices 18 Months Ago (378 trading days)
-- ===================================
prices_18m_ago AS (
    SELECT
        ticker,
        value as price_18m_ago
    FROM pricing_daily
    WHERE price_type = 'Adj Close'
    AND date = (
        SELECT MAX(date) FROM pricing_daily
        WHERE price_type = 'Adj Close'
        AND date <= DATE_SUB((SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close'), INTERVAL 378 DAY)
    )
),

-- ===================================
-- STEP 4: Get Prices 24 Months Ago (504 trading days)
-- ===================================
prices_24m_ago AS (
    SELECT
        ticker,
        value as price_24m_ago
    FROM pricing_daily
    WHERE price_type = 'Adj Close'
    AND date = (
        SELECT MAX(date) FROM pricing_daily
        WHERE price_type = 'Adj Close'
        AND date <= DATE_SUB((SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close'), INTERVAL 504 DAY)
    )
)

-- ===================================
-- FINAL QUERY: Calculate Returns for Each Security
-- ===================================
SELECT
    s.ticker,
    s.security_name,
    h.portfolio_weight,
    -- Today's price
    ROUND(tp.today_price, 2) as today_price,

    -- 12-Month Return Calculation
    ROUND(tp.price_12m_ago, 2) as price_12m_ago,
    ROUND(((tp.today_price - p12.price_12m_ago) / p12.price_12m_ago) * 100, 2) as return_12m_pct,

    -- 18-Month Return Calculation
    ROUND(p18.price_18m_ago, 2) as price_18m_ago,
    ROUND(((tp.today_price - p18.price_18m_ago) / p18.price_18m_ago) * 100, 2) as return_18m_pct,

    -- 24-Month Return Calculation
    ROUND(p24.price_24m_ago, 2) as price_24m_ago,
    ROUND(((tp.today_price - p24.price_24m_ago) / p24.price_24m_ago) * 100, 2) as return_24m_pct,

    -- Dollar gains
    ROUND((tp.today_price - p12.price_12m_ago) * h.market_value_million * 1000000 / p12.price_12m_ago, 0) as gain_12m_dollars

FROM security_masterlist s
JOIN today_prices tp ON s.ticker = tp.ticker
LEFT JOIN prices_12m_ago p12 ON s.ticker = p12.ticker
LEFT JOIN prices_18m_ago p18 ON s.ticker = p18.ticker
LEFT JOIN prices_24m_ago p24 ON s.ticker = p24.ticker
LEFT JOIN holdings_dim h ON s.ticker = h.ticker AND h.account_id = 1001

ORDER BY s.ticker;

-- ===================================
-- EXPLANATION
-- ===================================
-- This query calculates returns using the formula:
-- Return % = ((Current Price - Historical Price) / Historical Price) × 100
--
-- The query works by:
-- 1. Finding today's price (latest date in database)
-- 2. Finding price 252 days ago (approximately 12 months of trading days)
-- 3. Finding price 378 days ago (approximately 18 months)
-- 4. Finding price 504 days ago (approximately 24 months)
-- 5. Calculating percentage return for each time period
-- 6. Multiplying by portfolio weight and market value for dollar gains
--
-- Results show which securities performed best/worst over each period
