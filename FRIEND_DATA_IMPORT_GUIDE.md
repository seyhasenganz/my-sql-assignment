# DATA IMPORT GUIDE - Converting Excel to MySQL
## Simple Step-by-Step Instructions

---

## WHAT YOUR DATA SHOULD LOOK LIKE

Your Excel file should have 3 columns:

| Date | Ticker | ClosePrice |
|------|--------|-----------|
| 2024-06-12 | IXN | 138.50 |
| 2024-06-11 | IXN | 137.20 |
| 2024-06-10 | IXN | 136.80 |
| 2024-06-12 | QQQ | 425.30 |
| 2024-06-11 | QQQ | 423.50 |

---

## METHOD 1: IMPORT VIA CSV (RECOMMENDED)

### Step 1: Prepare CSV File

**In Excel:**
1. Open your file (All_ticker.xlsx)
2. Make sure it has exactly 3 columns: Date, Ticker, ClosePrice
3. Check that dates are in format: YYYY-MM-DD (e.g., 2024-06-12)
4. File → Save As
5. Choose format: "CSV (Comma delimited)" (.csv)
6. Save as: `portfolio_data.csv`
7. Click "Yes" when asked about compatibility

**Important:** Note where you saved the file!
Example: `C:\Users\YourName\Documents\portfolio_data.csv`

### Step 2: Import into MySQL Workbench

**Step 2A: Start Import Process**
1. Open MySQL Workbench
2. Click **Server** menu (top)
3. Click **Data Import** (or **Data Export**)
4. Window opens

**Step 2B: Select Your File**
1. Check "Import from Self-Contained File"
2. Click "..." button to browse
3. Navigate to your `portfolio_data.csv` file
4. Click "Open"

**Step 2C: Choose Destination**
1. In the dropdown, select database: `portfolio_analysis`
2. Choose table: `daily_prices`

**Step 2D: Configure Import**
1. Click **Import Progress** tab
2. Make sure format is set to: CSV
3. Click "Start Import"
4. You should see: "Import completed successfully"

### Step 3: Verify Data Loaded

Run this query in MySQL Workbench:

```sql
SELECT COUNT(*) as total_records FROM daily_prices;
```

**Expected result:** Shows a number (how many rows were imported)

---

## METHOD 2: MANUAL LOAD DATA (If CSV Import Doesn't Work)

### Step 1: Save Your Data as CSV

Same as Method 1, Steps 1-7

### Step 2: Get Full File Path

**On Windows:**
1. Right-click on `portfolio_data.csv` file
2. Click "Properties"
3. Copy the full path (e.g., `C:\Users\YourName\Documents\portfolio_data.csv`)

**On Mac:**
1. Right-click file → "Get Info"
2. Copy path

### Step 3: Enable Local File Loading

Run this query in MySQL Workbench:

```sql
SET GLOBAL local_infile = 1;
```

### Step 4: Import the Data

Replace `/path/to/your/file.csv` with your actual file path:

```sql
LOAD DATA LOCAL INFILE '/path/to/portfolio_data.csv'
INTO TABLE portfolio_analysis.daily_prices
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(trading_date, ticker, closing_price);
```

**Example (Windows):**
```sql
LOAD DATA LOCAL INFILE 'C:/Users/YourName/Documents/portfolio_data.csv'
INTO TABLE portfolio_analysis.daily_prices
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(trading_date, ticker, closing_price);
```

Note: Use forward slashes `/` even on Windows!

---

## METHOD 3: MANUAL INSERT (Last Resort)

If CSV import doesn't work, manually insert data:

### Step 1: Prepare Your Data

In Excel, arrange data like this:

| A | B | C |
|---|---|---|
| 2024-06-12 | IXN | 138.50 |
| 2024-06-11 | IXN | 137.20 |

### Step 2: Create SQL INSERT Statements

For each row in Excel, create an INSERT statement:

```sql
INSERT INTO daily_prices (trading_date, ticker, closing_price) VALUES
('2024-06-12', 'IXN', 138.50),
('2024-06-11', 'IXN', 137.20),
('2024-06-10', 'IXN', 136.80),
('2024-06-12', 'QQQ', 425.30),
('2024-06-11', 'QQQ', 423.50),
('2024-06-10', 'QQQ', 421.80),
('2024-06-12', 'IEF', 97.50),
('2024-06-11', 'IEF', 97.60),
-- Continue for all your data...
;
```

### Step 3: Run in MySQL Workbench

1. Paste the entire INSERT statement
2. Click lightning bolt to execute
3. You should see: "X rows affected" (where X = number of rows)

---

## VERIFYING YOUR DATA

Run these queries to check everything loaded correctly:

### Check 1: Total Records
```sql
SELECT COUNT(*) as total_records FROM daily_prices;
```
**Should show:** Number of rows you imported

