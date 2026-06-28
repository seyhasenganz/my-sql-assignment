# FRIEND_IMPORT_ALL_TICKER_CSV.md

## Importing Stock Price Data from CSV Files

This guide shows you how to import stock price data from CSV files into your `daily_stock_prices` database table.

---

## Table of Contents

1. [CSV File Format](#csv-file-format)
2. [Creating CSV Files](#creating-csv-files)
3. [Import Methods](#import-methods)
4. [Troubleshooting](#troubleshooting)
5. [Examples](#examples)

---

## CSV File Format

### Required Column Order

Your CSV file **MUST** have columns in this exact order:

```
trading_date,ticker,open_price,high_price,low_price,close_price,adj_close,volume
```

### Data Types & Formats

| Column | Format | Example | Notes |
|--------|--------|---------|-------|
| trading_date | YYYY-MM-DD | 2026-06-18 | Date must be in this exact format |
| ticker | Text (3-10 chars) | IXN, GLD, AAPL | Stock symbol, typically uppercase |
| open_price | Decimal | 145.03 | Opening price of the day |
| high_price | Decimal | 146.63 | Highest price during the day |
| low_price | Decimal | 144.49 | Lowest price during the day |
| close_price | Decimal | 146.33 | Closing price of the day |
| adj_close | Decimal | 146.33 | Adjusted closing price |
| volume | Integer | 361000 | Number of shares traded |

### Example CSV Content

```csv
trading_date,ticker,open_price,high_price,low_price,close_price,adj_close,volume
2026-06-18,IXN,145.03,146.63,144.49,146.33,146.33,361000
2026-06-17,IXN,143.42,144.21,140.72,141.04,141.04,213500
2026-06-18,AAPL,225.50,227.35,224.80,226.75,226.75,52500000
2026-06-17,AAPL,224.25,226.50,223.90,225.10,225.10,48750000
2026-06-18,MSFT,435.80,438.50,434.20,437.25,437.25,28300000
```

---

## Creating CSV Files

### Method 1: Export from Spreadsheet

#### Excel / Google Sheets:

1. Open your spreadsheet with stock data
2. Arrange columns in order:
   - A: trading_date (YYYY-MM-DD format)
   - B: ticker
   - C: open_price
   - D: high_price
   - E: low_price
   - F: close_price
   - G: adj_close
   - H: volume

3. Select all data including header
4. **File → Download as → CSV**
5. Save as `stock_data.csv`

#### Verify Format:

- Open the CSV in a text editor (not Excel)
- Check that first row has headers
- Check dates are YYYY-MM-DD format
- Check no extra spaces in data

### Method 2: Create CSV from Raw Data

If you have raw data, clean it first:

```python
import csv
from datetime import datetime

# Example: Convert date formats
input_file = 'raw_data.csv'
output_file = 'stock_data_clean.csv'

with open(input_file, 'r') as infile, open(output_file, 'w', newline='') as outfile:
    reader = csv.reader(infile)
    writer = csv.writer(outfile)
    
    # Write header
    writer.writerow(['trading_date', 'ticker', 'open_price', 'high_price', 
                     'low_price', 'close_price', 'adj_close', 'volume'])
    
    # Process each row
    next(reader)  # Skip original header
    for row in reader:
        # Convert date from MM/DD/YYYY to YYYY-MM-DD
        date_obj = datetime.strptime(row[0], '%m/%d/%Y')
        new_date = date_obj.strftime('%Y-%m-%d')
        
        # Clean and write
        writer.writerow([
            new_date,
            row[1].upper(),  # ticker
            float(row[2]),   # open_price
            float(row[3]),   # high_price
            float(row[4]),   # low_price
            float(row[5]),   # close_price
            float(row[6]),   # adj_close
            int(row[7])      # volume
        ])

print(f"✓ Cleaned CSV saved to {output_file}")
```

### Method 3: Using Command Line Tools

#### Convert from TSV to CSV:

```bash
# Tab-separated values to comma-separated
sed 's/\t/,/g' data.tsv > data.csv
```

#### Convert date format in CSV:

```bash
# Using awk to convert MM/DD/YYYY to YYYY-MM-DD
awk -F',' '{
    if (NR > 1) {
        split($1, date, "/")
        $1 = date[3] "-" date[1] "-" date[2]
    }
    print $0
}' old_data.csv > new_data.csv
```

---

## Import Methods

### Method 1: Using MySQL Command Line (Easiest)

#### Step 1: Save your CSV file

Save your file to a known location, e.g., `/home/user/stock_data.csv`

#### Step 2: Run import command

```bash
mysql -u your_username -p your_database_name << 'EOF'

LOAD DATA LOCAL INFILE '/home/user/stock_data.csv'
INTO TABLE daily_stock_prices
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS
(trading_date, ticker, open_price, high_price, low_price, close_price, adj_close, volume);

EOF
```

#### Step 3: Verify import

```bash
mysql -u your_username -p your_database_name -e "SELECT COUNT(*) FROM daily_stock_prices;"
```

### Method 2: Using MySQL GUI (Workbench, etc.)

**MySQL Workbench:**

1. Open MySQL Workbench
2. Connect to your database
3. Create new SQL tab
4. Paste this query:

```sql
LOAD DATA LOCAL INFILE '/absolute/path/to/stock_data.csv'
INTO TABLE daily_stock_prices
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS
(trading_date, ticker, open_price, high_price, low_price, close_price, adj_close, volume);
```

5. Click Execute (lightning bolt icon)
6. Watch for success message

### Method 3: Multiple Files (All Tickers)

If you have separate CSV files per ticker:

```sql
-- Import IXN
LOAD DATA LOCAL INFILE '/path/to/ixn_data.csv'
INTO TABLE daily_stock_prices
FIELDS TERMINATED BY ','
IGNORE 1 ROWS
(trading_date, ticker, open_price, high_price, low_price, close_price, adj_close, volume);

-- Import AAPL
LOAD DATA LOCAL INFILE '/path/to/aapl_data.csv'
INTO TABLE daily_stock_prices
FIELDS TERMINATED BY ','
IGNORE 1 ROWS
(trading_date, ticker, open_price, high_price, low_price, close_price, adj_close, volume);

-- Import GLD
LOAD DATA LOCAL INFILE '/path/to/gld_data.csv'
INTO TABLE daily_stock_prices
FIELDS TERMINATED BY ','
IGNORE 1 ROWS
(trading_date, ticker, open_price, high_price, low_price, close_price, adj_close, volume);
```

### Method 4: Using a Script

#### Python Script:

```python
import mysql.connector
import csv

# Database connection
conn = mysql.connector.connect(
    host="localhost",
    user="your_username",
    password="your_password",
    database="your_database"
)

cursor = conn.cursor()

# Read CSV and insert
with open('stock_data.csv', 'r') as file:
    reader = csv.DictReader(file)
    for row in reader:
        sql = """
        INSERT INTO daily_stock_prices 
        (trading_date, ticker, open_price, high_price, low_price, close_price, adj_close, volume)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """
        values = (
            row['trading_date'],
            row['ticker'],
            float(row['open_price']),
            float(row['high_price']),
            float(row['low_price']),
            float(row['close_price']),
            float(row['adj_close']),
            int(row['volume'])
        )
        cursor.execute(sql, values)

conn.commit()
print(f"✓ Imported {cursor.rowcount} rows")
cursor.close()
conn.close()
```

#### Bash Script:

```bash
#!/bin/bash

CSV_FILE="stock_data.csv"
DB_USER="your_username"
DB_PASS="your_password"
DB_NAME="your_database"

mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" << EOF
LOAD DATA LOCAL INFILE '$CSV_FILE'
INTO TABLE daily_stock_prices
FIELDS TERMINATED BY ','
IGNORE 1 ROWS
(trading_date, ticker, open_price, high_price, low_price, close_price, adj_close, volume);
EOF

echo "Import complete!"
```

---

## Troubleshooting

### Error: "LOAD DATA LOCAL not enabled"

```
ERROR 3948: Loading local data is disabled
```

**Solution:**

```sql
SET GLOBAL local_infile = 1;
```

Then reconnect and retry.

---

### Error: "File not found"

```
ERROR 2: Can't find file '/path/to/file.csv'
```

**Solutions:**

- Use absolute path (not relative): `/home/user/data.csv` instead of `./data.csv`
- Check file exists: `ls -la /path/to/file.csv`
- Use forward slashes: `/home/user/data.csv` (not Windows backslashes)
- Fix permissions: `chmod 644 file.csv`

---

### Error: "Incorrect date format"

```
ERROR 1292: Incorrect date value: '06-18-2026' for column 'trading_date'
```

**Solution:**

- Ensure date format is **YYYY-MM-DD** (2026-06-18)
- Not MM-DD-YYYY or DD-MM-YYYY
- Convert before importing

---

### Error: "Data truncated for column"

```
ERROR 1406: Data too long for column 'ticker'
```

**Solution:**

- Ticker must be ≤ 10 characters
- Check CSV for extra spaces or long values
- Trim spaces: `TRIM(ticker)`

---

### Error: "Duplicate entry"

```
ERROR 1062: Duplicate entry '2026-06-18-IXN'
```

**Solution:**

- Delete existing data: `DELETE FROM daily_stock_prices WHERE ticker = 'IXN';`
- Or use INSERT IGNORE to skip duplicates:

```sql
LOAD DATA LOCAL INFILE '/path/to/file.csv'
INTO TABLE daily_stock_prices
FIELDS TERMINATED BY ','
IGNORE 1 ROWS
(trading_date, ticker, open_price, high_price, low_price, close_price, adj_close, volume)
ON DUPLICATE KEY UPDATE close_price = VALUES(close_price);
```

---

### Error: "Wrong number of fields"

```
ERROR 1353: Wrong number of fields in CSV file
```

**Solution:**

- Check CSV has exactly 8 columns
- No extra commas or missing values
- Open in text editor to verify

---

## Examples

### Example 1: Import Single Ticker CSV

**File:** `ixn_data.csv`

```csv
trading_date,ticker,open_price,high_price,low_price,close_price,adj_close,volume
2026-06-18,IXN,145.03,146.63,144.49,146.33,146.33,361000
2026-06-17,IXN,143.42,144.21,140.72,141.04,141.04,213500
2026-06-16,IXN,144.26,144.99,140.94,141.03,141.03,270200
```

**Import Command:**

```sql
LOAD DATA LOCAL INFILE '/home/user/ixn_data.csv'
INTO TABLE daily_stock_prices
FIELDS TERMINATED BY ','
IGNORE 1 ROWS
(trading_date, ticker, open_price, high_price, low_price, close_price, adj_close, volume);
```

---

### Example 2: Import Multiple Tickers Combined

**File:** `all_tickers.csv`

```csv
trading_date,ticker,open_price,high_price,low_price,close_price,adj_close,volume
2026-06-18,IXN,145.03,146.63,144.49,146.33,146.33,361000
2026-06-18,GLD,214.71,215.50,214.45,214.99,214.99,4977800
2026-06-18,AAPL,225.50,227.35,224.80,226.75,226.75,52500000
2026-06-17,IXN,143.42,144.21,140.72,141.04,141.04,213500
2026-06-17,GLD,212.39,213.11,212.12,212.58,212.58,4690300
2026-06-17,AAPL,224.25,226.50,223.90,225.10,225.10,48750000
```

**Import Command:**

```sql
LOAD DATA LOCAL INFILE '/home/user/all_tickers.csv'
INTO TABLE daily_stock_prices
FIELDS TERMINATED BY ','
IGNORE 1 ROWS
(trading_date, ticker, open_price, high_price, low_price, close_price, adj_close, volume);
```

---

### Example 3: Import and Replace Existing Data

If the CSV ticker data already exists and you want to update:

```sql
DELETE FROM daily_stock_prices WHERE ticker = 'AAPL';

LOAD DATA LOCAL INFILE '/home/user/aapl_data.csv'
INTO TABLE daily_stock_prices
FIELDS TERMINATED BY ','
IGNORE 1 ROWS
(trading_date, ticker, open_price, high_price, low_price, close_price, adj_close, volume);
```

---

## Verification Checklist

After importing, verify:

```sql
-- 1. Check total count
SELECT COUNT(*) as total_rows FROM daily_stock_prices;

-- 2. Check by ticker
SELECT ticker, COUNT(*) as count
FROM daily_stock_prices
GROUP BY ticker;

-- 3. Check date range
SELECT MIN(trading_date), MAX(trading_date)
FROM daily_stock_prices;

-- 4. Sample data
SELECT * FROM daily_stock_prices LIMIT 10;

-- 5. Check for nulls
SELECT COUNT(*) FROM daily_stock_prices
WHERE trading_date IS NULL OR ticker IS NULL OR close_price IS NULL;
-- Should return 0
```

---

## Performance Tips

For large CSV files (> 100,000 rows):

```sql
-- Disable indexes during import
ALTER TABLE daily_stock_prices DISABLE KEYS;

-- Do your LOAD DATA import here
LOAD DATA LOCAL INFILE '/path/to/large_file.csv'
INTO TABLE daily_stock_prices
FIELDS TERMINATED BY ','
IGNORE 1 ROWS
(trading_date, ticker, open_price, high_price, low_price, close_price, adj_close, volume);

-- Re-enable indexes
ALTER TABLE daily_stock_prices ENABLE KEYS;

-- This can be 5-10x faster!
```

---

## CSV Tools

| Tool | Purpose | Notes |
|------|---------|-------|
| `csvstat` | Analyze CSV | `pip install csvkit` |
| `csvsort` | Sort CSV | From csvkit |
| `csvgrep` | Filter CSV | From csvkit |
| Excel/Sheets | Edit data | Easy UI |
| Python pandas | Process data | `import pandas as pd` |
| OpenOffice Calc | Edit/convert | Free alternative to Excel |

---

## Next Steps

1. ✓ Create CSV file with correct format
2. ✓ Enable local_infile if needed
3. ✓ Run LOAD DATA command
4. ✓ Verify with SELECT queries
5. → Analyze data with FRIEND_SQL_FOR_REAL_DATA.sql

---

**Repository:** https://github.com/seyhasenganz/my-sql-assignment/

For more help, see:
- `FRIEND_DATA_IMPORT_GUIDE.md` - General import guide
- `FRIEND_HOW_TO_RUN_IMPORT.md` - Quick start
- `FRIEND_STEP_BY_STEP_GUIDE.md` - Complete tutorial
