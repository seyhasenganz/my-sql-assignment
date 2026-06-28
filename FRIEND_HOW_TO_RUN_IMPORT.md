# FRIEND_HOW_TO_RUN_IMPORT.md

## Quick Start: How to Import Stock Price Data

**5-minute guide to get your data into the database!**

---

## ⚡ Fastest Method (Recommended)

### Step 1: Use the Pre-Made SQL File

The easiest way is to use the already-formatted `aligned_stock_prices.sql` file:

```bash
# From command line
mysql -u your_username -p your_database_name < aligned_stock_prices.sql
```

Or from within MySQL:

```sql
-- In MySQL prompt
SOURCE aligned_stock_prices.sql;
```

### Step 2: Verify It Worked

```sql
SELECT COUNT(*) FROM daily_stock_prices;
SELECT DISTINCT ticker FROM daily_stock_prices;
```

**Done!** ✓

---

## 📋 Step-by-Step Instructions

### For MySQL Command Line Users

```bash
# 1. Connect to MySQL
mysql -u your_username -p

# 2. Select your database
USE your_database_name;

# 3. Import the data file
SOURCE /path/to/aligned_stock_prices.sql;

# 4. Verify (should show number of records)
SELECT COUNT(*) FROM daily_stock_prices;

# 5. See what tickers you have
SELECT DISTINCT ticker FROM daily_stock_prices;
```

### For MySQL Workbench Users

1. **Connect** to your MySQL server
2. **Open** a new SQL query tab
3. **File → Open SQL Script → `aligned_stock_prices.sql`**
4. Click the **Execute** button (⚡ icon)
5. Watch the progress bar
6. See the success message

### For phpMyAdmin Users

1. Go to your database
2. Click **Import** tab
3. Click **Choose File** and select `aligned_stock_prices.sql`
4. Click **Go** button
5. Wait for completion

---

## 🐍 For Python Users

```python
import mysql.connector

# Connect to database
conn = mysql.connector.connect(
    host="localhost",
    user="your_username",
    password="your_password",
    database="your_database"
)

cursor = conn.cursor()

# Read and execute the SQL file
with open('aligned_stock_prices.sql', 'r') as f:
    sql_script = f.read()
    
for statement in sql_script.split(';'):
    if statement.strip():
        cursor.execute(statement)

conn.commit()
print(f"✓ Imported successfully!")

# Verify
cursor.execute("SELECT COUNT(*) FROM daily_stock_prices")
count = cursor.fetchone()[0]
print(f"Total records: {count}")

cursor.close()
conn.close()
```

---

## 📊 Alternative Method: CSV Import

If you have CSV data instead:

```sql
LOAD DATA LOCAL INFILE '/path/to/your_data.csv'
INTO TABLE daily_stock_prices
FIELDS TERMINATED BY ','
IGNORE 1 ROWS
(trading_date, ticker, open_price, high_price, low_price, close_price, adj_close, volume);
```

---

## ✅ Verification Commands

Run these to verify everything worked:

```sql
-- Total records imported
SELECT COUNT(*) as total_records FROM daily_stock_prices;

-- Records by ticker
SELECT ticker, COUNT(*) as count
FROM daily_stock_prices
GROUP BY ticker
ORDER BY ticker;

-- Date range
SELECT MIN(trading_date) as earliest, MAX(trading_date) as latest
FROM daily_stock_prices;

-- Sample records
SELECT * FROM daily_stock_prices LIMIT 10;
```

---

## 🆘 Common Issues & Quick Fixes

### Issue: "Table doesn't exist"

```sql
-- First create the table
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

-- Then import
SOURCE aligned_stock_prices.sql;
```

### Issue: "File not found"

- Use full path: `/home/user/aligned_stock_prices.sql`
- Not: `./aligned_stock_prices.sql`
- Check the file exists: `ls -la /path/to/file.sql`

### Issue: "LOAD DATA LOCAL not enabled"

```sql
SET GLOBAL local_infile = 1;
-- Then reconnect and try again
```

### Issue: "Permission denied"

```bash
# Fix file permissions
chmod 644 aligned_stock_prices.sql

# Or move to a writable location
mv aligned_stock_prices.sql ~/aligned_stock_prices.sql
```

---

## 🚀 Command Cheat Sheet

