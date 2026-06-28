-- ═══════════════════════════════════════════════════════════════════════════════
-- BEGINNER-FRIENDLY PORTFOLIO ANALYSIS
-- For Friend's Assignment - Simple & Easy to Understand
-- ═══════════════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════════════════
-- STEP 1: CREATE DATABASE AND TABLES
-- ═══════════════════════════════════════════════════════════════════════════════

-- Create database
CREATE DATABASE IF NOT EXISTS portfolio_analysis;
USE portfolio_analysis;

-- ═══════════════════════════════════════════════════════════════════════════════
-- TABLE 1: Store daily prices for all tickers
-- ═══════════════════════════════════════════════════════════════════════════════
DROP TABLE IF EXISTS daily_prices;

CREATE TABLE daily_prices (
    price_id       INT AUTO_INCREMENT PRIMARY KEY,
    trading_date   DATE NOT NULL,
    ticker         VARCHAR(10) NOT NULL,
    closing_price  DECIMAL(10, 2) NOT NULL,

    -- Create index for faster searches
    INDEX idx_ticker_date (ticker, trading_date)
);

-- ═══════════════════════════════════════════════════════════════════════════════
-- TABLE 2: Store ticker information
-- ═══════════════════════════════════════════════════════════════════════════════
DROP TABLE IF EXISTS ticker_info;

CREATE TABLE ticker_info (
    ticker           VARCHAR(10) PRIMARY KEY,
    security_name    VARCHAR(100) NOT NULL,
    current_percent  DECIMAL(5, 2) NOT NULL,
    asset_class      VARCHAR(50) NOT NULL
);

-- ═══════════════════════════════════════════════════════════════════════════════
-- STEP 2: INSERT TICKER INFORMATION
-- ═══════════════════════════════════════════════════════════════════════════════

INSERT INTO ticker_info (ticker, security_name, current_percent, asset_class) VALUES
('IXN', 'iShares Global Tech ETF', 17.5, 'Equity'),
('QQQ', 'NASDAQ 100', 22.1, 'Equity'),
('IEF', 'iShares 7-10 Year Treasury Bond ETF', 28.5, 'Fixed Income'),
('VNQ', 'Vanguard Real Estate ETF', 8.9, 'Real Assets'),
('GLD', 'SPDR Gold Shares', 23.0, 'Commodities');

-- ═══════════════════════════════════════════════════════════════════════════════
-- STEP 3: INSERT DAILY PRICES FROM EXCEL DATA
-- ═══════════════════════════════════════════════════════════════════════════════
--
-- INSTRUCTIONS FOR YOUR FRIEND:
-- 1. Export Excel data as CSV (comma-separated values)
-- 2. Format should be: Date, Ticker, ClosePrice
-- 3. Example rows:
--    2024-06-12,IXN,138.50
--    2024-06-12,QQQ,425.30
--    2024-06-12,IEF,97.50
--    etc.
-- 4. Then run this import command in MySQL:
--
--    LOAD DATA LOCAL INFILE '/path/to/your/file.csv'
--    INTO TABLE daily_prices
--    FIELDS TERMINATED BY ','
--    LINES TERMINATED BY '\n'
--    (trading_date, ticker, closing_price);
--
-- OR manually insert sample data like this:
-- ═══════════════════════════════════════════════════════════════════════════════

-- Sample data (replace with your real data)
INSERT INTO daily_prices (trading_date, ticker, closing_price) VALUES
('2024-06-12', 'IXN', 138.50),
('2024-06-11', 'IXN', 137.20),
('2024-06-10', 'IXN', 136.80),
-- Add more data here from your Excel file
-- Continue with QQQ, GLD, VNQ, IEF data
;

-- ═══════════════════════════════════════════════════════════════════════════════
-- VERIFICATION: Check data is loaded
-- ═══════════════════════════════════════════════════════════════════════════════

SELECT
    ticker,
    COUNT(*) as total_records,
    MIN(trading_date) as earliest_date,
    MAX(trading_date) as latest_date
FROM daily_prices
GROUP BY ticker
ORDER BY ticker;

-- ═══════════════════════════════════════════════════════════════════════════════
-- QUESTION 1: INDIVIDUAL SECURITY RETURNS (12M, 18M, 24M)
-- ═══════════════════════════════════════════════════════════════════════════════
--
-- WHAT DOES THIS MEASURE?
-- Returns show how much money an investor would have made (or lost)
-- Example: If you invested $100 and it's now worth $112, your return is 12%
--
-- HOW TO CALCULATE:
-- Return = ((Current Price - Old Price) / Old Price) × 100%
-- ═══════════════════════════════════════════════════════════════════════════════

