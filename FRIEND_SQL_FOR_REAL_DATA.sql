-- ═══════════════════════════════════════════════════════════════════════════════
-- COMPLETE SQL FOR PORTFOLIO ANALYSIS - REAL DATA (2 YEARS)
-- Data: 21-Jun-2024 to 21-Jun-2026
-- File: All_ticker.csv
-- ═══════════════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════════════════
-- STEP 1: CREATE DATABASE AND SCHEMA
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE DATABASE IF NOT EXISTS portfolio_db;
USE portfolio_db;

-- ═══════════════════════════════════════════════════════════════════════════════
-- TABLE 1: DAILY PRICES (with all OHLCV data)
-- ═══════════════════════════════════════════════════════════════════════════════

DROP TABLE IF EXISTS daily_stock_prices;

CREATE TABLE daily_stock_prices (
    price_id       INT AUTO_INCREMENT PRIMARY KEY,
    trading_date   DATE NOT NULL,
    ticker         VARCHAR(10) NOT NULL,
    open_price     DECIMAL(10, 2),
    high_price     DECIMAL(10, 2),
    low_price      DECIMAL(10, 2),
    close_price    DECIMAL(10, 2) NOT NULL,
    adj_close      DECIMAL(10, 2),
    volume         BIGINT,

    -- Indexes for faster queries
    INDEX idx_ticker_date (ticker, trading_date),
    INDEX idx_date (trading_date)
);

-- ═══════════════════════════════════════════════════════════════════════════════
-- TABLE 2: TICKER INFORMATION
-- ═══════════════════════════════════════════════════════════════════════════════

DROP TABLE IF EXISTS security_info;

CREATE TABLE security_info (
    ticker           VARCHAR(10) PRIMARY KEY,
    security_name    VARCHAR(100) NOT NULL,
    current_percent  DECIMAL(5, 2) NOT NULL,
    asset_class      VARCHAR(50) NOT NULL,
    portfolio_value  DECIMAL(15, 2)  -- = current_percent * 95M / 100
);

-- ═══════════════════════════════════════════════════════════════════════════════
-- STEP 2: INSERT TICKER INFORMATION
-- ═══════════════════════════════════════════════════════════════════════════════

INSERT INTO security_info (ticker, security_name, current_percent, asset_class, portfolio_value) VALUES
('IXN', 'iShares Global Tech ETF', 17.5, 'Equity', 16.625),
('QQQ', 'NASDAQ 100', 22.1, 'Equity', 20.995),
('IEF', 'iShares 7-10 Year Treasury Bond ETF', 28.5, 'Fixed Income', 27.075),
('VNQ', 'Vanguard Real Estate ETF', 8.9, 'Real Assets', 8.455),
('GLD', 'SPDR Gold Shares', 23.0, 'Commodities', 21.85);

-- ═══════════════════════════════════════════════════════════════════════════════
-- STEP 3: IMPORT DATA FROM CSV
-- ═══════════════════════════════════════════════════════════════════════════════
--
-- CSV FILE FORMAT:
-- Date,Ticker,Open,High,Low,Close ,Adj Close ,Volume
-- 18-Jun-26,IXN,145.03,146.63,144.49,146.33,146.33,"361,000"
--
-- METHOD 1: LOAD DATA from CSV (RECOMMENDED)
-- ═══════════════════════════════════════════════════════════════════════════════
--
-- IMPORTANT: In MySQL Workbench, use this command:
--
-- LOAD DATA LOCAL INFILE 'C:/path/to/All_ticker.csv'
-- INTO TABLE portfolio_db.daily_stock_prices
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS
-- (@trading_date, ticker, open_price, high_price, low_price, close_price, adj_close, @volume)
-- SET
--     trading_date = STR_TO_DATE(@trading_date, '%d-%b-%y'),
--     volume = CAST(REPLACE(@volume, ',', '') AS UNSIGNED);
--
-- Note: The SET clause handles:
-- - Date conversion from DD-MMM-YY to DATE format
-- - Volume comma removal (361,000 → 361000)
--
-- ═══════════════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════════════════
-- VERIFICATION QUERIES (Run after importing data)
-- ═══════════════════════════════════════════════════════════════════════════════

