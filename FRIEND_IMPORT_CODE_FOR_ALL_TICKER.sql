-- ============================================================================
-- FRIEND_IMPORT_CODE_FOR_ALL_TICKER.sql
-- SQL Code to Import Stock Price Data for All Tickers
-- ============================================================================
-- This file provides the structure and examples for importing data
-- for multiple stock tickers. Follow the patterns shown here!

-- ============================================================================
-- OVERVIEW
-- ============================================================================
/*
This file helps you understand how to import data for different tickers.
The main approach is to use the aligned_stock_prices.sql file which
contains pre-formatted INSERT statements for all available tickers.

Current tickers in the database:
- IXN (Technology Index)
- GLD (Gold ETF)
- And others...

You can expand this to include additional tickers by:
1. Using the import patterns shown below
2. Preparing CSV files for each ticker
3. Using batch INSERT statements
*/

-- ============================================================================
-- STEP 1: VERIFY TABLE STRUCTURE
-- ============================================================================

-- Check that the table exists
SHOW TABLES;

-- View table structure
DESCRIBE daily_stock_prices;

-- Clear previous data (if needed)
-- DELETE FROM daily_stock_prices;
-- TRUNCATE TABLE daily_stock_prices;


-- ============================================================================
-- STEP 2: IMPORT MAIN DATA FILE (RECOMMENDED METHOD)
-- ============================================================================

-- This imports all ticker data from the pre-formatted SQL file
-- This is the easiest and most reliable method
SOURCE aligned_stock_prices.sql;

-- Verify import was successful
SELECT COUNT(*) as total_records FROM daily_stock_prices;
SELECT DISTINCT ticker FROM daily_stock_prices ORDER BY ticker;
SELECT ticker, COUNT(*) as record_count FROM daily_stock_prices GROUP BY ticker;


-- ============================================================================
-- STEP 3: IMPORT ADDITIONAL SINGLE TICKER (IF NEEDED)
-- ============================================================================

/*
If you want to add a single new ticker, follow this pattern:
1. Prepare data in the correct format
2. Create a separate SQL file or use INSERT statements
3. Run the import

Example for a new ticker 'AAPL':
*/

-- Example: Import data for AAPL (Apple)
-- Save this in a file called aapl_data.sql or run directly:

/*
INSERT INTO daily_stock_prices (trading_date, ticker, open_price, high_price, low_price, close_price, adj_close, volume)
VALUES
  ('2026-06-18', 'AAPL', 225.50, 227.35, 224.80, 226.75, 226.75, 52500000),
  ('2026-06-17', 'AAPL', 224.25, 226.50, 223.90, 225.10, 225.10, 48750000),
  ('2026-06-16', 'AAPL', 226.10, 227.80, 225.45, 225.90, 225.90, 45200000);
*/

-- To import from a file:
-- SOURCE aapl_data.sql;


-- ============================================================================
-- STEP 4: IMPORT MULTIPLE TICKERS FROM CSV (BATCH METHOD)
-- ============================================================================

/*
If you have a CSV file with multiple tickers, use this approach:

CSV Format (with header):
trading_date,ticker,open_price,high_price,low_price,close_price,adj_close,volume
2026-06-18,AAPL,225.50,227.35,224.80,226.75,226.75,52500000
2026-06-17,AAPL,224.25,226.50,223.90,225.10,225.10,48750000
2026-06-18,MSFT,435.80,438.50,434.20,437.25,437.25,28300000
*/

-- Import from CSV:
LOAD DATA LOCAL INFILE '/path/to/all_tickers.csv'
INTO TABLE daily_stock_prices
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS
(trading_date, ticker, open_price, high_price, low_price, close_price, adj_close, volume);

-- Verify:
SELECT COUNT(*) FROM daily_stock_prices;


-- ============================================================================
-- STEP 5: VALIDATE TICKER DATA
-- ============================================================================

-- List all unique tickers in database
SELECT DISTINCT ticker FROM daily_stock_prices ORDER BY ticker;