SELECT
    t.ticker,
    t.security_name,

    -- 12-MONTH RETURN (252 trading days ≈ 1 year)
    ROUND(
        ((today.closing_price - price_12m.closing_price) / price_12m.closing_price) * 100,
        2
    ) as return_12m_pct,

    -- 18-MONTH RETURN (378 trading days ≈ 1.5 years)
    ROUND(
        ((today.closing_price - price_18m.closing_price) / price_18m.closing_price) * 100,
        2
    ) as return_18m_pct,

    -- 24-MONTH RETURN (504 trading days ≈ 2 years)
    ROUND(
        ((today.closing_price - price_24m.closing_price) / price_24m.closing_price) * 100,
        2
    ) as return_24m_pct

FROM ticker_info t

-- Get today's price (most recent date)
JOIN (
    SELECT ticker, closing_price
    FROM daily_prices
    WHERE trading_date = (SELECT MAX(trading_date) FROM daily_prices)
) today ON t.ticker = today.ticker

-- Get price from 12 months ago (252 trading days back)
LEFT JOIN (
    SELECT ticker, closing_price
    FROM daily_prices
    WHERE trading_date = (
        SELECT trading_date FROM daily_prices p1
        WHERE p1.ticker = 'IXN'  -- Change to each ticker
        ORDER BY trading_date DESC
        LIMIT 1 OFFSET 251
    )
) price_12m ON t.ticker = price_12m.ticker

-- Get price from 18 months ago (378 trading days back)
LEFT JOIN (
    SELECT ticker, closing_price
    FROM daily_prices
    WHERE trading_date = (
        SELECT trading_date FROM daily_prices p1
        WHERE p1.ticker = 'IXN'  -- Change to each ticker
        ORDER BY trading_date DESC
        LIMIT 1 OFFSET 377
    )
) price_18m ON t.ticker = price_18m.ticker

-- Get price from 24 months ago (504 trading days back)
LEFT JOIN (
    SELECT ticker, closing_price
    FROM daily_prices
    WHERE trading_date = (
        SELECT trading_date FROM daily_prices p1
        WHERE p1.ticker = 'IXN'  -- Change to each ticker
        ORDER BY trading_date DESC
        LIMIT 1 OFFSET 503
    )
) price_24m ON t.ticker = price_24m.ticker

ORDER BY return_12m_pct DESC;

-- ═══════════════════════════════════════════════════════════════════════════════
-- QUESTION 2: VARIANCE ANALYSIS (Proxy for Correlation)
-- ═══════════════════════════════════════════════════════════════════════════════
--
-- WHAT DOES THIS MEASURE?
-- Variance = How much a price bounces up and down
-- Higher variance = More risky (bigger price swings)
-- Lower variance = More stable (smaller price swings)
--
-- HOW IT WORKS:
-- If Asset A varies from $100-$120 and Asset B varies from $100-$102,
-- Asset A has higher variance = higher risk = bounces around more
-- ═══════════════════════════════════════════════════════════════════════════════

-- Calculate daily returns (% change day-to-day)
WITH daily_returns AS (
    SELECT
        ticker,
        trading_date,
        closing_price,
        LAG(closing_price) OVER (PARTITION BY ticker ORDER BY trading_date) as prev_price,

        -- Daily return % = (Today - Yesterday) / Yesterday × 100
        ROUND(
            ((closing_price - LAG(closing_price) OVER (PARTITION BY ticker ORDER BY trading_date))
             / LAG(closing_price) OVER (PARTITION BY ticker ORDER BY trading_date)) * 100,
            4
        ) as daily_return_pct

    FROM daily_prices

    -- Use last 6 months for recent variance
    WHERE trading_date >= DATE_SUB(
        (SELECT MAX(trading_date) FROM daily_prices),
        INTERVAL 6 MONTH
    )
)

-- Calculate variance for each ticker
SELECT
    dr.ticker,
    ti.security_name,

    -- Variance of daily returns
    ROUND(VARIANCE(dr.daily_return_pct), 2) as variance,

    -- Standard deviation (another measure of risk)
    ROUND(STDDEV(dr.daily_return_pct), 2) as std_deviation,

    -- How many days of data we analyzed
    COUNT(*) as data_points

FROM daily_returns dr
JOIN ticker_info ti ON dr.ticker = ti.ticker

WHERE dr.daily_return_pct IS NOT NULL

GROUP BY dr.ticker, ti.security_name

ORDER BY variance DESC;  -- Highest variance first

-- ═══════════════════════════════════════════════════════════════════════════════
-- QUESTION 3: ANNUALIZED VOLATILITY (SIGMA - Risk Measurement)
-- ═══════════════════════════════════════════════════════════════════════════════
--
-- WHAT DOES THIS MEASURE?
-- Sigma (σ) = How much the price swings annually
-- Example: If sigma = 20%, price could swing ±20% in a year
--
-- FORMULA:
-- Sigma = Daily Volatility × √252 (trading days per year)
-- ═══════════════════════════════════════════════════════════════════════════════

