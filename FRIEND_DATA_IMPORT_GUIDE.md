# FRIEND_DATA_IMPORT_GUIDE.md

## Complete Data Import Guide for Stock Prices Database

This guide provides detailed instructions for importing stock price data into your `daily_stock_prices` table.

---

## Table of Contents

1. [Data Format Requirements](#data-format-requirements)
2. [Pre-Import Checklist](#pre-import-checklist)
3. [Import Methods](#import-methods)
4. [Verifying Data](#verifying-data)
5. [Troubleshooting](#troubleshooting)
6. [Data Validation](#data-validation)

---

## Data Format Requirements

### Column Order & Data Types

Your data must match this structure:

```
Column Name      | Data Type        | Example
================================================================================
trading_date     | DATE (YYYY-MM-DD)| 2026-06-18
ticker           | VARCHAR(10)      | IXN
open_price       | DECIMAL(10,2)    | 145.03
high_price       | DECIMAL(10,2)    | 146.63
low_price        | DECIMAL(10,2)    | 144.49
close_price      | DECIMAL(10,2)    | 146.33
adj_close        | DECIMAL(10,2)    | 146.33
volume           | BIGINT           | 361000
```

### Important Notes:
- `price_id` is AUTO_INCREMENT (don't include in imports)
- Date format MUST be `YYYY-MM-DD`
- Prices should be decimal numbers with up to 2 decimal places
- Volume should be integer values
- Ticker symbols are typically 3-5 characters (uppercase)

---

## Pre-Import Checklist

Before importing, verify:

```bash
☐ Database is created
☐ Table daily_stock_prices exists
☐ You have backup of any existing data (optional)
☐ Data file is in the correct format
☐ You have necessary file permissions
☐ MySQL server is running
```

### Verify Table Exists:

```sql
USE your_database_name;
DESCRIBE daily_stock_prices;
```

Expected output:
```
+---------------+------------------+------+-----+---------+----------------+
| Field         | Type             | Null | Key | Default | Extra          |
+---------------+------------------+------+-----+---------+----------------+
| price_id      | int              | NO   | PRI | NULL    | auto_increment |
| trading_date  | date             | NO   | MUL | NULL    |                |
| ticker        | varchar(10)      | NO   |     | NULL    |                |
| open_price    | decimal(10,2)    | YES  |     | NULL    |                |
| high_price    | decimal(10,2)    | YES  |     | NULL    |                |
| low_price     | decimal(10,2)    | YES  |     | NULL    |                |
| close_price   | decimal(10,2)    | NO   |     | NULL    |                |
| adj_close     | decimal(10,2)    | YES  |     | NULL    |                |
| volume        | bigint           | YES  |     | NULL    |                |
+---------------+------------------+------+-----+---------+----------------+
```

---

## Import Methods

### Method 1: Direct SQL Script (RECOMMENDED)

**File:** `aligned_stock_prices.sql`

This is the easiest method - the file already has correct formatting.

#### From MySQL Command Line:

```bash
# Enter MySQL
mysql -u your_username -p your_database_name

# In MySQL prompt:
SOURCE /path/to/aligned_stock_prices.sql;
```

#### From System Command Line:

```bash
mysql -u your_username -p your_database_name < /path/to/aligned_stock_prices.sql
```

#### From MySQL Workbench:

1. Open File > Open SQL Script
2. Select `aligned_stock_prices.sql`
3. Click the Execute button (lightning bolt icon)
4. Wait for completion message

**Example Success Output:**
```
Query OK, 2500 rows affected (12.34 sec)
Records: 2500  Deleted: 0  Skipped: 0  Warnings: 0
```

---

### Method 2: Load from CSV File

#### Create CSV File Format

Save your CSV file with this format (no header row):

```csv
2026-06-18,IXN,145.03,146.63,144.49,146.33,146.33,361000
2026-06-17,IXN,143.42,144.21,140.72,141.04,141.04,213500
2026-06-16,IXN,144.26,144.99,140.94,141.03,141.03,270200
```

Or WITH header row (then use IGNORE 1 ROWS):

```csv
trading_date,ticker,open_price,high_price,low_price,close_price,adj_close,volume
2026-06-18,IXN,145.03,146.63,144.49,146.33,146.33,361000
2026-06-17,IXN,143.42,144.21,140.72,141.04,141.04,213500
```

#### Import CSV (No Header):

```sql
LOAD DATA LOCAL INFILE '/absolute/path/to/your/file.csv'
INTO TABLE daily_stock_prices
FIELDS TERMINATED BY ','
(trading_date, ticker, open_price, high_price, low_price, close_price, adj_close, volume);
```

#### Import CSV (With Header):

```sql
LOAD DATA LOCAL INFILE '/absolute/path/to/your/file.csv'
INTO TABLE daily_stock_prices
FIELDS TERMINATED BY ','
IGNORE 1 ROWS
(trading_date, ticker, open_price, high_price, low_price, close_price, adj_close, volume);
```

#### Enable LOAD DATA LOCAL

If you get an error about local infile:

**In MySQL (temporary for session):**
```sql
SET GLOBAL local_infile = 1;
```

**In my.cnf (permanent):**
```ini
[mysqld]
local_infile=1
```

---

### Method 3: Manual INSERT Statements

For small amounts of data, use INSERT:

```sql
INSERT INTO daily_stock_prices (trading_date, ticker, open_price, high_price, low_price, close_price, adj_close, volume)
VALUES
  ('2026-06-18', 'IXN', 145.03, 146.63, 144.49, 146.33, 146.33, 361000),
  ('2026-06-17', 'IXN', 143.42, 144.21, 140.72, 141.04, 141.04, 213500),
  ('2026-06-16', 'IXN', 144.26, 144.99, 140.94, 141.03, 141.03, 270200);
```

#### Batch INSERT for Better Performance:

```sql
INSERT INTO daily_stock_prices (trading_date, ticker, open_price, high_price, low_price, close_price, adj_close, volume)
VALUES
  ('2026-06-18', 'IXN', 145.03, 146.63, 144.49, 146.33, 146.33, 361000),
  ('2026-06-17', 'IXN', 143.42, 144.21, 140.72, 141.04, 141.04, 213500),
  ('2026-06-16', 'IXN', 144.26, 144.99, 140.94, 141.03, 141.03, 270200),
  -- Add more rows...
;
```

---

### Method 4: Using a Script to Generate INSERT Statements

If you have raw data, use a Python/bash script to generate INSERT statements:

```python
import csv

output_lines = []
with open('raw_data.csv', 'r') as f:
    for row in csv.reader(f):
        date, ticker, open_p, high_p, low_p, close_p, adj_p, volume = row
        sql = f"('{date}','{ticker}',{open_p},{high_p},{low_p},{close_p},{adj_p},{volume}),"
        output_lines.append(sql)

print("INSERT INTO daily_stock_prices VALUES")
print('\n'.join(output_lines[:-1]) + output_lines[-1].rstrip(','))
print(";")
```

---

## Verifying Data

### Step 1: Check Row Count

```sql
-- Total records
SELECT COUNT(*) as total_records FROM daily_stock_prices;

-- Expected output should show number of rows imported
```

### Step 2: Verify by Ticker

```sql
-- Count by ticker
SELECT ticker, COUNT(*) as record_count
FROM daily_stock_prices
GROUP BY ticker
ORDER BY ticker;
```

### Step 3: Check Date Range

```sql
-- See earliest and latest dates
SELECT
  MIN(trading_date) as earliest_date,
  MAX(trading_date) as latest_date
FROM daily_stock_prices;
```

### Step 4: Sample Data Review

```sql
-- View random samples
SELECT * FROM daily_stock_prices
ORDER BY RAND()
LIMIT 10;

-- View first records
SELECT * FROM daily_stock_prices
ORDER BY trading_date, ticker
LIMIT 20;

-- View specific ticker
SELECT * FROM daily_stock_prices
WHERE ticker = 'IXN'
ORDER BY trading_date DESC
LIMIT 10;
```

### Step 5: Data Integrity Checks

```sql
-- Check for NULL values in required columns
SELECT COUNT(*)
FROM daily_stock_prices
WHERE trading_date IS NULL OR ticker IS NULL OR close_price IS NULL;
-- Should return 0 if all data is valid

-- Check for duplicate records
SELECT trading_date, ticker, COUNT(*)
FROM daily_stock_prices
GROUP BY trading_date, ticker
HAVING COUNT(*) > 1;
-- Should return 0 if no duplicates

-- Check price ranges (sanity check)
SELECT
  MIN(close_price) as lowest_price,
  MAX(close_price) as highest_price,
  AVG(close_price) as avg_price
FROM daily_stock_prices;
```

---

## Troubleshooting

### Error: "Table doesn't exist"
```
ERROR 1146: Table 'database.daily_stock_prices' doesn't exist
```
**Solution:** Create the table first using the provided schema.

---

### Error: "LOAD DATA LOCAL not allowed"
```
ERROR 3948: Loading local data is disabled; this must be enabled on both the client and server
```
**Solution:** Enable local_infile:
```sql
SET GLOBAL local_infile = 1;
```
Then reconnect and try again.

---

### Error: "File not found"
```
ERROR 2 (HY000): Can't find file '/path/to/file'
```
**Solution:** 
- Use absolute path, not relative path
- Check file permissions (chmod 644 file.csv)
- Use forward slashes or escape backslashes

---

### Error: "Incorrect date format"
```
ERROR 1292: Incorrect date value: '06-18-2026' for column 'trading_date'
```
**Solution:** 
- Use YYYY-MM-DD format
- Check your source data format
- Convert dates before importing

---

### Error: "Duplicate entry"
```
ERROR 1062: Duplicate entry '2026-06-18-IXN' for key 'idx_ticker_date'
```
**Solution:**
- Delete existing data first if reimporting
- Check for duplicate rows in source file
- Use INSERT IGNORE to skip duplicates

---

### Slow Import Performance

If import is very slow:

```sql
-- Disable indexes temporarily
ALTER TABLE daily_stock_prices DISABLE KEYS;

-- Do your import here
SOURCE aligned_stock_prices.sql;

-- Re-enable indexes
ALTER TABLE daily_stock_prices ENABLE KEYS;
```

---

### Delete Data & Reimport

```sql
-- Delete all data
DELETE FROM daily_stock_prices;

-- Or drop table and recreate
DROP TABLE daily_stock_prices;

-- Then recreate table and reimport
```

---

## Data Validation

### Complete Validation Script

```sql
-- Run this after import to validate everything

-- 1. Count records
SELECT 'Total Records:' as check_name, COUNT(*) as result
FROM daily_stock_prices
UNION ALL

-- 2. Unique tickers
SELECT 'Unique Tickers:', COUNT(DISTINCT ticker)
FROM daily_stock_prices
UNION ALL

-- 3. Date range
SELECT 'Days Covered:', COUNT(DISTINCT trading_date)
FROM daily_stock_prices
UNION ALL

-- 4. Null values
SELECT 'NULL values in close_price:', COUNT(*)
FROM daily_stock_prices
WHERE close_price IS NULL
UNION ALL

-- 5. Invalid prices (negative)
SELECT 'Negative prices:', COUNT(*)
FROM daily_stock_prices
WHERE close_price < 0
UNION ALL

-- 6. Zero volume
SELECT 'Zero volume records:', COUNT(*)
FROM daily_stock_prices
WHERE volume = 0;
```

---

## Next Steps

1. ✓ Create the table (see FRIEND_STEP_BY_STEP_GUIDE.md)
2. ✓ Import data (use methods above)
3. ✓ Validate data (use verification scripts)
4. → Run test queries (FRIEND_ASSIGNMENT_BEGINNER_GUIDE.sql)
5. → Analyze data (FRIEND_SQL_FOR_REAL_DATA.sql)

---

## Quick Command Reference

| Task | Command |
|------|---------|
| Import SQL file | `SOURCE aligned_stock_prices.sql;` |
| Import CSV | `LOAD DATA LOCAL INFILE '...csv' INTO TABLE daily_stock_prices FIELDS TERMINATED BY ',';` |
| Check row count | `SELECT COUNT(*) FROM daily_stock_prices;` |
| See data | `SELECT * FROM daily_stock_prices LIMIT 10;` |
| Delete all | `DELETE FROM daily_stock_prices;` |
| Get summary | `SELECT ticker, COUNT(*) FROM daily_stock_prices GROUP BY ticker;` |

---

**Repository:** https://github.com/seyhasenganz/my-sql-assignment/

For more help, see:
- `FRIEND_STEP_BY_STEP_GUIDE.md` - General guide
- `FRIEND_HOW_TO_RUN_IMPORT.md` - Quick import steps