```bash
# Connect to MySQL
mysql -u username -p database_name

# Import from file
mysql -u username -p database < aligned_stock_prices.sql

# Import with password in command (less secure)
mysql -u username -ppassword database < aligned_stock_prices.sql

# Check if import worked
mysql -u username -p database -e "SELECT COUNT(*) FROM daily_stock_prices;"
```

---

## 📝 Inside MySQL Shell

```sql
-- Show current database
SELECT DATABASE();

-- List all tables
SHOW TABLES;

-- View table structure
DESCRIBE daily_stock_prices;

-- Import data
SOURCE aligned_stock_prices.sql;

-- Count records
SELECT COUNT(*) FROM daily_stock_prices;

-- View sample data
SELECT * FROM daily_stock_prices LIMIT 10;

-- List unique tickers
SELECT DISTINCT ticker FROM daily_stock_prices ORDER BY ticker;

-- Exit MySQL
EXIT;
or
QUIT;
```

---

## 📈 Next Steps After Importing

Once your data is imported:

1. **Run test queries** → See `FRIEND_ASSIGNMENT_BEGINNER_GUIDE.sql`
2. **Analyze data** → See `FRIEND_SQL_FOR_REAL_DATA.sql`
3. **Learn SQL** → See `FRIEND_STEP_BY_STEP_GUIDE.md`
4. **Advanced queries** → See `FRIEND_IMPORT_CODE_FOR_ALL_TICKER.sql`

---

## 🎯 Complete Workflow

```sql
-- Step 1: Create database (if not exists)
CREATE DATABASE IF NOT EXISTS stock_prices;

-- Step 2: Use the database
USE stock_prices;

-- Step 3: Create table
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

-- Step 4: Import data
SOURCE aligned_stock_prices.sql;

-- Step 5: Verify
SELECT COUNT(*) as total FROM daily_stock_prices;
SELECT DISTINCT ticker FROM daily_stock_prices;

-- Step 6: Start analyzing!
SELECT ticker, AVG(close_price) FROM daily_stock_prices GROUP BY ticker;
```

---

## 💡 Pro Tips

1. **Always use LIMIT** when exploring data
   ```sql
   SELECT * FROM daily_stock_prices LIMIT 10;  -- Good
   SELECT * FROM daily_stock_prices;            -- Bad (too much output)
   ```

2. **Check before deleting**
   ```sql
   SELECT COUNT(*) FROM daily_stock_prices;
   -- Only delete if you're sure
   DELETE FROM daily_stock_prices;
   ```

3. **Backup before large operations**
   ```bash
   mysqldump -u username -p database > backup.sql
   ```

4. **Use indexes for speed**
   - Already included in table creation
   - Queries on `ticker` and `trading_date` will be fast

5. **Disable keys for faster bulk import**
   ```sql
   ALTER TABLE daily_stock_prices DISABLE KEYS;
   SOURCE aligned_stock_prices.sql;
   ALTER TABLE daily_stock_prices ENABLE KEYS;
   ```

---

## 🔗 Related Files

- `FRIEND_STEP_BY_STEP_GUIDE.md` - Detailed tutorial
- `FRIEND_DATA_IMPORT_GUIDE.md` - Complete import reference
- `FRIEND_IMPORT_ALL_TICKER_CSV.md` - CSV import guide
- `FRIEND_ASSIGNMENT_BEGINNER_GUIDE.sql` - Sample queries
- `FRIEND_SQL_FOR_REAL_DATA.sql` - Advanced queries
- `FRIEND_IMPORT_CODE_FOR_ALL_TICKER.sql` - Multi-ticker examples

---

## ❓ Quick FAQ

**Q: How long does import take?**
A: Usually 5-30 seconds for 2500+ records

**Q: Can I import multiple times?**
A: Yes, but you'll get duplicates unless you delete first

**Q: What if import fails halfway?**
A: Delete and retry: `DELETE FROM daily_stock_prices; SOURCE aligned_stock_prices.sql;`

**Q: How much disk space needed?**
A: ~10-20 MB for 2500+ records

**Q: Can I import while querying?**
A: Yes, but locks may occur. Best to import during off-hours.

---

## 🎓 Learning Resources

- MySQL Official Docs: https://dev.mysql.com/doc/
- SQL Tutorial: https://www.w3schools.com/sql/
- Our Guides: See this repository at https://github.com/seyhasenganz/my-sql-assignment/

---

**That's it! You're ready to start.** 🎉

For detailed information, check the other FRIEND_*.md files in this repository.