WITH daily_returns AS (
    SELECT
        ticker,
        trading_date,
        closing_price,
        LAG(closing_price) OVER (PARTITION BY ticker ORDER BY trading_date) as prev_price,

        ROUND(
            ((closing_price - LAG(closing_price) OVER (PARTITION BY ticker ORDER BY trading_date))
             / LAG(closing_price) OVER (PARTITION BY ticker ORDER BY trading_date)) * 100,
            4
        ) as daily_return_pct

    FROM daily_prices

    -- Use last 12 months for annual volatility
    WHERE trading_date >= DATE_SUB(
        (SELECT MAX(trading_date) FROM daily_prices),
        INTERVAL 12 MONTH
    )
)

SELECT
    dr.ticker,
    ti.security_name,
    ti.asset_class,

    -- Daily volatility (standard deviation of daily returns)
    ROUND(STDDEV(dr.daily_return_pct), 4) as daily_volatility_pct,

    -- Annualized volatility (SIGMA)
    -- √252 ≈ 15.87
    ROUND(STDDEV(dr.daily_return_pct) * SQRT(252), 2) as annual_volatility_sigma,

    -- Risk classification
    CASE
        WHEN STDDEV(dr.daily_return_pct) * SQRT(252) > 25 THEN 'HIGH RISK'
        WHEN STDDEV(dr.daily_return_pct) * SQRT(252) > 15 THEN 'MODERATE RISK'
        ELSE 'LOW RISK'
    END as risk_level,

    -- Number of trading days analyzed
    COUNT(*) as trading_days_analyzed

FROM daily_returns dr
JOIN ticker_info ti ON dr.ticker = ti.ticker

WHERE dr.daily_return_pct IS NOT NULL

GROUP BY dr.ticker, ti.security_name, ti.asset_class

ORDER BY annual_volatility_sigma DESC;  -- Highest risk first

-- ═══════════════════════════════════════════════════════════════════════════════
-- QUESTION 4: SHARPE RATIO ANALYSIS (Risk-Adjusted Returns)
-- ═══════════════════════════════════════════════════════════════════════════════
--
-- WHAT DOES THIS MEASURE?
-- Sharpe Ratio = How much return you get per unit of risk
-- Higher Sharpe = Better investment (more return for same risk)
--
-- FORMULA:
-- Sharpe = (Expected Annual Return - Risk-Free Rate) / Annual Volatility
-- Risk-Free Rate = 2% (US Treasury bonds)
-- ═══════════════════════════════════════════════════════════════════════════════

WITH daily_returns AS (
    SELECT
        ticker,
        trading_date,
        closing_price,
        LAG(closing_price) OVER (PARTITION BY ticker ORDER BY trading_date) as prev_price,

        ROUND(
            ((closing_price - LAG(closing_price) OVER (PARTITION BY ticker ORDER BY trading_date))
             / LAG(closing_price) OVER (PARTITION BY ticker ORDER BY trading_date)) * 100,
            4
        ) as daily_return_pct

    FROM daily_prices

    WHERE trading_date >= DATE_SUB(
        (SELECT MAX(trading_date) FROM daily_prices),
        INTERVAL 12 MONTH
    )
)

SELECT
    dr.ticker,
    ti.security_name,
    ti.current_percent as current_allocation,

    -- Expected annual return
    ROUND(AVG(dr.daily_return_pct) * 252, 2) as expected_annual_return_pct,

    -- Annual volatility
    ROUND(STDDEV(dr.daily_return_pct) * SQRT(252), 2) as annual_volatility_pct,

    -- Sharpe ratio (2% risk-free rate)
    ROUND(
        (AVG(dr.daily_return_pct) * 252 - 2) / (STDDEV(dr.daily_return_pct) * SQRT(252)),
        4
    ) as sharpe_ratio,

    -- Investment recommendation based on Sharpe
    CASE
        WHEN (AVG(dr.daily_return_pct) * 252 - 2) / (STDDEV(dr.daily_return_pct) * SQRT(252)) > 0.8 THEN 'STRONG BUY'
        WHEN (AVG(dr.daily_return_pct) * 252 - 2) / (STDDEV(dr.daily_return_pct) * SQRT(252)) > 0.5 THEN 'BUY'
        WHEN (AVG(dr.daily_return_pct) * 252 - 2) / (STDDEV(dr.daily_return_pct) * SQRT(252)) > 0.2 THEN 'HOLD'
        ELSE 'SELL'
    END as recommendation

FROM daily_returns dr
JOIN ticker_info ti ON dr.ticker = ti.ticker

WHERE dr.daily_return_pct IS NOT NULL

GROUP BY dr.ticker, ti.security_name, ti.current_percent

ORDER BY sharpe_ratio DESC;  -- Best quality first