-- Count records per ticker
SELECT ticker, COUNT(*) as record_count
FROM daily_stock_prices
GROUP BY ticker
ORDER BY ticker;

-- Get data statistics for all tickers
SELECT
    ticker,
    COUNT(*) as days,
    MIN(trading_date) as start_date,
    MAX(trading_date) as end_date,
    ROUND(MIN(low_price), 2) as low,
    ROUND(MAX(high_price), 2) as high,
    ROUND(AVG(close_price), 2) as avg_close
FROM daily_stock_prices
GROUP BY ticker
ORDER BY ticker;


-- ============================================================================
-- STEP 6: SAMPLE QUERIES BY TICKER
-- ============================================================================

-- View recent prices for all tickers
SELECT ticker, trading_date, open_price, high_price, low_price, close_price, volume
FROM daily_stock_prices
WHERE ROW_NUMBER() OVER (PARTITION BY ticker ORDER BY trading_date DESC) <= 5
ORDER BY ticker, trading_date DESC;

-- Compare last close prices across all tickers
SELECT
    ticker,
    trading_date,
    close_price
FROM daily_stock_prices
WHERE ROW_NUMBER() OVER (PARTITION BY ticker ORDER BY trading_date DESC) = 1
ORDER BY ticker;

-- Performance metrics for each ticker
SELECT
    ticker,
    ROUND(MIN(close_price), 2) as lowest_price,
    ROUND(MAX(close_price), 2) as highest_price,
    ROUND(AVG(close_price), 2) as avg_price,
    ROUND((MAX(close_price) - MIN(close_price)) / MIN(close_price) * 100, 2) as total_return_percent
FROM daily_stock_prices
GROUP BY ticker
ORDER BY ticker;


-- ============================================================================
-- STEP 7: WORKING WITH SPECIFIC TICKERS
-- ============================================================================

-- All IXN records
SELECT * FROM daily_stock_prices WHERE ticker = 'IXN' ORDER BY trading_date DESC LIMIT 20;

-- All GLD records
SELECT * FROM daily_stock_prices WHERE ticker = 'GLD' ORDER BY trading_date DESC LIMIT 20;

-- Compare two specific tickers on the same day
SELECT
    a.trading_date,
    'IXN' as ticker1,
    ROUND(a.close_price, 2) as ixn_close,
    'GLD' as ticker2,
    ROUND(b.close_price, 2) as gld_close
FROM daily_stock_prices a
JOIN daily_stock_prices b
ON a.trading_date = b.trading_date
AND a.ticker = 'IXN'
AND b.ticker = 'GLD'
ORDER BY a.trading_date DESC
LIMIT 20;


-- ============================================================================
-- STEP 8: BULK INSERT EXAMPLE (FOR SCRIPTING)
-- ============================================================================

/*
If you're generating INSERT statements programmatically, use this pattern:

INSERT INTO daily_stock_prices (trading_date, ticker, open_price, high_price, low_price, close_price, adj_close, volume)
VALUES
(date1, 'TICKER1', open1, high1, low1, close1, adj_close1, vol1),
(date2, 'TICKER1', open2, high2, low2, close2, adj_close2, vol2),
(date3, 'TICKER2', open3, high3, low3, close3, adj_close3, vol3),
-- ... more rows ...
;

Key points:
- Use NULL for unknown values (or provide a default)
- Date must be YYYY-MM-DD format
- Prices can have up to 2 decimal places
- Volume should be integer
- This approach is faster than individual inserts
*/


-- ============================================================================
-- STEP 9: TROUBLESHOOTING MULTI-TICKER IMPORTS
-- ============================================================================

-- Problem: Duplicate entries
-- Solution: Check for duplicates
SELECT ticker, trading_date, COUNT(*)
FROM daily_stock_prices
GROUP BY ticker, trading_date
HAVING COUNT(*) > 1;

-- Problem: Missing tickers
-- Solution: List expected vs actual
SELECT DISTINCT ticker FROM daily_stock_prices ORDER BY ticker;

-- Problem: Data type errors
-- Solution: Check data types
SELECT
    'trading_date' as field,
    COUNT(*) as rows,
    COUNT(CASE WHEN trading_date IS NULL THEN 1 END) as nulls