-- Check 1: Total records imported
SELECT COUNT(*) as total_records FROM daily_stock_prices;

-- Check 2: Records per ticker (should be ~503 each for 2 years)
SELECT
    ticker,
    COUNT(*) as record_count,
    MIN(trading_date) as earliest_date,
    MAX(trading_date) as latest_date
FROM daily_stock_prices
GROUP BY ticker
ORDER BY ticker;

-- Check 3: Date range (should be 21-Jun-2024 to 21-Jun-2026)
SELECT
    MIN(trading_date) as earliest_date,
    MAX(trading_date) as latest_date,
    COUNT(DISTINCT trading_date) as unique_trading_days
FROM daily_stock_prices;

-- Check 4: Sample data
SELECT * FROM daily_stock_prices LIMIT 10;

-- ═══════════════════════════════════════════════════════════════════════════════
-- QUESTION 1: RETURNS ANALYSIS (12M, 18M, 24M)
-- ═══════════════════════════════════════════════════════════════════════════════
--
-- WHAT: Calculate return on investment for different time periods
-- FORMULA: ((Current Price - Old Price) / Old Price) × 100%
-- TIME WINDOWS:
--   - 12M = 252 trading days (1 year)
--   - 18M = 378 trading days (1.5 years)
--   - 24M = 504 trading days (2 years)
--
-- NOTE: Using 2 years of data means we can calculate:
--   - 24M return (back to 21-Jun-2024)
--   - 18M return (back to 21-Dec-2024)
--   - 12M return (back to 21-Jun-2025)
-- ═══════════════════════════════════════════════════════════════════════════════

-- Get today's date and recent prices
WITH today_prices AS (
    SELECT ticker, close_price, trading_date
    FROM daily_stock_prices
    WHERE trading_date = (SELECT MAX(trading_date) FROM daily_stock_prices)
),

-- Get prices from 12 months ago (252 trading days back)
prices_12m_ago AS (
    SELECT ticker, close_price, trading_date,
           ROW_NUMBER() OVER (PARTITION BY ticker ORDER BY trading_date DESC) as row_num
    FROM daily_stock_prices
    WHERE trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 12 MONTH)
),

-- Get prices from 18 months ago (378 trading days back)
prices_18m_ago AS (
    SELECT ticker, close_price, trading_date,
           ROW_NUMBER() OVER (PARTITION BY ticker ORDER BY trading_date DESC) as row_num
    FROM daily_stock_prices
    WHERE trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 18 MONTH)
),

-- Get prices from 24 months ago (504 trading days back)
prices_24m_ago AS (
    SELECT ticker, close_price, trading_date,
           ROW_NUMBER() OVER (PARTITION BY ticker ORDER BY trading_date DESC) as row_num
    FROM daily_stock_prices
    WHERE trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 24 MONTH)
)

SELECT
    s.ticker,
    s.security_name,
    s.current_percent,

    -- 24-MONTH RETURN (since 21-Jun-2024)
    ROUND(
        ((t.close_price - p24.close_price) / p24.close_price) * 100,
        2
    ) as return_24m_pct,

    -- 18-MONTH RETURN
    ROUND(
        ((t.close_price - p18.close_price) / p18.close_price) * 100,
        2
    ) as return_18m_pct,

    -- 12-MONTH RETURN (since 21-Jun-2025)
    ROUND(
        ((t.close_price - p12.close_price) / p12.close_price) * 100,
        2
    ) as return_12m_pct

FROM security_info s
JOIN today_prices t ON s.ticker = t.ticker
LEFT JOIN (SELECT * FROM prices_24m_ago WHERE row_num = 1) p24 ON s.ticker = p24.ticker
LEFT JOIN (SELECT * FROM prices_18m_ago WHERE row_num = 1) p18 ON s.ticker = p18.ticker
LEFT JOIN (SELECT * FROM prices_12m_ago WHERE row_num = 1) p12 ON s.ticker = p12.ticker

ORDER BY return_24m_pct DESC;