-- ═══════════════════════════════════════════════════════════════════════════════
-- QUESTION 5: REBALANCING PROPOSAL
-- ═══════════════════════════════════════════════════════════════════════════════
--
-- WHAT SHOULD WE DO?
-- Based on Sharpe Ratios, recommend which holdings to BUY, SELL, or HOLD
-- Goal: Increase portfolio return with minimal risk increase
-- ═══════════════════════════════════════════════════════════════════════════════

-- This requires manual analysis based on Question 4 results
-- Example recommendation logic:
--
-- IF Sharpe Ratio > 1.5:  STRONG BUY  (invest more)
-- IF Sharpe Ratio > 1.0:  BUY         (increase position)
-- IF Sharpe Ratio > 0.5:  HOLD        (keep current)
-- IF Sharpe Ratio < 0.5:  SELL        (reduce position)

-- Sample rebalancing proposal (you'll create this after analyzing Q4 results)
SELECT
    ti.ticker,
    ti.security_name,
    ti.current_percent as current_allocation_pct,

    -- Proposed allocation (you decide based on Sharpe analysis)
    CASE
        WHEN ti.ticker = 'IXN' THEN 20.0   -- Increase from 17.5%
        WHEN ti.ticker = 'QQQ' THEN 25.0   -- Increase from 22.1%
        WHEN ti.ticker = 'GLD' THEN 22.0   -- Hold at 23%
        WHEN ti.ticker = 'VNQ' THEN 18.0   -- Increase from 8.9%
        WHEN ti.ticker = 'IEF' THEN 15.0   -- Reduce from 28.5%
    END as proposed_allocation_pct,

    -- Calculate trade amount (assume $95M portfolio)
    ROUND(
        (CASE
            WHEN ti.ticker = 'IXN' THEN 20.0
            WHEN ti.ticker = 'QQQ' THEN 25.0
            WHEN ti.ticker = 'GLD' THEN 22.0
            WHEN ti.ticker = 'VNQ' THEN 18.0
            WHEN ti.ticker = 'IEF' THEN 15.0
        END - ti.current_percent) * 95 / 100,
        1
    ) as trade_amount_millions,

    -- Action to take
    CASE
        WHEN CASE
            WHEN ti.ticker = 'IXN' THEN 20.0
            WHEN ti.ticker = 'QQQ' THEN 25.0
            WHEN ti.ticker = 'GLD' THEN 22.0
            WHEN ti.ticker = 'VNQ' THEN 18.0
            WHEN ti.ticker = 'IEF' THEN 15.0
        END > ti.current_percent THEN 'BUY'
        WHEN CASE
            WHEN ti.ticker = 'IXN' THEN 20.0
            WHEN ti.ticker = 'QQQ' THEN 25.0
            WHEN ti.ticker = 'GLD' THEN 22.0
            WHEN ti.ticker = 'VNQ' THEN 18.0
            WHEN ti.ticker = 'IEF' THEN 15.0
        END < ti.current_percent THEN 'SELL'
        ELSE 'HOLD'
    END as action

FROM ticker_info ti

ORDER BY
    CASE
        WHEN CASE
            WHEN ti.ticker = 'IXN' THEN 20.0
            WHEN ti.ticker = 'QQQ' THEN 25.0
            WHEN ti.ticker = 'GLD' THEN 22.0
            WHEN ti.ticker = 'VNQ' THEN 18.0
            WHEN ti.ticker = 'IEF' THEN 15.0
        END > ti.current_percent THEN 0  -- BUY first
        WHEN CASE
            WHEN ti.ticker = 'IXN' THEN 20.0
            WHEN ti.ticker = 'QQQ' THEN 25.0
            WHEN ti.ticker = 'GLD' THEN 22.0
            WHEN ti.ticker = 'VNQ' THEN 18.0
            WHEN ti.ticker = 'IEF' THEN 15.0
        END < ti.current_percent THEN 2  -- SELL last
        ELSE 1  -- HOLD in middle
    END;

-- ═══════════════════════════════════════════════════════════════════════════════
-- VERIFICATION QUERIES (Run these to check your work)
-- ═══════════════════════════════════════════════════════════════════════════════

-- Check total records loaded
SELECT COUNT(*) as total_price_records FROM daily_prices;

-- Check tickers in database
SELECT DISTINCT ticker FROM daily_prices ORDER BY ticker;

-- Check date range
SELECT
    MIN(trading_date) as earliest_date,
    MAX(trading_date) as latest_date,
    COUNT(DISTINCT trading_date) as total_trading_days
FROM daily_prices;

-- Check data completeness for each ticker
SELECT
    ticker,
    COUNT(*) as record_count,
    MIN(trading_date) as earliest_date,
    MAX(trading_date) as latest_date
FROM daily_prices
GROUP BY ticker
ORDER BY ticker;
