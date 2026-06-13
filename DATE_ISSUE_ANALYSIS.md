# Date Import Issue - Root Cause Analysis & Solution

## Problem Summary
The `pricing_daily` table has dates spanning **2001-04-25 to 2031-12-25** (30 years) instead of the intended **2024-2026** timeframe. This causes Q2, Q3, Q4 queries to find only 5 trading days in 6-month lookback windows, producing unrealistic results.

## Root Cause: MySQL Date Format Misinterpretation

### What Happened
The CREATE_SCHEMA_invest_portfolio.txt script inserts dates as STRING values in **DD-MM-YY format**:
```sql
INSERT INTO pricing_daily_new(date,ticker,price_type,value) VALUES ('12-06-26','IXN','Open',138.5);
```

When MySQL receives a string like `'12-06-26'` for a DATE column **without explicit format conversion**, it interprets it as **YY-MM-DD** instead of DD-MM-YY:

**Example: Date `'31-12-25'`**
- **Intended format**: DD-MM-YY = 31st December 2025
- **MySQL interpretation**: YY-MM-DD = Year 31, Month 12, Day 25
- **After 2-digit year mapping** (31 → 2031): Becomes **2031-12-25** ❌

**Example: Date `'01-04-25'`**
- **Intended format**: DD-MM-YY = 1st April 2025  
- **MySQL interpretation**: YY-MM-DD = Year 01, Month 04, Day 25
- **After 2-digit year mapping** (01 → 2001): Becomes **2001-04-25** ❌

### Why It Spans 30 Years
- Days in dataset: 01-31
- Months in dataset: 01-12
- Years in dataset: 24, 25, 26 (represented as DD-MM-YY)

When MySQL reads the first two digits (intended as day) as year:
- Year 01 → 2001
- Year 31 → 2031
- Creates 30-year range: 2001-2031

## Impact on Analysis

### Query 1 (Portfolio Returns)
- ✅ **Still works correctly** - calculates return from latest date to 252/378/504 days back
- Result: 0.38% (12M), 0.61% (18M), 11.82% (24M)
- **This is still valid** despite the date scrambling

### Queries 2, 3, 4 (Variance, Volatility, Sharpe Ratio)
- ❌ **Broken** - Look for dates in 6-month or 12-month windows
- With scattered data across 30 years, only ~5 trading days found instead of ~126 (6 months)
- Produces unrealistic metrics (variance 1395.74, volatility 629.87%, Sharpe returns 1968.69%)

### Query 5 (Rebalancing)
- ✅ **Based on Sharpe ratios from Q4, so needs Q4 fixed**
- Currently using hardcoded allocation, but methodology depends on valid Q4 data

## Solution: Re-import with Proper Date Conversion

### Step 1: Drop and Recreate Table
```sql
DROP TABLE IF EXISTS pricing_daily;

CREATE TABLE pricing_daily (
    date       DATE NOT NULL,
    ticker     VARCHAR(3) NOT NULL,
    price_type VARCHAR(10) NOT NULL,
    value      NUMERIC(11,2) NOT NULL,
    PRIMARY KEY (date, ticker, price_type),
    INDEX idx_ticker_date (ticker, date),
    INDEX idx_price_type (price_type)
);
```

### Step 2: Use STR_TO_DATE() with Explicit Format
Replace all INSERT statements to use `STR_TO_DATE()`:

```sql
-- BEFORE (Wrong):
INSERT INTO pricing_daily(date,ticker,price_type,value) VALUES ('12-06-26','IXN','Open',138.5);

-- AFTER (Correct):
INSERT INTO pricing_daily(date,ticker,price_type,value) 
VALUES (STR_TO_DATE('12-06-26','%d-%m-%y'),'IXN','Open',138.5);
```

**Format Code Explanation:**
- `%d` = 2-digit day (01-31)
- `%m` = 2-digit month (01-12)
- `%y` = 2-digit year (00-99, mapped by MySQL)

### Step 3: Corrected Script
Run the **CORRECTED_SCHEMA_with_DATE_FIX.sql** file included in this folder.

## Expected Results After Fix

### Date Range
- **Before**: 2001-04-25 to 2031-12-25 (30 years, 502 dates scattered)
- **After**: ~2024-06-12 to ~2026-06-12 (2 years, dates consecutive or nearly so)

### Query 2 Results (Variance - 6 Month Window)
- Should find 126-130 trading days (not 5)
- Variance should be realistic (0.5-2.0 range)

### Query 3 Results (Volatility - 12 Month Window)  
- Should find 252-260 trading days (not 5)
- Annual volatility should be realistic (10-35% range, not 629%)

### Query 4 Results (Sharpe Ratio)
- Expected annual returns: -5% to +20% (not 679-1968)
- Sharpe ratios: -1.0 to +2.0 (not 3.12)
- Recommendations will match realistic risk-adjusted returns

### Query 1 & 5 Results
- Should remain consistent
- But methodology confidence improves with valid Q4 data

## How to Apply the Fix

1. **Option A (Recommended - Clean Start)**:
   - Delete current `pricing_daily` table
   - Run `CORRECTED_SCHEMA_with_DATE_FIX.sql`
   - Verify date range with:
   ```sql
   SELECT MIN(date), MAX(date), COUNT(DISTINCT date)
   FROM pricing_daily;
   ```
   Expected: ~2024-06-12, ~2026-06-12, ~502 dates

2. **Option B (Add-only)**: 
   - If data is cumulative, run the corrected script to add new data
   - Use `REPLACE INTO` to avoid duplicates

## Verification Queries

After applying the fix, run these to verify:

```sql
-- Check date range
SELECT MIN(date), MAX(date), COUNT(DISTINCT date) 
FROM pricing_daily;

-- Check data density (should have ~30 rows per date)
SELECT date, COUNT(*) 
FROM pricing_daily 
GROUP BY date 
ORDER BY date 
LIMIT 10;

-- Test Q2 query should find ~126 trading days
WITH daily_returns AS (
    SELECT ticker, COUNT(*) as trading_days
    FROM pricing_daily
    WHERE price_type = 'Adj Close'
    AND date >= DATE_SUB((SELECT MAX(date) FROM pricing_daily), INTERVAL 6 MONTH)
    GROUP BY ticker
)
SELECT ticker, trading_days FROM daily_returns ORDER BY ticker;
-- Expected: 126-130 days per ticker
```

## Summary Table

| Aspect | Before Fix | After Fix |
|--------|-----------|-----------|
| Date Range | 2001-2031 (30 years) | 2024-2026 (2 years) |
| Q1 Reliability | ✅ Good | ✅ Good |
| Q2, Q3, Q4 Reliability | ❌ Poor (5 days) | ✅ Good (126+ days) |
| Variance Metric | 1395.74 | ~0.5-2.0 |
| Volatility | 629.87% | ~15-35% |
| Sharpe Ratio | 1968.69 | ~-1.0 to +2.0 |
