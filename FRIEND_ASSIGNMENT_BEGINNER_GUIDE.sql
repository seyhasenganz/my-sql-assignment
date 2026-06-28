-- ============================================================================
-- FRIEND_ASSIGNMENT_BEGINNER_GUIDE.sql
-- A Beginner-Friendly Guide to Stock Prices Database Queries
-- ============================================================================
-- This file contains simple SQL queries to help you get started with the
-- daily_stock_prices table. Start with these basic queries and work your way up!

-- ============================================================================
-- 1. VIEWING THE TABLE STRUCTURE
-- ============================================================================

-- See the structure of the daily_stock_prices table
DESCRIBE daily_stock_prices;

-- Or use this alternative command
SHOW COLUMNS FROM daily_stock_prices;


-- ============================================================================
-- 2. SIMPLE SELECT QUERIES (VIEWING DATA)
-- ============================================================================

-- View all records in the table (careful: might be a lot of data!)
SELECT * FROM daily_stock_prices LIMIT 10;

-- View only the first 5 records
SELECT * FROM daily_stock_prices LIMIT 5;

-- View specific columns
SELECT trading_date, ticker, close_price FROM daily_stock_prices LIMIT 10;

-- View data for a specific ticker (IXN)
SELECT * FROM daily_stock_prices WHERE ticker = 'IXN' LIMIT 10;

-- View data from a specific date
SELECT * FROM daily_stock_prices WHERE trading_date = '2026-06-18';


-- ============================================================================
-- 3. COUNTING & AGGREGATION
-- ============================================================================

-- Count how many records are in the table
SELECT COUNT(*) as total_records FROM daily_stock_prices;

-- Count records for each ticker
SELECT ticker, COUNT(*) as number_of_records
FROM daily_stock_prices
GROUP BY ticker;

-- Count unique tickers
SELECT COUNT(DISTINCT ticker) as unique_tickers FROM daily_stock_prices;

-- List all unique tickers
SELECT DISTINCT ticker FROM daily_stock_prices ORDER BY ticker;


-- ============================================================================
-- 4. FINDING MIN, MAX, AND AVERAGE VALUES
-- ============================================================================

-- Find the highest closing price ever
SELECT MAX(close_price) as highest_close FROM daily_stock_prices;

-- Find the lowest closing price ever
SELECT MIN(close_price) as lowest_close FROM daily_stock_prices;

-- Find the average closing price for each ticker
SELECT ticker, AVG(close_price) as avg_close
FROM daily_stock_prices
GROUP BY ticker;

-- Find the highest volume traded
SELECT MAX(volume) as highest_volume FROM daily_stock_prices;

-- Find average trading volume for each ticker
SELECT ticker, AVG(volume) as avg_volume
FROM daily_stock_prices
GROUP BY ticker;


-- ============================================================================
-- 5. FILTERING DATA WITH WHERE
-- ============================================================================

-- Find all records where closing price is greater than 100
SELECT trading_date, ticker, close_price
FROM daily_stock_prices
WHERE close_price > 100
LIMIT 20;

-- Find records where volume is very high (over 1 million)
SELECT trading_date, ticker, volume
FROM daily_stock_prices
WHERE volume > 1000000
ORDER BY volume DESC
LIMIT 10;

-- Find records for multiple specific tickers
SELECT * FROM daily_stock_prices
WHERE ticker IN ('IXN', 'GLD')
LIMIT 20;

-- Find records between two dates
SELECT * FROM daily_stock_prices
WHERE trading_date BETWEEN '2026-06-01' AND '2026-06-30'
LIMIT 20;


-- ============================================================================
-- 6. SORTING DATA
-- ============================================================================

-- Sort by closing price (highest first)
SELECT trading_date, ticker, close_price
FROM daily_stock_prices
ORDER BY close_price DESC
LIMIT 10;

-- Sort by trading date (most recent first)
SELECT trading_date, ticker, close_price
FROM daily_stock_prices
ORDER BY trading_date DESC
LIMIT 10;

-- Sort by multiple columns (ticker first, then date)
SELECT trading_date, ticker, close_price
FROM daily_stock_prices
ORDER BY ticker ASC, trading_date DESC
LIMIT 20;


-- ============================================================================
-- 7. PRICE ANALYSIS
-- ============================================================================

-- Calculate price change (difference between open and close)
SELECT
    trading_date,
    ticker,
    open_price,
    close_price,
    (close_price - open_price) as price_change
FROM daily_stock_prices
LIMIT 20;

-- Calculate price change percentage
SELECT
    trading_date,
    ticker,
    open_price,
    close_price,
    ROUND((close_price - open_price) / open_price * 100, 2) as percent_change
FROM daily_stock_prices
LIMIT 20;

-- Find the daily high-low spread
SELECT
    trading_date,
    ticker,
    high_price,
    low_price,
    (high_price - low_price) as daily_spread
FROM daily_stock_prices
ORDER BY daily_spread DESC
LIMIT 10;


-- ============================================================================
-- 8. STATISTICS PER TICKER
-- ============================================================================

-- Get comprehensive statistics for each ticker
SELECT
    ticker,
    COUNT(*) as trading_days,
    ROUND(MIN(low_price), 2) as lowest_price,
    ROUND(MAX(high_price), 2) as highest_price,
    ROUND(AVG(close_price), 2) as avg_close,
    ROUND(AVG(volume), 0) as avg_volume
FROM daily_stock_prices
GROUP BY ticker
ORDER BY ticker;


-- ============================================================================
-- 9. ADVANCED FILTERING
-- ============================================================================

-- Find days where stock closed higher than opened (bullish days)
SELECT trading_date, ticker, open_price, close_price
FROM daily_stock_prices
WHERE close_price > open_price
LIMIT 20;

-- Find days where stock closed lower than opened (bearish days)
SELECT trading_date, ticker, open_price, close_price
FROM daily_stock_prices
WHERE close_price < open_price
LIMIT 20;


-- ============================================================================
-- 10. TIME-BASED QUERIES
-- ============================================================================

-- Get the latest record for each ticker
SELECT * FROM daily_stock_prices
ORDER BY trading_date DESC
LIMIT 10;

-- Find all data from June 2026
SELECT *
FROM daily_stock_prices
WHERE YEAR(trading_date) = 2026 AND MONTH(trading_date) = 6
LIMIT 20;


-- ============================================================================
-- TIPS & PRACTICE EXERCISES
-- ============================================================================

/*
BEGINNER TIPS:
1. Always use LIMIT when exploring to avoid overwhelming output
2. Use DESCRIBE to understand table structure
3. Start simple - SELECT * before adding conditions
4. Use WHERE to filter data
5. Use ORDER BY to sort results
6. Use GROUP BY with aggregate functions (COUNT, SUM, AVG, MIN, MAX)
7. Remember: SQL keywords are case-insensitive, but data values are not
8. Test queries step by step, don't build complex queries all at once

PRACTICE:
1. Find the average closing price for IXN
2. Find the highest volume day overall
3. Count how many tickers exist in the database
4. Find all records where close > 150
5. Sort all IXN records by date (newest first)
*/
