-- =====================================================
-- DATA LOADING TEMPLATE
-- =====================================================
-- This file provides examples of how to load pricing data
-- You'll need to adapt paths to your local file system

-- =====================================================
-- METHOD 1: LOAD DATA INFILE (Recommended - Fastest)
-- =====================================================
-- Before using this method:
-- 1. Make sure MySQL secure_file_priv setting allows file reading
-- 2. Check: SHOW VARIABLES LIKE 'secure_file_priv';
-- 3. Place CSV files in the specified directory (usually /var/lib/mysql-files/)

-- Example 1: Load IXN Data
-- LOAD DATA INFILE '/var/lib/mysql-files/IXN.csv'
-- INTO TABLE investment_portfolio.pricing_daily
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS
-- (price_date, open_price, high_price, low_price, close_price, adjusted_close, volume)
-- SET ticker = 'IXN', price_type = 'Adjusted';

-- Example 2: Load QQQ Data
-- LOAD DATA INFILE '/var/lib/mysql-files/QQQ.csv'
-- INTO TABLE investment_portfolio.pricing_daily
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS
-- (price_date, open_price, high_price, low_price, close_price, adjusted_close, volume)
-- SET ticker = 'QQQ', price_type = 'Adjusted';

-- Example 3: Load IEF Data
-- LOAD DATA INFILE '/var/lib/mysql-files/IEF.csv'
-- INTO TABLE investment_portfolio.pricing_daily
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS
-- (price_date, open_price, high_price, low_price, close_price, adjusted_close, volume)
-- SET ticker = 'IEF', price_type = 'Adjusted';

-- Example 4: Load VNQ Data
-- LOAD DATA INFILE '/var/lib/mysql-files/VNQ.csv'
-- INTO TABLE investment_portfolio.pricing_daily
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS
-- (price_date, open_price, high_price, low_price, close_price, adjusted_close, volume)
-- SET ticker = 'VNQ', price_type = 'Adjusted';

-- Example 5: Load GLD Data
-- LOAD DATA INFILE '/var/lib/mysql-files/GLD.csv'
-- INTO TABLE investment_portfolio.pricing_daily
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS
-- (price_date, open_price, high_price, low_price, close_price, adjusted_close, volume)
-- SET ticker = 'GLD', price_type = 'Adjusted';

-- =====================================================
-- METHOD 2: MySQL Workbench GUI Import (Easiest)
-- =====================================================
-- 1. In MySQL Workbench, right-click on pricing_daily table
-- 2. Select "Table Data Import Wizard"
-- 3. Browse to your CSV file
-- 4. Follow the wizard:
--    - Column mapping:
--      Column 1 (Date) → price_date
--      Column 2 (Open) → open_price
--      Column 3 (High) → high_price
--      Column 4 (Low) → low_price
--      Column 5 (Close) → close_price
--      Column 6 (Adj Close) → adjusted_close
--      Column 7 (Volume) → volume
--    - Before import: Edit column data types to match table
--    - Add ticker value for each import (IXN, QQQ, IEF, VNQ, GLD)
-- 5. Import and verify

-- =====================================================
-- METHOD 3: Manual INSERT Statements (For Testing)
-- =====================================================
-- Sample data structure - replace with actual values from your CSV

INSERT INTO investment_portfolio.pricing_daily
(ticker, price_date, open_price, high_price, low_price, close_price, adjusted_close, volume, price_type)
VALUES
-- IXN Sample Data
('IXN', '2024-06-13', 200.50, 201.25, 199.75, 200.80, 200.80, 1500000, 'Adjusted'),
('IXN', '2024-06-12', 199.75, 200.50, 199.00, 200.10, 200.10, 1400000, 'Adjusted'),
('IXN', '2024-06-11', 200.25, 200.75, 199.50, 199.95, 199.95, 1350000, 'Adjusted'),
-- QQQ Sample Data
('QQQ', '2024-06-13', 425.75, 427.50, 425.00, 426.80, 426.80, 2500000, 'Adjusted'),
('QQQ', '2024-06-12', 424.50, 426.25, 424.00, 425.75, 425.75, 2400000, 'Adjusted'),
('QQQ', '2024-06-11', 425.00, 425.50, 423.75, 424.50, 424.50, 2350000, 'Adjusted'),
-- IEF Sample Data
('IEF', '2024-06-13', 95.50, 96.00, 95.25, 95.80, 95.80, 800000, 'Adjusted'),
('IEF', '2024-06-12', 95.75, 96.25, 95.50, 95.65, 95.65, 750000, 'Adjusted'),
('IEF', '2024-06-11', 95.60, 95.90, 95.25, 95.75, 95.75, 800000, 'Adjusted'),
-- VNQ Sample Data
('VNQ', '2024-06-13', 215.25, 216.50, 214.75, 216.00, 216.00, 1200000, 'Adjusted'),
('VNQ', '2024-06-12', 214.75, 215.75, 214.00, 215.25, 215.25, 1150000, 'Adjusted'),
('VNQ', '2024-06-11', 215.00, 215.50, 213.75, 214.75, 214.75, 1100000, 'Adjusted'),
-- GLD Sample Data
('GLD', '2024-06-13', 175.80, 176.50, 175.25, 176.00, 176.00, 1500000, 'Adjusted'),
('GLD', '2024-06-12', 175.50, 176.25, 175.00, 175.80, 175.80, 1450000, 'Adjusted'),
('GLD', '2024-06-11', 175.25, 175.75, 174.75, 175.50, 175.50, 1500000, 'Adjusted');

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- After loading data, run these verification queries

