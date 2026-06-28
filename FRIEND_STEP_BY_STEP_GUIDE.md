# BEGINNER'S COMPLETE GUIDE TO PORTFOLIO ANALYSIS ASSIGNMENT
## For Students New to SQL and MySQL

---

## 📋 TABLE OF CONTENTS
1. [What You'll Learn](#what-youll-learn)
2. [Setup Instructions](#setup-instructions)
3. [Step 1: Create Database](#step-1-create-database)
4. [Step 2: Load Your Data](#step-2-load-your-data)
5. [Understanding Each Question](#understanding-each-question)
6. [Running Queries & Getting Results](#running-queries--getting-results)
7. [Writing Your Report](#writing-your-report)
8. [Troubleshooting](#troubleshooting)

---

## WHAT YOU'LL LEARN

By the end of this assignment, you'll understand:
- ✅ How to create database tables
- ✅ How to import real data from Excel
- ✅ How to calculate investment returns
- ✅ How to measure investment risk (volatility)
- ✅ How to compare investments (Sharpe ratio)
- ✅ How to recommend portfolio changes

---

## SETUP INSTRUCTIONS

### Step A: Download MySQL Workbench
1. Go to: https://www.mysql.com/products/workbench/
2. Download and install (free version is fine)
3. Open MySQL Workbench

### Step B: Create a Connection (if you don't have one)
1. Click "MySQL Connections" → "+" button
2. Connection Name: `MyPortfolio`
3. Hostname: `localhost`
4. Username: `root`
5. Password: (your MySQL password)
6. Click "Test Connection" → OK

### Step C: Open a Query Tab
1. Double-click your connection to open it
2. Click File → New Query Tab
3. Ready to write SQL!

---

## STEP 1: CREATE DATABASE

Copy this code into MySQL Workbench and run it:

```sql
CREATE DATABASE IF NOT EXISTS portfolio_analysis;
USE portfolio_analysis;
```

**What this does:**
- Creates a new database called `portfolio_analysis`
- Tells MySQL to use that database for the next queries

**How to run:**
1. Paste the code
2. Select all (Ctrl+A)
3. Click the **lightning bolt** button to execute
4. You should see: "Query executed successfully"

---

## STEP 2: CREATE TABLES

### Table 1: Daily Prices

This table stores all the daily closing prices for each ticker.

```sql
DROP TABLE IF EXISTS daily_prices;

CREATE TABLE daily_prices (
    price_id       INT AUTO_INCREMENT PRIMARY KEY,
    trading_date   DATE NOT NULL,
    ticker         VARCHAR(10) NOT NULL,
    closing_price  DECIMAL(10, 2) NOT NULL,
    INDEX idx_ticker_date (ticker, trading_date)
);
```

**What each column means:**
- `price_id`: Unique ID for each row (auto-increments)
- `trading_date`: The date (e.g., 2024-06-12)
- `ticker`: Stock symbol (IXN, QQQ, etc.)
- `closing_price`: Price at end of day

**Run this query in MySQL Workbench.**

### Table 2: Ticker Information

This table stores information about each security.

```sql
DROP TABLE IF EXISTS ticker_info;

CREATE TABLE ticker_info (
    ticker           VARCHAR(10) PRIMARY KEY,
    security_name    VARCHAR(100) NOT NULL,
    current_percent  DECIMAL(5, 2) NOT NULL,
    asset_class      VARCHAR(50) NOT NULL
);
```

**Run this query in MySQL Workbench.**

---

## STEP 3: INSERT TICKER INFORMATION

This adds the 5 tickers and their allocation percentages.

```sql
INSERT INTO ticker_info (ticker, security_name, current_percent, asset_class) VALUES
('IXN', 'iShares Global Tech ETF', 17.5, 'Equity'),
('QQQ', 'NASDAQ 100', 22.1, 'Equity'),
('IEF', 'iShares 7-10 Year Treasury Bond ETF', 28.5, 'Fixed Income'),
('VNQ', 'Vanguard Real Estate ETF', 8.9, 'Real Assets'),
('GLD', 'SPDR Gold Shares', 23.0, 'Commodities');
```

**Run this query in MySQL Workbench.**

---

## STEP 4: LOAD YOUR DATA

### Option A: Import from Excel (Recommended)

**Step 1: Convert Excel to CSV**
1. Open your Excel file (All_ticker.xlsx)
2. File → Save As → Choose "CSV (Comma delimited)"
3. Save as `portfolio_data.csv`
4. Note the file location (e.g., `C:\Users\YourName\Documents\portfolio_data.csv`)

**Step 2: Import into MySQL Workbench**
1. In MySQL Workbench, go to Server → Data Import
2. Choose "Import from Self-Contained File"
3. Select your `portfolio_data.csv` file
4. Click "Start Import"
5. MySQL Workbench will load the data

### Option B: Manual Insert (If Import Doesn't Work)

Copy your data row by row:

```sql
INSERT INTO daily_prices (trading_date, ticker, closing_price) VALUES
('2024-06-12', 'IXN', 138.50),
('2024-06-11', 'IXN', 137.20),
('2024-06-10', 'IXN', 136.80),
('2024-06-12', 'QQQ', 425.30),
('2024-06-11', 'QQQ', 423.50),
-- Continue for all your data...
;
```

### Verify Data Loaded

Run this query to check:

```sql
SELECT
    ticker,
    COUNT(*) as total_records,
    MIN(trading_date) as earliest_date,
    MAX(trading_date) as latest_date
FROM daily_prices
GROUP BY ticker
ORDER BY ticker;
```

**Expected result:** Shows each ticker with number of records and date range.

---

## UNDERSTANDING EACH QUESTION

### QUESTION 1: RETURNS (20 POINTS)

**What is it?**
- How much money did the investment gain or lose?
- Example: Buy at $100, sell at $112 = 12% return

**How to calculate:**
```
Return = ((New Price - Old Price) / Old Price) × 100%
```

**Time periods:**
- 12M = 252 trading days (1 year)
- 18M = 378 trading days (1.5 years)
- 24M = 504 trading days (2 years)

**What to expect:**
- High returns (>20%) = good investment
- Low returns (<5%) = poor investment
- Negative returns = lost money

---

### QUESTION 2: VARIANCE (20 POINTS)

**What is it?**
- How much a price bounces up and down
- High variance = risky (big swings)
- Low variance = safe (small swings)

**Simple way to think about it:**
- Asset A: Price goes from $100 to $120 (big swing = high variance)
- Asset B: Price goes from $100 to $102 (small swing = low variance)

**What to compare:**
```
If IXN variance = 3.25 and IEF variance = 0.09
Then: IXN is 36x more risky than IEF (3.25 ÷ 0.09)
```

---

### QUESTION 3: SIGMA (VOLATILITY) (20 POINTS)

**What is it?**
- σ (sigma) = annual risk measurement
- Shows how much price could swing in a year
- Example: σ = 20% means price could move ±20% annually

**Formula:**
```
Sigma = Daily Volatility × √252 (trading days/year)
```

**Risk levels:**
- σ > 25% = HIGH RISK (growth stocks, commodities)
- σ 15-25% = MODERATE RISK (balanced)
- σ < 15% = LOW RISK (bonds, stable assets)

---

### QUESTION 4: SHARPE RATIO (20 POINTS)

**What is it?**
- "Return per unit of risk"
- Higher Sharpe = better investment
- Compares investments fairly by risk-adjusting returns

**Formula:**
```
Sharpe = (Annual Return - Risk-Free Rate) / Annual Volatility
```

**Example:**
- Asset X: Return 20%, Risk 10% → Sharpe = (20-2)/10 = 1.8
- Asset Y: Return 8%, Risk 4% → Sharpe = (8-2)/4 = 1.5
- Asset X is better (higher Sharpe for same risk)

**Recommendations:**
- Sharpe > 0.8 = STRONG BUY (excellent quality)
- Sharpe > 0.5 = BUY (good quality)
- Sharpe > 0.2 = HOLD (acceptable)
- Sharpe ≤ 0.2 = SELL (poor quality)

---

### QUESTION 5: REBALANCING (20 POINTS)

**What is it?**
- Should we buy, sell, or hold each investment?
- Goal: Maximize returns while minimizing risk

**How to decide:**
1. Look at Sharpe ratios from Question 4
2. Holdings with high Sharpe → increase (BUY)
3. Holdings with low Sharpe → decrease (SELL)
4. Holdings with medium Sharpe → hold (MAINTAIN)

**Example:**
| Ticker | Sharpe | Current | Proposed | Action |
|--------|--------|---------|----------|--------|
| IXN | 2.01 | 17.5% | 20% | BUY $2.4M |
| QQQ | 1.76 | 22.1% | 25% | BUY $2.8M |
| GLD | 0.85 | 23% | 22% | HOLD/TRIM |
| VNQ | 0.82 | 8.9% | 18% | BUY $8.6M |
| IEF | 0.31 | 28.5% | 15% | SELL $12.8M |

---

## RUNNING QUERIES & GETTING RESULTS

### Step 1: Run Question 1 Query

1. Copy the "QUESTION 1" code from `FRIEND_ASSIGNMENT_BEGINNER_GUIDE.sql`
2. Paste into MySQL Workbench
3. Click the **lightning bolt** to execute
4. Results appear in "Result Grid" below

### Step 2: Screenshot the Results

1. In Results Grid, press Ctrl+A to select all
2. Right-click → "Copy with Headers"
3. Paste into Excel or Word
4. This is one screenshot for your report

### Step 3: Repeat for Questions 2-5

- Copy each question's code
- Execute it
- Screenshot the results
- Paste into your report

---

## WRITING YOUR REPORT

### Report Structure (PDF)

**Step 1: Introduction**
- Client background
- Portfolio summary ($95M, 5 holdings)
- What you're analyzing

**Step 2: Methodology**
- Explain each question briefly
- Show the SQL code you used
- Explain what each SQL part does

**Step 3: Results for Each Question**
For each of the 5 questions:
1. Show the query results (screenshot/table)
2. Explain what the results mean
3. Provide recommendations

**Example for Question 1:**
```
QUESTION 1: RETURNS

SQL Query:
[show the SQL code]

Results:
[show the screenshot/table]

Analysis:
IXN had a 34.51% 12-month return, the best performer in the portfolio.
QQQ returned 19.89%, which is solid.
IEF returned only 0.21%, which is concerning.

Recommendation:
The portfolio should consider increasing IXN and QQQ allocation...
```

**Step 4: Overall Recommendations**
- Summary of findings
- Which holdings to buy/sell
- Expected impact on returns and risk

**Step 5: Conclusion**
- Final thoughts
- How client's portfolio will improve

---

## TROUBLESHOOTING

### Problem: "Table already exists"
**Solution:** Make sure you're using `DROP TABLE IF EXISTS` at the start

### Problem: "Data not loading from CSV"
**Solution:** 
- Check CSV format (Date, Ticker, Price)
- Make sure date format is YYYY-MM-DD
- Try manual insert instead

### Problem: "Query syntax error"
**Solution:**
- Check for missing semicolons (;)
- Make sure all quotes are paired
- Look for typos in table/column names

### Problem: "No results returned"
**Solution:**
- Check if data actually loaded: `SELECT COUNT(*) FROM daily_prices;`
- Check date range: `SELECT MIN(trading_date), MAX(trading_date) FROM daily_prices;`
- If no data, go back to Step 4

### Problem: "I don't understand the SQL"
**Solution:**
- Read the comments in the code (lines starting with --)
- Break queries into smaller pieces
- Ask your professor or teaching assistant

---

## QUICK REFERENCE

### Essential MySQL Commands
```sql
-- Show all databases
SHOW DATABASES;

-- Use a database
USE portfolio_analysis;

-- Show all tables
SHOW TABLES;

-- See table structure
DESCRIBE daily_prices;

-- Count rows
SELECT COUNT(*) FROM daily_prices;

-- See first 10 rows
SELECT * FROM daily_prices LIMIT 10;

-- Delete all data (be careful!)
DELETE FROM daily_prices;

-- See latest date in data
SELECT MAX(trading_date) FROM daily_prices;
```

---

## SUBMISSION CHECKLIST

Before submitting your PDF, make sure you have:

- [ ] Database created with correct table names
- [ ] All data loaded (verified with SELECT COUNT)
- [ ] Question 1: Returns calculated for 12M, 18M, 24M
- [ ] Question 2: Variance compared between holdings
- [ ] Question 3: Sigma (volatility) calculated and risk levels assigned
- [ ] Question 4: Sharpe ratios calculated with buy/hold/sell recommendations
- [ ] Question 5: Rebalancing proposal with dollar amounts
- [ ] All 5 SQL queries included in report
- [ ] All results shown as screenshots/tables
- [ ] Clear explanations of what each result means
- [ ] Professional recommendations for the client
- [ ] PDF format (not Word or other format)

---

## GRADING RUBRIC (100 POINTS TOTAL)

**Q1: Returns (20 points)**
- Correct 12M, 18M, 24M calculations
- Clear explanation of results
- Reasonable conclusions

**Q2: Variance (20 points)**
- Correct variance calculations
- Comparison between holdings
- Interpretation of differences

**Q3: Sigma/Volatility (20 points)**
- Correct annualized volatility
- Risk level classification
- Portfolio volatility calculated

**Q4: Sharpe Ratio (20 points)**
- Correct calculation
- Buy/hold/sell recommendations
- Justification for each recommendation

**Q5: Rebalancing (20 points)**
- Clear proposal with percentages
- Dollar amounts for trades
- Expected impact on portfolio
- Detailed recommendations

---

## FINAL TIPS

✅ **DO:**
- Test each query before including it in your report
- Use clear, simple language in explanations
- Include all SQL code (even if it seems repetitive)
- Screenshot results clearly
- Provide specific dollar amounts for trades

❌ **DON'T:**
- Copy results without understanding them
- Skip explanations
- Use jargon without defining it
- Include too many queries (just the 5 questions)
- Submit as Word doc (must be PDF)

---

**Good luck with your assignment! You've got this! 🚀**

If you have questions, ask your professor or check the assignment rubric again.