FROM daily_stock_prices
UNION ALL
SELECT
    'ticker',
    COUNT(*),
    COUNT(CASE WHEN ticker IS NULL THEN 1 END)
FROM daily_stock_prices
UNION ALL
SELECT
    'close_price',
    COUNT(*),
    COUNT(CASE WHEN close_price IS NULL THEN 1 END)
FROM daily_stock_prices;

-- Problem: Price outliers
-- Solution: Check ranges
SELECT
    ticker,
    MIN(close_price) as min,
    MAX(close_price) as max,
    AVG(close_price) as avg
FROM daily_stock_prices
GROUP BY ticker;


-- ============================================================================
-- STEP 10: POST-IMPORT OPERATIONS
-- ============================================================================

-- Refresh indexes (for performance)
OPTIMIZE TABLE daily_stock_prices;

-- Count final records
SELECT COUNT(*) as total_records FROM daily_stock_prices;

-- Summary by ticker
SELECT
    ticker,
    COUNT(*) as total_records,
    MIN(trading_date) as first_date,
    MAX(trading_date) as last_date,
    COUNT(DISTINCT trading_date) as unique_days
FROM daily_stock_prices
GROUP BY ticker
ORDER BY ticker;

-- Data quality check
SELECT
    'Total Records' as metric,
    COUNT(*) as value
FROM daily_stock_prices
UNION ALL
SELECT 'Unique Tickers', COUNT(DISTINCT ticker)
FROM daily_stock_prices
UNION ALL
SELECT 'Unique Dates', COUNT(DISTINCT trading_date)
FROM daily_stock_prices
UNION ALL
SELECT 'NULL close_prices', COUNT(CASE WHEN close_price IS NULL THEN 1 END)
FROM daily_stock_prices
UNION ALL
SELECT 'NULL tickers', COUNT(CASE WHEN ticker IS NULL THEN 1 END)
FROM daily_stock_prices;


-- ============================================================================
-- STEP 11: ADDING NEW TICKERS LATER
-- ============================================================================

/*
When you want to add a new ticker (e.g., MSFT):

1. Prepare data file: msft_data.sql or msft_data.csv

2. If using SQL file:
   SOURCE msft_data.sql;

3. If using CSV file:
   LOAD DATA LOCAL INFILE '/path/to/msft_data.csv'
   INTO TABLE daily_stock_prices
   FIELDS TERMINATED BY ','
   IGNORE 1 ROWS
   (trading_date, ticker, open_price, high_price, low_price, close_price, adj_close, volume);

4. Verify:
   SELECT COUNT(*) FROM daily_stock_prices WHERE ticker = 'MSFT';

5. Compare with other tickers:
   SELECT ticker, COUNT(*) FROM daily_stock_prices GROUP BY ticker;
*/


-- ============================================================================
-- QUICK REFERENCE - COMMON OPERATIONS
-- ============================================================================

/*
Import all data:
  SOURCE aligned_stock_prices.sql;

View all tickers:
  SELECT DISTINCT ticker FROM daily_stock_prices;

Count by ticker:
  SELECT ticker, COUNT(*) FROM daily_stock_prices GROUP BY ticker;

Get recent prices:
  SELECT * FROM daily_stock_prices ORDER BY trading_date DESC LIMIT 30;

Compare tickers:
  SELECT ticker, trading_date, close_price FROM daily_stock_prices WHERE ticker IN ('IXN', 'GLD');

Delete all data:
  DELETE FROM daily_stock_prices;

Check data quality:
  SELECT COUNT(*), COUNT(DISTINCT ticker), COUNT(DISTINCT trading_date) FROM daily_stock_prices;
*/

-- ============================================================================
-- For more information, see:
-- - FRIEND_DATA_IMPORT_GUIDE.md (detailed import instructions)
-- - FRIEND_HOW_TO_RUN_IMPORT.md (quick start guide)
-- - FRIEND_STEP_BY_STEP_GUIDE.md (complete tutorial)
-- ============================================================================
