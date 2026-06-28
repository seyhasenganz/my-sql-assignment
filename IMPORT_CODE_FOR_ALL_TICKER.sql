-- ═══════════════════════════════════════════════════════════════════════════════
-- IMPORT CODE FOR All_ticker.csv
-- Direct Copy-Paste Ready for MySQL Workbench
-- ═══════════════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════════════════
-- STEP 1: CREATE DATABASE AND TABLES
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE DATABASE IF NOT EXISTS portfolio_db;
USE portfolio_db;

-- Drop tables if they exist
DROP TABLE IF EXISTS daily_stock_prices;
DROP TABLE IF EXISTS security_info;

-- Create the daily prices table
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

    INDEX idx_ticker_date (ticker, trading_date),
    INDEX idx_date (trading_date)
);

-- Create security info table
CREATE TABLE security_info (
    ticker           VARCHAR(10) PRIMARY KEY,
    security_name    VARCHAR(100) NOT NULL,
    current_percent  DECIMAL(5, 2) NOT NULL,
    asset_class      VARCHAR(50) NOT NULL,
    portfolio_value  DECIMAL(15, 2)
);

-- Insert ticker information
INSERT INTO security_info (ticker, security_name, current_percent, asset_class, portfolio_value) VALUES
('IXN', 'iShares Global Tech ETF', 17.5, 'Equity', 16.625),
('QQQ', 'NASDAQ 100', 22.1, 'Equity', 20.995),
('IEF', 'iShares 7-10 Year Treasury Bond ETF', 28.5, 'Fixed Income', 27.075),
('VNQ', 'Vanguard Real Estate ETF', 8.9, 'Real Assets', 8.455),
('GLD', 'SPDR Gold Shares', 23.0, 'Commodities', 21.85);

-- ═══════════════════════════════════════════════════════════════════════════════
-- STEP 2: IMPORT DATA FROM CSV
-- ═══════════════════════════════════════════════════════════════════════════════
--
-- IMPORTANT: Change the file path below to match your actual file location
--
-- Examples:
--   Windows: C:/Users/YourName/Documents/All_ticker.csv
--   Mac: /Users/YourName/Documents/All_ticker.csv
--   Linux: /home/username/Documents/All_ticker.csv
--
-- Always use FORWARD SLASHES (/) even on Windows!
-- ═══════════════════════════════════════════════════════════════════════════════

-- METHOD 1: LOAD DATA LOCAL INFILE (RECOMMENDED - Fastest)
-- Change 'C:/path/to/All_ticker.csv' to your actual file path

LOAD DATA LOCAL INFILE 'C:/path/to/All_ticker.csv'
INTO TABLE portfolio_db.daily_stock_prices
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@trading_date, ticker, open_price, high_price, low_price, close_price, adj_close, @volume)
SET
    trading_date = STR_TO_DATE(@trading_date, '%d-%b-%y'),
    volume = CAST(REPLACE(@volume, ',', '') AS UNSIGNED);

-- ═══════════════════════════════════════════════════════════════════════════════
-- VERIFICATION QUERIES - Run these to confirm data imported correctly
-- ═══════════════════════════════════════════════════════════════════════════════

-- Check 1: Total records
SELECT
    COUNT(*) as total_records,
    'Should be ~2500 rows' as expected
FROM daily_stock_prices;

-- Check 2: Records per ticker
SELECT
    ticker,
    COUNT(*) as record_count,
    MIN(trading_date) as earliest_date,
    MAX(trading_date) as latest_date,
    'Should be ~502 per ticker' as expected
FROM daily_stock_prices
GROUP BY ticker
ORDER BY ticker;

-- Check 3: Date range
SELECT
    MIN(trading_date) as earliest_date,
    MAX(trading_date) as latest_date,
    COUNT(DISTINCT trading_date) as unique_trading_days,
    'Should be ~502 unique trading days' as expected
FROM daily_stock_prices;

-- Check 4: Sample data (first 10 rows)
SELECT * FROM daily_stock_prices LIMIT 10;

-- Check 5: All 5 tickers present
SELECT DISTINCT ticker FROM daily_stock_prices ORDER BY ticker;