-- ═══════════════════════════════════════════════════════════════════════════════
-- QUESTION 2: VARIANCE ANALYSIS (Last 6 Months)
-- ═══════════════════════════════════════════════════════════════════════════════
--
-- WHAT: Measure how much daily returns vary (proxy for correlation)
-- HOW: Calculate daily return % and then variance of those returns
-- INTERPRETATION:
--   - High variance = bounces around (risky)
--   - Low variance = stable (safe)
-- ═══════════════════════════════════════════════════════════════════════════════

WITH daily_returns AS (
    SELECT
        ticker,
        trading_date,
        close_price,
        LAG(close_price) OVER (PARTITION BY ticker ORDER BY trading_date) as prev_close,

        -- Daily return = (Today - Yesterday) / Yesterday × 100
        ROUND(
            ((close_price - LAG(close_price) OVER (PARTITION BY ticker ORDER BY trading_date))
             / LAG(close_price) OVER (PARTITION BY ticker ORDER BY trading_date)) * 100,
            4
        ) as daily_return_pct

    FROM daily_stock_prices

    -- Last 6 months only
    WHERE trading_date >= DATE_SUB(
        (SELECT MAX(trading_date) FROM daily_stock_prices),
        INTERVAL 6 MONTH
    )
)

SELECT
    s.ticker,
    s.security_name,
    s.asset_class,

    -- Variance (how spread out the returns are)
    ROUND(VARIANCE(dr.daily_return_pct), 4) as variance,

    -- Standard Deviation (another measure of volatility)
    ROUND(STDDEV_POP(dr.daily_return_pct), 4) as std_deviation,

    -- Average daily return
    ROUND(AVG(dr.daily_return_pct), 4) as avg_daily_return_pct,

    -- Number of data points
    COUNT(*) as trading_days_analyzed

FROM daily_returns dr
JOIN security_info s ON dr.ticker = s.ticker

WHERE dr.daily_return_pct IS NOT NULL

GROUP BY dr.ticker, s.ticker, s.security_name, s.asset_class

ORDER BY variance DESC;  -- Highest variance first (most risky)

-- ═══════════════════════════════════════════════════════════════════════════════
-- QUESTION 3: SIGMA (ANNUALIZED VOLATILITY) - 12 MONTHS
-- ═══════════════════════════════════════════════════════════════════════════════
--
-- WHAT: Annual volatility (σ sigma) = how much price could swing in a year
-- FORMULA: Daily Volatility × √252 (trading days per year)
-- EXAMPLE: σ = 20% means price could swing ±20% in a year
--
-- RISK LEVELS:
--   σ > 25% = HIGH RISK
--   15% < σ < 25% = MODERATE RISK
--   σ < 15% = LOW RISK
-- ═══════════════════════════════════════════════════════════════════════════════

WITH daily_returns AS (
    SELECT
        ticker,
        trading_date,
        close_price,
        LAG(close_price) OVER (PARTITION BY ticker ORDER BY trading_date) as prev_close,

        ROUND(
            ((close_price - LAG(close_price) OVER (PARTITION BY ticker ORDER BY trading_date))
             / LAG(close_price) OVER (PARTITION BY ticker ORDER BY trading_date)) * 100,
            4
        ) as daily_return_pct

    FROM daily_stock_prices

    -- Last 12 months for annual volatility
    WHERE trading_date >= DATE_SUB(
        (SELECT MAX(trading_date) FROM daily_stock_prices),
        INTERVAL 12 MONTH
    )
)

SELECT
    s.ticker,
    s.security_name,
    s.asset_class,

    -- Daily volatility (standard deviation of daily returns)
    ROUND(STDDEV_POP(dr.daily_return_pct), 4) as daily_volatility_pct,

    -- Annualized volatility (SIGMA)
    -- Formula: Daily Vol × √252 ≈ Daily Vol × 15.87
    ROUND(STDDEV_POP(dr.daily_return_pct) * SQRT(252), 2) as annual_volatility_sigma_pct,

    -- Risk classification
    CASE
        WHEN STDDEV_POP(dr.daily_return_pct) * SQRT(252) > 25 THEN 'HIGH RISK'
        WHEN STDDEV_POP(dr.daily_return_pct) * SQRT(252) > 15 THEN 'MODERATE RISK'
        ELSE 'LOW RISK'
    END as risk_level,

    -- Number of trading days analyzed
    COUNT(*) as trading_days

