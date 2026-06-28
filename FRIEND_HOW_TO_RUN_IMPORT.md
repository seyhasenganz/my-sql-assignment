# HOW TO RUN THE IMPORT IN MYSQL WORKBENCH
## Step-by-Step with Screenshots Description

---

## 📝 QUICK SUMMARY

**What You'll Do:**
1. Open `IMPORT_CODE_FOR_ALL_TICKER.sql` in MySQL Workbench
2. Change file path to your CSV location
3. Run the SQL code
4. Verify data loaded with verification queries

**Time Required:** 5-10 minutes

---

## STEP 1: GET YOUR FILE PATH

### Windows Example:
1. Right-click on `All_ticker.csv` file
2. Click "Properties"
3. Copy the full path shown
   
**Example:** `C:\Users\YourName\Documents\All_ticker.csv`

**Convert to SQL format:** `C:/Users/YourName/Documents/All_ticker.csv`
- Change `\` (backslash) to `/` (forward slash)

### Mac/Linux Example:
1. Right-click on `All_ticker.csv`
2. Hold Option key, click "Copy as Pathname"
3. Paste - this is your path

**Example:** `/Users/YourName/Documents/All_ticker.csv`

---

## STEP 2: OPEN MYSQL WORKBENCH

1. Launch MySQL Workbench
2. Double-click your MySQL connection (e.g., "Local instance")
3. Wait for it to connect
4. You should see an empty query window

---

## STEP 3: COPY THE IMPORT CODE

**Option A: Copy from File**
1. Open `IMPORT_CODE_FOR_ALL_TICKER.sql` in any text editor
2. Select all code (Ctrl+A)
3. Copy (Ctrl+C)

**Option B: Type in MySQL Workbench Directly**
1. Click in the query editor area
2. Paste or type the code below

---

## STEP 4: EDIT THE FILE PATH

Find this line in the code:
```sql
LOAD DATA LOCAL INFILE 'C:/path/to/All_ticker.csv'
```

Replace `'C:/path/to/All_ticker.csv'` with your actual file path.

**Examples:**

**Windows:**
```sql
LOAD DATA LOCAL INFILE 'C:/Users/Student/Documents/All_ticker.csv'
```

**Mac:**
```sql
LOAD DATA LOCAL INFILE '/Users/Student/Documents/All_ticker.csv'
```

**Important:** Keep the single quotes around the path!

---

## STEP 5: RUN THE IMPORT

### In MySQL Workbench:

**Step 5A: Highlight the STEP 1 code**
- Select lines from `CREATE DATABASE` through `INSERT INTO security_info`
- This creates the tables and inserts ticker info
- Click the **Lightning Bolt** button (Execute)
- You should see: "Query executed successfully"

**Step 5B: Highlight the STEP 2 code**
- Select the LOAD DATA LOCAL INFILE section
- This actually imports your CSV data
- Click the **Lightning Bolt** button
- **Wait 10-30 seconds** for import to complete
- You should see: "Query OK, 2500 rows affected" (or similar)

**Step 5C: Highlight the Verification Queries**
- Select the verification queries section
- Click the **Lightning Bolt** button
- Results will show in the output panel below

---

## STEP 6: CHECK RESULTS

After running verification queries, you should see:

### Verification Check 1:
```
total_records
2500
```
Should show ~2,500 (exact number might vary slightly)

### Verification Check 2:
```
ticker | record_count | earliest_date | latest_date
GLD    | 502          | 2024-06-21    | 2026-06-19
IEF    | 502          | 2024-06-21    | 2026-06-19
IXN    | 502          | 2024-06-21    | 2026-06-19
QQQ    | 502          | 2024-06-21    | 2026-06-19
VNQ    | 502          | 2024-06-21    | 2026-06-19
```

### Verification Check 3:
```
earliest_date | latest_date | unique_trading_days
2024-06-21    | 2026-06-19  | 502
```

### Verification Check 4:
First 10 rows should show data like:
```
price_id | trading_date | ticker | open_price | high_price | low_price | close_price | adj_close | volume
1        | 2024-06-21   | IXN    | 120.75     | 122.27     | 120.74    | 121.85      | 121.7     | 255400
2        | 2024-06-21   | IXN    | 120.26     | 120.47     | 118.18    | 120.25      | 120.11    | 153900
...
```

### Verification Check 5:
```
ticker
GLD
IEF
IXN
QQQ
VNQ
```

### Verification Check 6:
```
ticker | total_rows | min_volume | max_volume
GLD    | 502        | 100000     | 5000000
IEF    | 502        | 50000      | 2000000
IXN    | 502        | 100000     | 4000000
QQQ    | 502        | 200000     | 6000000
VNQ    | 502        | 150000     | 3000000
```

**If all checks show correct data → IMPORT SUCCESSFUL! ✅**

---

## ⚠️ TROUBLESHOOTING

### Problem: "Syntax Error"
**Solution:**
- Make sure file path uses forward slashes `/`
- Make sure single quotes surround the path: `'C:/path/to/file.csv'`
- Example correct: `LOAD DATA LOCAL INFILE 'C:/Users/Name/Documents/All_ticker.csv'`
- Example wrong: `LOAD DATA LOCAL INFILE C:\Users\Name\Documents\All_ticker.csv`

### Problem: "File not found" or "Cannot open file"
**Solution:**
- Double-check the file path is correct
- Copy path directly from File Explorer (Windows) or Finder (Mac)
- Verify file actually exists at that location
- Try absolute path instead of relative path

### Problem: "0 rows affected"
**Solution:**
1. Check if CSV file is empty or corrupted
2. Open CSV in Excel to verify data is there
3. Check file format (should be .csv, not .xlsx)
4. Try Method 2 or Method 3 in the import code

### Problem: "LOAD DATA LOCAL is disabled"
**Solution:**
1. Run this first:
   ```sql
   SET GLOBAL local_infile = 1;
   ```
2. Then run the LOAD DATA command again

### Problem: "Access denied"
**Solution:**
1. Check MySQL connection (should be connected)
2. Make sure file path is readable by your user
3. Try running MySQL Workbench as Administrator
4. Try different file location (e.g., Desktop instead of Documents)

### Problem: "Incorrect datetime value"
**Solution:**
- The date format conversion might have failed
- Check CSV file first row - what format are dates in?
- If dates are `DD-MMM-YY` (like 21-Jun-24), the code should work
- If different format, adjust the conversion code

### Problem: "1054 Unknown column"
**Solution:**
- The table structure doesn't match the data
- Run the CREATE TABLE statements first (Step 1)
- Make sure you're using `daily_stock_prices` table (not different name)
- Drop and recreate tables if needed:
  ```sql
  DROP TABLE IF EXISTS daily_stock_prices;
  -- Then re-run CREATE TABLE statement
  ```

---

## VISUAL WALKTHROUGH

### Step-by-Step Images (Description):

**1. MySQL Workbench Home Screen**
- See the query editor area (white text box at top)
- See the lightning bolt icon on toolbar

**2. Copy Code into Editor**
- Paste `IMPORT_CODE_FOR_ALL_TICKER.sql` content
- See all the SQL code in the editor

**3. Edit File Path**
- Find the line: `LOAD DATA LOCAL INFILE 'C:/path/to/All_ticker.csv'`
- Change to your actual path
- Keep the single quotes!

**4. Run STEP 1 (Create Tables)**
- Select lines 1-50 (CREATE DATABASE through INSERT INTO security_info)
- Click Lightning Bolt button
- Wait for "Query executed successfully" message

**5. Run STEP 2 (Import Data)**
- Select the LOAD DATA LOCAL INFILE section
- Click Lightning Bolt button
- **Important:** Wait for completion (~10-30 seconds)
- See "Query OK, 2500 rows affected" message

**6. Run Verification Queries**
- Select the verification queries
- Click Lightning Bolt button
- See results in the "Result Grid" panel below
- Verify ~2,500 total records with 502 per ticker

---

## COMPLETE CODE TO RUN

Here's the exact code you need (just change the file path):

```sql
-- Step 1: Create Database and Tables
CREATE DATABASE IF NOT EXISTS portfolio_db;
USE portfolio_db;