### Check 2: Records Per Ticker
```sql
SELECT
    ticker,
    COUNT(*) as record_count
FROM daily_prices
GROUP BY ticker
ORDER BY ticker;
```
**Should show:** Each ticker with count
```
IEF    250
GLD    250
IXN    250
QQQ    250
VNQ    250
```

### Check 3: Date Range
```sql
SELECT
    MIN(trading_date) as earliest_date,
    MAX(trading_date) as latest_date,
    COUNT(DISTINCT trading_date) as unique_dates
FROM daily_prices;
```
**Should show:** Your earliest and latest dates

### Check 4: Sample Data
```sql
SELECT * FROM daily_prices LIMIT 10;
```
**Should show:** First 10 rows looking correct

### Check 5: All 5 Tickers Present
```sql
SELECT DISTINCT ticker FROM daily_prices ORDER BY ticker;
```
**Should show:**
```
GLD
IEF
IXN
QQQ
VNQ
```

---

## COMMON PROBLEMS & SOLUTIONS

### Problem: "File not found"
**Solution:**
- Check the file path is correct
- Use forward slashes `/` not backslashes `\`
- Example: `C:/Users/Name/Documents/file.csv`

### Problem: "Incorrect integer value"
**Solution:**
- Make sure dates are in YYYY-MM-DD format
- Make sure prices are numbers, not text
- Example: `2024-06-12` not `06/12/2024`

### Problem: "0 rows affected"
**Solution:**
- Check CSV file is not empty
- Check field names match table columns
- Make sure CSV uses commas as separator (not semicolons or tabs)

### Problem: "Access denied for user 'root'@'localhost'"
**Solution:**
- Make sure MySQL server is running
- Check username and password
- Try different MySQL connection

### Problem: "No data in table after import"
**Solution:**
1. Check if table was created correctly: `SHOW TABLES;`
2. Check if data was really imported: `SELECT COUNT(*) FROM daily_prices;`
3. Try manual INSERT instead (Method 3)

---

## EXAMPLE: COMPLETE IMPORT WALKTHROUGH

### My Data:
```
Date,Ticker,Price
2024-06-12,IXN,138.50
2024-06-11,IXN,137.20
2024-06-12,QQQ,425.30
2024-06-11,QQQ,423.50
2024-06-12,GLD,195.75
2024-06-11,GLD,194.80
2024-06-12,VNQ,89.50
2024-06-11,VNQ,88.90
2024-06-12,IEF,97.50
2024-06-11,IEF,97.60
```

### Step 1: Save as CSV
1. Excel → File → Save As → CSV format
2. Save as `my_portfolio.csv`
3. File saved at: `C:\Users\Student\Documents\my_portfolio.csv`

### Step 2: Create Tables
```sql
USE portfolio_analysis;

CREATE TABLE daily_prices (
    price_id INT AUTO_INCREMENT PRIMARY KEY,
    trading_date DATE NOT NULL,
    ticker VARCHAR(10) NOT NULL,
    closing_price DECIMAL(10, 2) NOT NULL
);
```

### Step 3: Import Data
```sql
LOAD DATA LOCAL INFILE 'C:/Users/Student/Documents/my_portfolio.csv'
INTO TABLE daily_prices
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(trading_date, ticker, closing_price);
```

### Step 4: Verify
```sql
SELECT * FROM daily_prices;
```

**Result:**
```
price_id | trading_date | ticker | closing_price
1        | 2024-06-12   | IXN    | 138.50
2        | 2024-06-11   | IXN    | 137.20
3        | 2024-06-12   | QQQ    | 425.30
...
```

✅ **Success!** Data is loaded.

---

## FORMAT REQUIREMENTS

Your CSV file MUST have:

✅ **Correct Format:**
```
Date,Ticker,Price
2024-06-12,IXN,138.50
2024-06-11,IXN,137.20
2024-06-10,IXN,136.80
```

❌ **Wrong Format (will fail):**
```
Date | Ticker | Price          (using pipes instead of commas)
06/12/2024,IXN,138.50         (date format wrong)
2024-06-12,ixn,138.50         (ticker lowercase)
"2024-06-12","IXN","138.50"    (extra quotes)
```

---

## FINAL CHECKLIST BEFORE ANALYSIS

- [ ] Created `portfolio_analysis` database
- [ ] Created `daily_prices` table
- [ ] Created `ticker_info` table
- [ ] Inserted ticker information (5 rows)
- [ ] Imported daily prices from CSV or manual insert
- [ ] Verified data loaded: `SELECT COUNT(*) FROM daily_prices;`
- [ ] Checked all 5 tickers present
- [ ] Checked date range covers 12+ months
- [ ] Verified no NULL values in important columns

**Once all checkmarks are done, you're ready for analysis! 🚀**

---

## STILL STUCK?

If data won't import:
1. Try manual insert (Method 3) - slower but always works
2. Check CSV file is saved correctly (open it in Notepad to verify)
3. Contact your professor - import issues are common!
4. Ask for help in class forum

**Don't waste time on import - manual insert works fine!**
