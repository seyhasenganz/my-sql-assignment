# FRIEND_STEP_BY_STEP_GUIDE.md

## Step-by-Step Guide to Daily Stock Prices Database

Welcome! This guide will walk you through the daily stock prices database project step by step.

---

## Step 1: Understanding the Database Structure

### Table: `daily_stock_prices`

This table stores daily stock market data for various stock tickers (symbols).

**Columns:**
- `price_id` - Unique identifier (auto-generated)
- `trading_date` - Date of the trading day (YYYY-MM-DD format)
- `ticker` - Stock ticker symbol (e.g., 'IXN', 'GLD')
- `open_price` - Opening price of the day
- `high_price` - Highest price during the day
- `low_price` - Lowest price during the day
- `close_price` - Closing price of the day
- `adj_close` - Adjusted closing price
- `volume` - Number of shares traded

**Example Row:**
```
price_id=1, trading_date=2026-06-18, ticker=IXN, open=145.03, high=146.63, 
low=144.49, close=146.33, adj_close=146.33, volume=361000
```

---

## Step 2: Connecting to Your Database

### Using MySQL Command Line:

```bash
mysql -u your_username -p your_database_name
```

### Using MySQL Workbench or other GUI:
1. Open your MySQL client
2. Select your database
3. Create a new query tab

---

## Step 3: Creating the Table

Run this SQL to create the table:

```sql
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
```

**Check if table was created:**
```sql
SHOW TABLES;
DESCRIBE daily_stock_prices;
```

---

## Step 4: Importing Sample Data

### Method 1: Using the provided SQL file

```sql
SOURCE aligned_stock_prices.sql;
```

Or if that doesn't work:
```bash
mysql -u your_username -p your_database_name < aligned_stock_prices.sql
```

### Method 2: Manual INSERT (for small amounts)

```sql
INSERT INTO daily_stock_prices(trading_date, ticker, open_price, high_price, low_price, close_price, adj_close, volume)
VALUES ('2026-06-18', 'IXN', 145.03, 146.63, 144.49, 146.33, 146.33, 361000);
```

### Method 3: Import from CSV
```sql
LOAD DATA LOCAL INFILE '/path/to/your/file.csv'
INTO TABLE daily_stock_prices
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;
```

---

## Step 5: Verifying Data Import

After importing, verify the data:

```sql
-- Count total records
SELECT COUNT(*) as total_records FROM daily_stock_prices;

-- View first 5 records
SELECT * FROM daily_stock_prices LIMIT 5;

-- Count records per ticker
SELECT ticker, COUNT(*) as count
FROM daily_stock_prices
GROUP BY ticker;

-- Check date range
SELECT MIN(trading_date) as earliest, MAX(trading_date) as latest
FROM daily_stock_prices;
```

---

## Step 6: Basic Queries

### 6.1 Viewing Data

```sql
-- See all columns
SELECT * FROM daily_stock_prices LIMIT 10;

-- See specific columns
SELECT trading_date, ticker, close_price FROM daily_stock_prices LIMIT 10;

-- See data for one ticker
SELECT * FROM daily_stock_prices WHERE ticker = 'IXN' LIMIT 10;
```

### 6.2 Finding Unique Values

```sql
-- Get all unique tickers
SELECT DISTINCT ticker FROM daily_stock_prices ORDER BY ticker;

-- Count unique tickers
SELECT COUNT(DISTINCT ticker) as unique_tickers FROM daily_stock_prices;
```

### 6.3 Filtering with WHERE

```sql
-- Find high-price days
SELECT trading_date, ticker, close_price
FROM daily_stock_prices
WHERE close_price > 200;

-- Find specific ticker on specific date
SELECT * FROM daily_stock_prices
WHERE ticker = 'IXN' AND trading_date = '2026-06-18';

-- Find records in a date range
SELECT * FROM daily_stock_prices
WHERE trading_date BETWEEN '2026-06-01' AND '2026-06-30';
```

---

## Step 7: Aggregation & Statistics

### 7.1 Basic Aggregation

```sql
-- Count records
SELECT COUNT(*) FROM daily_stock_prices;

-- Find highest price ever recorded
SELECT MAX(close_price) as highest_price FROM daily_stock_prices;

-- Find lowest price ever recorded
SELECT MIN(close_price) as lowest_price FROM daily_stock_prices;

-- Average closing price
SELECT AVG(close_price) as average_price FROM daily_stock_prices;
```

### 7.2 Group By Statistics

```sql
-- Statistics for each ticker
SELECT
    ticker,
    COUNT(*) as trading_days,
    MIN(close_price) as lowest_close,
    MAX(close_price) as highest_close,
    ROUND(AVG(close_price), 2) as avg_close
FROM daily_stock_prices
GROUP BY ticker;

-- Average volume per ticker
SELECT ticker, ROUND(AVG(volume), 0) as avg_volume
FROM daily_stock_prices
GROUP BY ticker
ORDER BY avg_volume DESC;
```

---

## Step 8: Sorting & Ordering

```sql
-- Sort by price (highest first)
SELECT trading_date, ticker, close_price
FROM daily_stock_prices
ORDER BY close_price DESC
LIMIT 10;

-- Sort by date (newest first)
SELECT trading_date, ticker, close_price
FROM daily_stock_prices
ORDER BY trading_date DESC
LIMIT 10;

-- Sort by multiple columns
SELECT *
FROM daily_stock_prices
ORDER BY ticker ASC, trading_date DESC
LIMIT 20;
```