FROM daily_returns dr
JOIN security_info s ON dr.ticker = s.ticker

WHERE dr.daily_return_pct IS NOT NULL

GROUP BY dr.ticker, s.ticker, s.security_name, s.asset_class

ORDER BY annual_volatility_sigma_pct DESC;  -- Highest risk first

-- ═══════════════════════════════════════════════════════════════════════════════
-- QUESTION 4: SHARPE RATIO (Risk-Adjusted Return Quality) - 12 MONTHS
-- ═══════════════════════════════════════════════════════════════════════════════
--
-- WHAT: "Return per unit of risk" - how much return for each unit of risk
-- FORMULA: (Annual Return - Risk-Free Rate) / Annual Volatility
-- RISK-FREE RATE: 2% (US Treasury bonds baseline)
--
-- INTERPRETATION:
--   Sharpe > 1.5 = Excellent (strong risk-adjusted return)
--   Sharpe > 1.0 = Very Good
--   Sharpe > 0.5 = Good
--   Sharpe > 0.2 = Acceptable
--   Sharpe ≤ 0.2 = Poor (questionable investment)
--
-- RECOMMENDATION LEVELS:
--   Sharpe > 0.8 = STRONG BUY
--   Sharpe > 0.5 = BUY
--   Sharpe > 0.2 = HOLD
--   Sharpe ≤ 0.2 = SELL
-- ═══════════════════════════════════════════════════════════════════════════════

WITH daily_returns AS (
    SELECT
        ticker,
        close_price,
        LAG(close_price) OVER (PARTITION BY ticker ORDER BY trading_date) as prev_close,

        ROUND(
            ((close_price - LAG(close_price) OVER (PARTITION BY ticker ORDER BY trading_date))
             / LAG(close_price) OVER (PARTITION BY ticker ORDER BY trading_date)) * 100,
            4
        ) as daily_return_pct,

        trading_date

    FROM daily_stock_prices

    WHERE trading_date >= DATE_SUB(
        (SELECT MAX(trading_date) FROM daily_stock_prices),
        INTERVAL 12 MONTH
    )
)

SELECT
    s.ticker,
    s.security_name,
    s.current_percent as current_allocation_pct,

    -- Expected annual return (daily average × 252 trading days)
    ROUND(AVG(dr.daily_return_pct) * 252, 2) as expected_annual_return_pct,

    -- Annual volatility (sigma)
    ROUND(STDDEV_POP(dr.daily_return_pct) * SQRT(252), 2) as annual_volatility_pct,

    -- Sharpe ratio = (Return - Risk-Free) / Volatility
    -- Risk-Free Rate = 2%
    ROUND(
        (AVG(dr.daily_return_pct) * 252 - 2) / (STDDEV_POP(dr.daily_return_pct) * SQRT(252)),
        4
    ) as sharpe_ratio,

    -- Investment recommendation based on Sharpe ratio
    CASE
        WHEN (AVG(dr.daily_return_pct) * 252 - 2) / (STDDEV_POP(dr.daily_return_pct) * SQRT(252)) > 0.8 THEN 'STRONG BUY'
        WHEN (AVG(dr.daily_return_pct) * 252 - 2) / (STDDEV_POP(dr.daily_return_pct) * SQRT(252)) > 0.5 THEN 'BUY'
        WHEN (AVG(dr.daily_return_pct) * 252 - 2) / (STDDEV_POP(dr.daily_return_pct) * SQRT(252)) > 0.2 THEN 'HOLD'
        ELSE 'SELL'
    END as recommendation

FROM daily_returns dr
JOIN security_info s ON dr.ticker = s.ticker

WHERE dr.daily_return_pct IS NOT NULL

GROUP BY dr.ticker, s.ticker, s.security_name, s.current_percent

