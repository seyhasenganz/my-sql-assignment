-- ===================================
-- QUESTION 1: INDIVIDUAL SECURITY RETURNS
-- ===================================
-- Using the SAME proven structure from SIMPLE_5_QUESTIONS.sql
-- Get 12M, 18M, 24M returns for EACH security

USE invest_portfolio;

-- ===================================
-- Method: Use CTEs (WITH clause) - Same as working portfolio query
-- ===================================

WITH today_prices AS (
    SELECT ticker, value FROM pricing_daily
    WHERE price_type = 'Adj Close'
    AND date = (SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close')
),

prices_12m_ago AS (
    SELECT ticker, value FROM pricing_daily
    WHERE price_type = 'Adj Close'
    AND date = (SELECT MAX(date) FROM pricing_daily
                WHERE price_type = 'Adj Close'
                AND date <= DATE_SUB((SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close'), INTERVAL 252 DAY))
),

prices_18m_ago AS (
    SELECT ticker, value FROM pricing_daily
    WHERE price_type = 'Adj Close'
    AND date = (SELECT MAX(date) FROM pricing_daily
                WHERE price_type = 'Adj Close'
                AND date <= DATE_SUB((SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close'), INTERVAL 378 DAY))
),

prices_24m_ago AS (
    SELECT ticker, value FROM pricing_daily
    WHERE price_type = 'Adj Close'
    AND date = (SELECT MAX(date) FROM pricing_daily
                WHERE price_type = 'Adj Close'
                AND date <= DATE_SUB((SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close'), INTERVAL 504 DAY))
)

-- ===================================
-- Main Query: Calculate returns for each security
-- ===================================
SELECT
    s.ticker,
    s.security_name,
    h.portfolio_weight,

    -- Today's prices
    ROUND(tp.value, 2) as today_price,

    -- 12-Month Return
    ROUND(p12.value, 2) as price_12m_ago,
    ROUND(((tp.value - p12.value) / p12.value) * 100, 2) as return_12m_pct,

    -- 18-Month Return
    ROUND(p18.value, 2) as price_18m_ago,
    ROUND(((tp.value - p18.value) / p18.value) * 100, 2) as return_18m_pct,

    -- 24-Month Return
    ROUND(p24.value, 2) as price_24m_ago,
    ROUND(((tp.value - p24.value) / p24.value) * 100, 2) as return_24m_pct,

    -- Dollar Gains (12M)
    ROUND((tp.value - p12.value) * h.market_value_million * 1000000 / p12.value, 0) as gain_12m_dollars

FROM security_masterlist s
JOIN today_prices tp ON s.ticker = tp.ticker
JOIN prices_12m_ago p12 ON s.ticker = p12.ticker
JOIN prices_18m_ago p18 ON s.ticker = p18.ticker
JOIN prices_24m_ago p24 ON s.ticker = p24.ticker
JOIN holdings_dim h ON s.ticker = h.ticker AND h.account_id = 1001

ORDER BY return_24m_pct DESC;