---

## Step 9: Analysis Queries

### 9.1 Daily Price Changes

```sql
-- Calculate daily price change
SELECT
    trading_date,
    ticker,
    open_price,
    close_price,
    (close_price - open_price) as price_change,
    ROUND((close_price - open_price) / open_price * 100, 2) as percent_change
FROM daily_stock_prices
LIMIT 20;
```

### 9.2 Price Ranges

```sql
-- Daily high-low range
SELECT
    trading_date,
    ticker,
    (high_price - low_price) as daily_range
FROM daily_stock_prices
ORDER BY daily_range DESC
LIMIT 10;
```

### 9.3 Volume Analysis

```sql
-- Highest volume days
SELECT trading_date, ticker, volume
FROM daily_stock_prices
WHERE volume > 1000000
ORDER BY volume DESC
LIMIT 10;

-- Average volume by ticker
SELECT ticker, ROUND(AVG(volume), 0) as avg_vol
FROM daily_stock_prices
GROUP BY ticker
ORDER BY avg_vol DESC;
```

---

## Step 10: Advanced Queries

### 10.1 Using HAVING

```sql
-- Tickers with more than 200 trading days
SELECT ticker, COUNT(*) as trading_days
FROM daily_stock_prices
GROUP BY ticker
HAVING COUNT(*) > 200
ORDER BY trading_days DESC;
```

### 10.2 Subqueries

```sql
-- Find records with above-average volume
SELECT trading_date, ticker, volume
FROM daily_stock_prices
WHERE volume > (
    SELECT AVG(volume) FROM daily_stock_prices
)
ORDER BY volume DESC
LIMIT 20;
```

### 10.3 JOINs (self-join)

```sql
-- Compare prices between consecutive days
SELECT
    a.trading_date,
    a.ticker,
    a.close_price as today_close,
    b.close_price as yesterday_close
FROM daily_stock_prices a
JOIN daily_stock_prices b
ON a.ticker = b.ticker
AND DATE_ADD(b.trading_date, INTERVAL 1 DAY) = a.trading_date
LIMIT 20;
```

---

## Step 11: Troubleshooting

### Common Issues:

**Q: "Table doesn't exist"**
- Make sure you created the table first
- Check if you're using the correct database: `USE your_database_name;`

**Q: "Data import failed"**
- Check file path is correct
- Verify data format matches table structure
- Use SHOW WARNINGS to see detailed error messages

**Q: "Query returns too much data"**
- Always use LIMIT when exploring
- Use WHERE to filter specific data

**Q: "Date format error"**
- Ensure dates are in YYYY-MM-DD format
- Check if trading_date column is set to DATE type

---

## Step 12: Common Patterns

### Pattern 1: Get Latest Data
```sql
SELECT * FROM daily_stock_prices
ORDER BY trading_date DESC
LIMIT 1;
```

### Pattern 2: Monthly Summary
```sql
SELECT
    YEAR(trading_date) as year,
    MONTH(trading_date) as month,
    ticker,
    COUNT(*) as trading_days,
    ROUND(AVG(close_price), 2) as avg_price
FROM daily_stock_prices
GROUP BY year, month, ticker;
```

### Pattern 3: Find Volatility
```sql
SELECT
    ticker,
    ROUND(STDDEV(close_price), 2) as volatility
FROM daily_stock_prices
GROUP BY ticker;
```

---

## Next Steps

1. **Explore the beginner guide**: See `FRIEND_ASSIGNMENT_BEGINNER_GUIDE.sql` for more examples
2. **Practice**: Try writing your own queries based on these patterns
3. **Import more data**: Use `FRIEND_IMPORT_CODE_FOR_ALL_TICKER.sql` to load more tickers
4. **Analyze**: Use the queries to answer real-world questions about the data
5. **Optimize**: Learn about indexes and query optimization for performance

---

## Quick Reference

| Task | Command |
|------|---------|
| View table structure | `DESCRIBE daily_stock_prices;` |
| View all data | `SELECT * FROM daily_stock_prices LIMIT 10;` |
| Count records | `SELECT COUNT(*) FROM daily_stock_prices;` |
| Get unique values | `SELECT DISTINCT ticker FROM daily_stock_prices;` |
| Filter data | `SELECT * FROM daily_stock_prices WHERE ticker = 'IXN';` |
| Sort data | `SELECT * FROM daily_stock_prices ORDER BY close_price DESC;` |
| Aggregate data | `SELECT ticker, AVG(close_price) FROM daily_stock_prices GROUP BY ticker;` |
| Import data | `SOURCE aligned_stock_prices.sql;` |
| Delete all data | `DELETE FROM daily_stock_prices;` |
| Drop table | `DROP TABLE daily_stock_prices;` |

---

**Good luck with your SQL assignment!**

For more help, check:
- `FRIEND_DATA_IMPORT_GUIDE.md` - Detailed import instructions
- `FRIEND_HOW_TO_RUN_IMPORT.md` - Step-by-step import process
- Repository: https://github.com/seyhasenganz/my-sql-assignment/
