# IMPORT GUIDE FOR All_ticker.csv
## Step-by-Step Instructions for Your Friend

---

## 📊 DATA SUMMARY

**File:** `All_ticker.csv`

**Data Details:**
- **Date Range:** 21-Jun-2024 to 21-Jun-2026 (2 full years)
- **Records:** ~2,500 rows (502 trading days × 5 tickers)
- **Tickers:** IXN, QQQ, IEF, VNQ, GLD

**CSV Format:**
```
Date,Ticker,Open,High,Low,Close ,Adj Close ,Volume
18-Jun-26,IXN,145.03,146.63,144.49,146.33,146.33,"361,000"
17-Jun-26,IXN,143.42,144.21,140.72,141.04,141.04,"213,500"
```

**Special Handling Required:**
- ✅ Date format: `DD-MMM-YY` (18-Jun-26) → needs conversion to `YYYY-MM-DD`
- ✅ Volume format: `"361,000"` (with commas) → needs removal to `361000`

---

## STEP 1: CREATE DATABASE AND TABLE

Run this SQL in MySQL Workbench:

```sql
CREATE DATABASE IF NOT EXISTS portfolio_db;
USE portfolio_db;

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

    INDEX idx_ticker_date (ticker, trading_date),
    INDEX idx_date (trading_date)
);

DROP TABLE IF EXISTS security_info;

CREATE TABLE security_info (
    ticker           VARCHAR(10) PRIMARY KEY,
    security_name    VARCHAR(100) NOT NULL,
    current_percent  DECIMAL(5, 2) NOT NULL,
    asset_class      VARCHAR(50) NOT NULL,
    portfolio_value  DECIMAL(15, 2)
);

INSERT INTO security_info (ticker, security_name, current_percent, asset_class, portfolio_value) VALUES
('IXN', 'iShares Global Tech ETF', 17.5, 'Equity', 16.625),
('QQQ', 'NASDAQ 100', 22.1, 'Equity', 20.995),
('IEF', 'iShares 7-10 Year Treasury Bond ETF', 28.5, 'Fixed Income', 27.075),
('VNQ', 'Vanguard Real Estate ETF', 8.9, 'Real Assets', 8.455),
('GLD', 'SPDR Gold Shares', 23.0, 'Commodities', 21.85);
```

✅ **Run these queries to create tables and insert ticker info**

---

## STEP 2: IMPORT DATA FROM CSV

### Option A: Import via MySQL Workbench (Easy)

**Step 1:** Get full file path
- Windows: Right-click `All_ticker.csv` → Properties → copy full path
- Mac: Right-click → Get Info → copy path

**Step 2:** Run import command in MySQL Workbench

Replace `C:/path/to/All_ticker.csv` with your actual file path:

```sql
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
```

**What each part does:**
- `LOAD DATA LOCAL INFILE`: Read the CSV file
- `FIELDS TERMINATED BY ','`: CSV uses commas as separator
- `ENCLOSED BY '"'`: Volume field is enclosed in quotes
- `IGNORE 1 ROWS`: Skip header row (Date,Ticker,Open,...)
- `@trading_date`: Temporary variable for date (needs conversion)
- `@volume`: Temporary variable for volume (needs comma removal)
- `STR_TO_DATE(@trading_date, '%d-%b-%y')`: Convert `18-Jun-26` to `2026-06-18`
- `REPLACE(@volume, ',', '')`: Remove commas from volume (`361,000` → `361000`)

**Expected Result:** "Query OK, 2500 rows affected"

---

### Option B: If Import Fails - Manual Import

**Step 1:** Export CSV as SQL INSERT statements

Use an online CSV to SQL converter:
- Visit: https://www.csvjson.com/csv2sql
- Upload `All_ticker.csv`
- Choose: Table = `daily_stock_prices`
- Generate SQL

**Step 2:** Modify the generated SQL

The converter will create INSERT statements. You need to modify the date format:

```sql
-- Find this pattern:
INSERT INTO daily_stock_prices (trading_date, ticker, ...) VALUES
('18-Jun-26', 'IXN', ...),

-- Replace with:
INSERT INTO daily_stock_prices (trading_date, ticker, ...) VALUES
(STR_TO_DATE('18-Jun-26', '%d-%b-%y'), 'IXN', ...),
```

**Step 3:** Run the modified INSERT statements

---

## STEP 3: VERIFY DATA LOADED

Run these verification queries:

### Query 1: Count total records
```sql
SELECT COUNT(*) as total_records FROM daily_stock_prices;
```
**Expected:** ~2,500 rows

### Query 2: Records per ticker
```sql
SELECT
    ticker,
    COUNT(*) as record_count,
    MIN(trading_date) as earliest_date,
    MAX(trading_date) as latest_date
FROM daily_stock_prices
GROUP BY ticker
ORDER BY ticker;
```
**Expected output:**
```
GLD    502    2024-06-21    2026-06-19
IEF    502    2024-06-21    2026-06-19
IXN    502    2024-06-21    2026-06-19
QQQ    502    2024-06-21    2026-06-19
VNQ    502    2024-06-21    2026-06-19
```

### Query 3: Date range
```sql
SELECT
    MIN(trading_date) as earliest_date,
    MAX(trading_date) as latest_date,
    COUNT(DISTINCT trading_date) as unique_trading_days
FROM daily_stock_prices;
```
**Expected:** Dates from 2024-06-21 to 2026-06-19, ~502 unique dates

### Query 4: Check volume (should NOT have commas)
```sql
SELECT
    ticker,
    MIN(volume) as min_volume,
    MAX(volume) as max_volume,
    COUNT(*) as records
FROM daily_stock_prices
GROUP BY ticker;
```
**Expected:** Volume as numbers (e.g., 361000), NOT text ("361,000")

### Query 5: Sample data
```sql
SELECT * FROM daily_stock_prices LIMIT 10;
```
**Should show clean data without commas or quote issues**

---

## TROUBLESHOOTING

### Problem: "Syntax Error" in LOAD DATA command
**Solution:** 
- Make sure you use forward slashes `/` in file path (not backslashes `\`)
- Windows example: `C:/Users/Student/Documents/All_ticker.csv`
- Enclose full path in single quotes

### Problem: "0 rows affected" (no data imported)
**Solution:**
1. Check file path is correct
2. Check file has data (open in Excel to verify)
3. Check CSV format (Date, Ticker, Open, High, Low, Close, Adj Close, Volume)
4. Try manual insert instead (Option B)

### Problem: "Access denied" or "File not found"
**Solution:**
1. Make sure MySQL is running
2. Check file path exists
3. Try using absolute path instead of relative path

### Problem: "Incorrect datetime value"
**Solution:**
- Date conversion failed. CSV date format might be different
- Check first few lines of CSV to see actual date format
- If not `DD-MMM-YY`, adjust conversion: `STR_TO_DATE(@trading_date, 'your-format-here')`

### Problem: Volume showing as 0 or wrong numbers
**Solution:**
- Volume comma removal failed
- The REPLACE function should have removed commas
- Try modifying: `volume = CAST(REPLACE(REPLACE(@volume, '"', ''), ',', '') AS UNSIGNED);`

### Problem: "LOAD DATA LOCAL is disabled"
**Solution:**
Run this command first, then retry:
```sql
SET GLOBAL local_infile = 1;
```

---

## AFTER IMPORT: RUN YOUR ANALYSES

Once data is verified, use this SQL file:
- **File:** `FRIEND_SQL_FOR_REAL_DATA.sql`
- Contains all 5 SQL queries for the assignment
- Copy each question's query and run it
- Screenshot the results for your report

---

## QUICK CHECKLIST

- [ ] Database created: `portfolio_db`
- [ ] Tables created: `daily_stock_prices` and `security_info`
- [ ] Ticker info inserted (5 records)
- [ ] All data imported from CSV (~2,500 records)
- [ ] Date format verified (YYYY-MM-DD)
- [ ] Volume format verified (numbers, no commas)
- [ ] All 5 tickers present in table
- [ ] Date range correct (2024-06-21 to 2026-06-19)
- [ ] Ready to run analysis queries

✅ **Once all checks pass, you're ready for analysis!**

---

## NEXT STEPS

1. **Run all 5 SQL queries** from `FRIEND_SQL_FOR_REAL_DATA.sql`
2. **Screenshot each result** (copy to Word/Google Docs)
3. **Write explanations** for each question (Q1-Q5)
4. **Make rebalancing recommendation** (Question 5)
5. **Convert to PDF** and submit

---

## NEED HELP?

If import still won't work:
- Use manual method (Option B) - slower but 100% reliable
- Ask your professor
- Check the assignment rubric for import help
- Data quality check is more important than import method!