-- Check total records per ticker
SELECT
    ticker,
    COUNT(*) as record_count,
    MIN(price_date) as earliest_date,
    MAX(price_date) as latest_date,
    DATEDIFF(MAX(price_date), MIN(price_date)) as days_span
FROM investment_portfolio.pricing_daily
GROUP BY ticker
ORDER BY ticker;

-- Expected output: ~750 records per ticker (3 years of trading days)

-- Check for missing data (gaps in dates)
SELECT
    ticker,
    price_date,
    LAG(price_date) OVER (PARTITION BY ticker ORDER BY price_date) as prev_date
FROM investment_portfolio.pricing_daily
WHERE DATEDIFF(price_date, LAG(price_date) OVER (PARTITION BY ticker ORDER BY price_date)) > 1
ORDER BY ticker, price_date
LIMIT 10;

-- Should be empty or only show weekends/holidays

-- Check for NULL values
SELECT
    'price_date' as column_name,
    COUNT(*) - COUNT(price_date) as null_count
FROM investment_portfolio.pricing_daily
UNION ALL
SELECT 'adjusted_close', COUNT(*) - COUNT(adjusted_close) FROM investment_portfolio.pricing_daily
UNION ALL
SELECT 'volume', COUNT(*) - COUNT(volume) FROM investment_portfolio.pricing_daily;

-- Should show 0 NULL values for important columns

-- Check price range reasonableness
SELECT
    ticker,
    ROUND(MIN(adjusted_close), 2) as min_price,
    ROUND(MAX(adjusted_close), 2) as max_price,
    ROUND(AVG(adjusted_close), 2) as avg_price,
    ROUND(MAX(adjusted_close) - MIN(adjusted_close), 2) as price_range
FROM investment_portfolio.pricing_daily
GROUP BY ticker
ORDER BY ticker;

-- Verify all data loaded successfully before proceeding to analysis

-- =====================================================
-- OPTIONAL: Create Indexed Views for Performance
-- =====================================================

-- This can speed up analysis queries significantly
-- Create a summary table with daily returns pre-calculated

CREATE TABLE pricing_daily_returns AS
SELECT
    ticker,
    price_date,
    adjusted_close,
    LAG(adjusted_close) OVER (PARTITION BY ticker ORDER BY price_date) as prev_price,
    ROUND(
        ((adjusted_close - LAG(adjusted_close) OVER (PARTITION BY ticker ORDER BY price_date))
         / LAG(adjusted_close) OVER (PARTITION BY ticker ORDER BY price_date)) * 100,
        4
    ) as daily_return_pct
FROM investment_portfolio.pricing_daily
WHERE price_date >= DATE_SUB(CURDATE(), INTERVAL 24 MONTH);

-- Add index for faster queries
CREATE INDEX idx_returns_ticker_date ON pricing_daily_returns(ticker, price_date);

-- Now you can use this table for faster analysis queries
SELECT * FROM pricing_daily_returns LIMIT 10;

-- =====================================================
-- TROUBLESHOOTING
-- =====================================================

-- Issue: "Access denied for user when using LOAD DATA INFILE"
-- Solution: Check secure_file_priv setting
SHOW VARIABLES LIKE 'secure_file_priv';
-- If NULL: File loading disabled. Use GUI method instead.
-- If path: Place CSV files in that directory

-- Issue: "Duplicate entry" error
-- Solution: Clear table before reloading
DELETE FROM investment_portfolio.pricing_daily;
-- Then reload data

-- Issue: "Column count doesn't match"
-- Solution: Verify CSV has 7 columns: Date, Open, High, Low, Close, Adj Close, Volume
-- Check column order matches INSERT statement

-- Issue: "Date format error"
-- Solution: CSV dates should be in YYYY-MM-DD format
-- If different format: Use STR_TO_DATE() in INSERT statement

-- Example with different date format:
-- INSERT INTO pricing_daily (..., price_date, ...)
-- VALUES (..., STR_TO_DATE('06/13/2024', '%m/%d/%Y'), ...);

-- =====================================================
-- CLEAN UP (If needed)
-- =====================================================

-- Remove test data
-- DELETE FROM investment_portfolio.pricing_daily WHERE ticker = 'IXN';
-- DELETE FROM investment_portfolio.pricing_daily WHERE ticker = 'QQQ';
-- DELETE FROM investment_portfolio.pricing_daily WHERE ticker = 'IEF';
-- DELETE FROM investment_portfolio.pricing_daily WHERE ticker = 'VNQ';
-- DELETE FROM investment_portfolio.pricing_daily WHERE ticker = 'GLD';

-- Drop and recreate returns table if needed
-- DROP TABLE IF EXISTS pricing_daily_returns;
