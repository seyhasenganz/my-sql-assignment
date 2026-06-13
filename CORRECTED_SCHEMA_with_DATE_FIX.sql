-- ===================================
-- CORRECTED SCHEMA WITH PROPER DATE HANDLING
-- ===================================
-- This script fixes the date format issue by using STR_TO_DATE()
-- with explicit DD-MM-YY format specification
--
-- Date Format: DD-MM-YY (e.g., '12-06-26' = 12th June 2026)
-- MySQL Format Code: '%d-%m-%y'
-- ===================================

USE invest_portfolio;

-- Drop old table with scrambled dates
DROP TABLE IF EXISTS pricing_daily;

-- Create new pricing_daily table
CREATE TABLE pricing_daily (
    date       DATE  NOT NULL,
    ticker     VARCHAR(3) NOT NULL,
    price_type VARCHAR(10) NOT NULL,
    value      NUMERIC(11,2) NOT NULL,

    PRIMARY KEY (date, ticker, price_type),
    INDEX idx_ticker_date (ticker, date),
    INDEX idx_price_type (price_type)
);

-- ===================================
-- INSERT DATA WITH CORRECT DATE CONVERSION
-- ===================================
-- Use STR_TO_DATE() to explicitly parse DD-MM-YY format
-- This replaces the ~15,000+ INSERT statements in the original file
--
-- IMPORTANT: If you have the original CREATE_SCHEMA_invest_portfolio.txt,
-- you need to replace all lines like:
--   INSERT INTO pricing_daily_new(date,ticker,price_type,value) VALUES ('12-06-26','IXN','Open',138.5);
-- with:
--   INSERT INTO pricing_daily(date,ticker,price_type,value) VALUES (STR_TO_DATE('12-06-26','%d-%m-%y'),'IXN','Open',138.5);
--
-- See GENERATION_INSTRUCTIONS.txt for how to auto-convert the file

-- Sample data to verify the fix (first 6 days of IXN):
INSERT INTO pricing_daily(date,ticker,price_type,value) VALUES (STR_TO_DATE('12-06-26','%d-%m-%y'),'IXN','Open',138.5);
INSERT INTO pricing_daily(date,ticker,price_type,value) VALUES (STR_TO_DATE('12-06-26','%d-%m-%y'),'IXN','High',140.48);
INSERT INTO pricing_daily(date,ticker,price_type,value) VALUES (STR_TO_DATE('12-06-26','%d-%m-%y'),'IXN','Low',137.6);
INSERT INTO pricing_daily(date,ticker,price_type,value) VALUES (STR_TO_DATE('12-06-26','%d-%m-%y'),'IXN','Close',139.73);
INSERT INTO pricing_daily(date,ticker,price_type,value) VALUES (STR_TO_DATE('12-06-26','%d-%m-%y'),'IXN','Adj Close',139.73);
INSERT INTO pricing_daily(date,ticker,price_type,value) VALUES (STR_TO_DATE('12-06-26','%d-%m-%y'),'IXN','Volume',186178);

INSERT INTO pricing_daily(date,ticker,price_type,value) VALUES (STR_TO_DATE('11-06-26','%d-%m-%y'),'IXN','Open',134.3);
INSERT INTO pricing_daily(date,ticker,price_type,value) VALUES (STR_TO_DATE('11-06-26','%d-%m-%y'),'IXN','High',139.39);
INSERT INTO pricing_daily(date,ticker,price_type,value) VALUES (STR_TO_DATE('11-06-26','%d-%m-%y'),'IXN','Low',133.58);
INSERT INTO pricing_daily(date,ticker,price_type,value) VALUES (STR_TO_DATE('11-06-26','%d-%m-%y'),'IXN','Close',139.14);
INSERT INTO pricing_daily(date,ticker,price_type,value) VALUES (STR_TO_DATE('11-06-26','%d-%m-%y'),'IXN','Adj Close',139.14);
INSERT INTO pricing_daily(date,ticker,price_type,value) VALUES (STR_TO_DATE('11-06-26','%d-%m-%y'),'IXN','Volume',467800);

-- ... (Insert all remaining rows with STR_TO_DATE conversion) ...
-- Total: 15,060 rows (6 price types × 5 tickers × 502 unique dates)

-- ===================================
-- VERIFICATION QUERIES (Run after loading data)
-- ===================================

-- Query 1: Verify date range
-- Expected after fix: MIN ~2024-06-12, MAX ~2026-06-12, COUNT ~502
-- SELECT MIN(date), MAX(date), COUNT(DISTINCT date) FROM pricing_daily;

-- Query 2: Verify data density (should have 30 rows per date)
-- SELECT date, COUNT(*) as row_count
-- FROM pricing_daily
-- GROUP BY date
-- ORDER BY date DESC
-- LIMIT 10;

-- Query 3: Check trading days in 6-month window (should be 126-130, not 5)
-- WITH recent_data AS (
--     SELECT DISTINCT date
--     FROM pricing_daily
--     WHERE date >= DATE_SUB((SELECT MAX(date) FROM pricing_daily), INTERVAL 6 MONTH)
-- )
-- SELECT COUNT(*) as trading_days_6m FROM recent_data;