-- Check 6: Volume data (verify commas were removed)
SELECT
    ticker,
    COUNT(*) as total_rows,
    MIN(volume) as min_volume,
    MAX(volume) as max_volume,
    'Should be numbers, not text' as expected
FROM daily_stock_prices
WHERE volume IS NOT NULL
GROUP BY ticker
ORDER BY ticker;

-- ═══════════════════════════════════════════════════════════════════════════════
-- IF LOAD DATA DOESN'T WORK - METHOD 2: ALTERNATIVE LOAD DATA
-- ═══════════════════════════════════════════════════════════════════════════════
-- Try this if the first LOAD DATA command fails
-- Change file path to match your location

/*
LOAD DATA LOCAL INFILE 'C:/path/to/All_ticker.csv'
INTO TABLE daily_stock_prices
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@trading_date, ticker, open_price, high_price, low_price, close_price, adj_close, @volume)
SET
    trading_date = STR_TO_DATE(@trading_date, '%d-%b-%y'),
    volume = IF(@volume = '' OR @volume IS NULL, NULL, CAST(REPLACE(@volume, ',', '') AS UNSIGNED));
*/

-- ═══════════════════════════════════════════════════════════════════════════════
-- IF BOTH METHODS FAIL - METHOD 3: ENABLE LOCAL INFILE
-- ═══════════════════════════════════════════════════════════════════════════════
-- Run this if you get "LOAD DATA LOCAL is disabled" error

/*
SET GLOBAL local_infile = 1;

-- Then try the LOAD DATA command again
LOAD DATA LOCAL INFILE 'C:/path/to/All_ticker.csv'
INTO TABLE portfolio_db.daily_stock_prices
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@trading_date, ticker, open_price, high_price, low_price, close_price, adj_close, @volume)
SET
    trading_date = STR_TO_DATE(@trading_date, '%d-%b-%y'),
    volume = CAST(REPLACE(@volume, ',', '') AS UNSIGNED);
*/

-- ═══════════════════════════════════════════════════════════════════════════════
-- TROUBLESHOOTING QUERIES
-- ═══════════════════════════════════════════════════════════════════════════════

-- If data didn't import, check if table is empty
-- SELECT COUNT(*) FROM daily_stock_prices;

-- Check for NULL values
-- SELECT
--     COUNT(IF(trading_date IS NULL, 1, NULL)) as null_dates,
--     COUNT(IF(ticker IS NULL, 1, NULL)) as null_tickers,
--     COUNT(IF(close_price IS NULL, 1, NULL)) as null_close_prices,
--     COUNT(IF(volume IS NULL, 1, NULL)) as null_volumes
-- FROM daily_stock_prices;

-- Check latest data
-- SELECT * FROM daily_stock_prices ORDER BY trading_date DESC LIMIT 10;

-- ═══════════════════════════════════════════════════════════════════════════════
-- EXAMPLE RESULTS EXPECTED
-- ═══════════════════════════════════════════════════════════════════════════════

-- After successful import, you should see:
--
-- Check 1 Result:
--   total_records: 2500 (approximately)
--
-- Check 2 Result:
--   GLD | 502 | 2024-06-21 | 2026-06-19
--   IEF | 502 | 2024-06-21 | 2026-06-19
--   IXN | 502 | 2024-06-21 | 2026-06-19
--   QQQ | 502 | 2024-06-21 | 2026-06-19
--   VNQ | 502 | 2024-06-21 | 2026-06-19
--
-- Check 3 Result:
--   earliest_date: 2024-06-21
--   latest_date: 2026-06-19
--   unique_trading_days: 502
--
-- Check 5 Result:
--   GLD
--   IEF
--   IXN
--   QQQ
--   VNQ
--
-- Check 6 Result (Sample):
--   ticker | total_rows | min_volume | max_volume
--   GLD    | 502        | 100000     | 5000000
--   IEF    | 502        | 50000      | 2000000
--   IXN    | 502        | 100000     | 4000000
--   QQQ    | 502        | 200000     | 6000000
--   VNQ    | 502        | 150000     | 3000000

-- ═══════════════════════════════════════════════════════════════════════════════
-- SUCCESS! Data is now ready for analysis
-- ═══════════════════════════════════════════════════════════════════════════════
-- Now run the queries from: FRIEND_SQL_FOR_REAL_DATA.sql