ORDER BY sharpe_ratio DESC;  -- Best quality first

-- ═══════════════════════════════════════════════════════════════════════════════
-- QUESTION 5: REBALANCING PROPOSAL
-- ═══════════════════════════════════════════════════════════════════════════════
--
-- BASED ON SHARPE RATIOS FROM Q4:
-- - Holdings with high Sharpe → INCREASE allocation (BUY)
-- - Holdings with low Sharpe → DECREASE allocation (SELL)
-- - Holdings with medium Sharpe → HOLD
--
-- PORTFOLIO: $95,000,000
-- ═══════════════════════════════════════════════════════════════════════════════

-- This is a manual proposal based on Q4 Sharpe ratios
-- Update the proposed_percent values based on your actual Q4 results

SELECT
    s.ticker,
    s.security_name,
    s.current_percent as current_allocation_pct,

    -- EDIT THESE VALUES based on your Q4 Sharpe ratio findings
    CASE
        WHEN s.ticker = 'IXN' THEN 20.0   -- Increase if Sharpe > 1.5
        WHEN s.ticker = 'QQQ' THEN 25.0   -- Increase if Sharpe > 1.0
        WHEN s.ticker = 'GLD' THEN 22.0   -- Maintain or trim slightly
        WHEN s.ticker = 'VNQ' THEN 18.0   -- Increase if underweighted
        WHEN s.ticker = 'IEF' THEN 15.0   -- Reduce if Sharpe < 0.5
    END as proposed_allocation_pct,

    -- Calculate dollar amounts (based on $95M portfolio)
    ROUND(
        (CASE
            WHEN s.ticker = 'IXN' THEN 20.0
            WHEN s.ticker = 'QQQ' THEN 25.0
            WHEN s.ticker = 'GLD' THEN 22.0
            WHEN s.ticker = 'VNQ' THEN 18.0
            WHEN s.ticker = 'IEF' THEN 15.0
        END - s.current_percent) * 95 / 100,
        1
    ) as trade_amount_millions,

    -- Action to take
    CASE
        WHEN CASE
            WHEN s.ticker = 'IXN' THEN 20.0
            WHEN s.ticker = 'QQQ' THEN 25.0
            WHEN s.ticker = 'GLD' THEN 22.0
            WHEN s.ticker = 'VNQ' THEN 18.0
            WHEN s.ticker = 'IEF' THEN 15.0
        END > s.current_percent THEN 'BUY'
        WHEN CASE
            WHEN s.ticker = 'IXN' THEN 20.0
            WHEN s.ticker = 'QQQ' THEN 25.0
            WHEN s.ticker = 'GLD' THEN 22.0
            WHEN s.ticker = 'VNQ' THEN 18.0
            WHEN s.ticker = 'IEF' THEN 15.0
        END < s.current_percent THEN 'SELL'
        ELSE 'HOLD'
    END as action

FROM security_info s

ORDER BY s.ticker;

-- ═══════════════════════════════════════════════════════════════════════════════
-- ADDITIONAL VERIFICATION QUERIES
-- ═══════════════════════════════════════════════════════════════════════════════

-- Check if all tickers have sufficient data
SELECT
    ticker,
    COUNT(*) as total_records,
    COUNT(DISTINCT trading_date) as unique_dates,
    MIN(trading_date) as earliest,
    MAX(trading_date) as latest
FROM daily_stock_prices
GROUP BY ticker
ORDER BY ticker;

-- Check for NULL values
SELECT
    COUNT(*) as null_close_prices,
    COUNT(IF(close_price IS NULL, 1, NULL)) as close_price_nulls,
    COUNT(IF(volume IS NULL, 1, NULL)) as volume_nulls
FROM daily_stock_prices;

-- Check latest prices
SELECT
    ticker,
    MAX(trading_date) as latest_date,
    MAX(close_price) as latest_close,
    MIN(close_price) as min_close_12m,
    MAX(close_price) as max_close_12m
FROM daily_stock_prices
WHERE trading_date >= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 12 MONTH)
GROUP BY ticker
ORDER BY ticker;