DROP TABLE IF EXISTS daily_stock_prices;
CREATE TABLE daily_stock_prices (
    price_id INT AUTO_INCREMENT PRIMARY KEY,
    trading_date DATE NOT NULL,
    ticker VARCHAR(10) NOT NULL,
    open_price DECIMAL(10, 2),
    high_price DECIMAL(10, 2),
    low_price DECIMAL(10, 2),
    close_price DECIMAL(10, 2) NOT NULL,
    adj_close DECIMAL(10, 2),
    volume BIGINT,
    INDEX idx_ticker_date (ticker, trading_date)
);

DROP TABLE IF EXISTS security_info;
CREATE TABLE security_info (
    ticker VARCHAR(10) PRIMARY KEY,
    security_name VARCHAR(100) NOT NULL,
    current_percent DECIMAL(5, 2) NOT NULL,
    asset_class VARCHAR(50) NOT NULL,
    portfolio_value DECIMAL(15, 2)
);

INSERT INTO security_info VALUES
('IXN', 'iShares Global Tech ETF', 17.5, 'Equity', 16.625),
('QQQ', 'NASDAQ 100', 22.1, 'Equity', 20.995),
('IEF', 'iShares 7-10 Year Treasury Bond ETF', 28.5, 'Fixed Income', 27.075),
('VNQ', 'Vanguard Real Estate ETF', 8.9, 'Real Assets', 8.455),
('GLD', 'SPDR Gold Shares', 23.0, 'Commodities', 21.85);

-- Step 2: Import Data (CHANGE FILE PATH!)
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

-- Step 3: Verify (Run these separately)
SELECT COUNT(*) as total_records FROM daily_stock_prices;

SELECT ticker, COUNT(*) as count, MIN(trading_date) as start, MAX(trading_date) as end 
FROM daily_stock_prices 
GROUP BY ticker;

SELECT * FROM daily_stock_prices LIMIT 10;
```

---

## SUCCESS!

If all verification checks pass → **Your data is ready for analysis!**

Next: Run the 5 SQL queries from `FRIEND_SQL_FOR_REAL_DATA.sql`

---

## NEXT STEPS

1. ✅ Data imported successfully
2. 📊 Run Question 1 query (Returns)
3. 📊 Run Question 2 query (Variance)
4. 📊 Run Question 3 query (Sigma)
5. 📊 Run Question 4 query (Sharpe)
6. 📊 Run Question 5 query (Rebalancing)
7. 📝 Write explanations
8. 📄 Convert to PDF
9. ✈️ Submit assignment!

Good luck! 🚀
