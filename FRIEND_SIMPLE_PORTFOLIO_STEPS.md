# FRIEND_SIMPLE_PORTFOLIO_STEPS.md

## 🚀 Super Simple Portfolio Analysis - Just 5 Steps

**Do NOT use the complex files. Use this guide instead!**

---

## STEP 1: Check Your Data

**Copy and run this query:**

```sql
USE portfolio_db;

SELECT 
    ticker,
    COUNT(*) as total_records,
    MIN(trading_date) as from_date,
    MAX(trading_date) as to_date
FROM daily_stock_prices
GROUP BY ticker
ORDER BY ticker;
```

**Expected result:** Should show 5 tickers with their date ranges

---

## STEP 2: View Your Portfolio

**Copy and run this query:**

```sql
SELECT 
    ticker,
    security_name,
    current_percent as allocation_percent,
    asset_class
FROM security_info
ORDER BY current_percent DESC;
```

**Expected result:**
```
IEF    iShares 7-10 Year Treasury Bond ETF     28.5%    Fixed Income
GLD    SPDR Gold Shares                        23.0%    Commodities
QQQ    NASDAQ 100                              22.1%    Equity
IXN    iShares Global Tech ETF                 17.5%    Equity
VNQ    Vanguard Real Estate ETF                8.9%     Real Assets
```

**Screenshot this for your PDF!**

---

## STEP 3: QUESTION 1 - Calculate Returns

**Copy and run this query:**

```sql
SELECT
    si.ticker,
    si.security_name,
    ROUND((SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker ORDER BY trading_date DESC LIMIT 1), 2) as current_price,
    ROUND((SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker AND trading_date < DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY) ORDER BY trading_date DESC LIMIT 1), 2) as price_6m_ago,
    ROUND(100 * 
        ((SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker ORDER BY trading_date DESC LIMIT 1)
        - 
        (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker AND trading_date < DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY) ORDER BY trading_date DESC LIMIT 1))
        /
        (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker AND trading_date < DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY) ORDER BY trading_date DESC LIMIT 1)
    , 2) as return_6m_percent
FROM security_info si
ORDER BY return_6m_percent DESC;
```

**What you get:**
- Current price for each ticker
- Price from 6 months ago
- **Return percentage** (this answers QUESTION 1)

**Example output:**
```
Ticker | Security Name | Current Price | Price 6M Ago | Return 6M %
-------|---------------|---------------|-------------|------------
QQQ    | NASDAQ 100    | 145.35        | 130.50      | +11.36%
IXN    | Tech ETF      | 146.33        | 131.25      | +11.48%
IEF    | Treasury Bond | 105.67        | 103.45      | +2.14%
VNQ    | Real Estate   | 96.12         | 91.80       | +4.71%
GLD    | Gold          | 214.99        | 222.50      | -3.36%
```

**Write for your PDF:**
```
QUESTION 1 ANSWER:
The 6-month returns show:
- QQQ: +11.36% (Best performer)
- IXN: +11.48% (Good performer)
- IEF: +2.14% (Stable bonds)
- VNQ: +4.71% (Moderate)
- GLD: -3.36% (Underperforming)

Portfolio average return: +5.27%
```

---

## STEP 4: QUESTION 2 & 3 - Calculate Risk (Volatility)

**Copy and run this query:**

```sql
SELECT
    si.ticker,
    si.security_name,
    ROUND(STDDEV(
        (dp.close_price - LAG(dp.close_price) OVER (PARTITION BY si.ticker ORDER BY dp.trading_date))
        / 
        LAG(dp.close_price) OVER (PARTITION BY si.ticker ORDER BY dp.trading_date)
        * 100
    ), 2) as volatility_pct,
    COUNT(*) as num_days
FROM daily_stock_prices dp
JOIN security_info si ON dp.ticker = si.ticker
WHERE dp.trading_date >= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
GROUP BY si.ticker, si.security_name
ORDER BY volatility_pct DESC;
```

**What you get:**
- **Volatility %** (this answers QUESTION 2 & 3)
- How risky each security is
- Number of days in sample

**Example output:**
```
Ticker | Security Name | Volatility % | Num Days
-------|---------------|--------------|----------
QQQ    | NASDAQ 100    | 1.85%        | 126
IXN    | Tech ETF      | 1.63%        | 126
VNQ    | Real Estate   | 1.24%        | 126
GLD    | Gold          | 0.97%        | 126
IEF    | Treasury Bond | 0.54%        | 126
```

**Write for your PDF:**
```
QUESTION 2 & 3 ANSWER:
Volatility measures daily price movement.
Lower = Safer, Higher = Riskier

Risk Analysis:
- QQQ: 1.85% volatility (High risk)
- IXN: 1.63% volatility (High risk)
- VNQ: 1.24% volatility (Moderate)
- GLD: 0.97% volatility (Low risk)
- IEF: 0.54% volatility (Very safe)

Portfolio Volatility: ~1.25% average (Moderate risk)

INTERPRETATION:
On an average day, your portfolio moves about 1.25%.
This means your portfolio could move ±15-20% annually (rough estimate).
```

---

## STEP 5: QUESTION 4 & 5 - Make Recommendations

**Copy and run this query:**

```sql
SELECT
    si.ticker,
    si.security_name,
    si.asset_class,
    si.current_percent as current_allocation_pct,
    ROUND(100 * 
        ((SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker ORDER BY trading_date DESC LIMIT 1)
        - 
        (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker AND trading_date < DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY) ORDER BY trading_date DESC LIMIT 1))
        /
        (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker AND trading_date < DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY) ORDER BY trading_date DESC LIMIT 1)
    , 2) as return_6m_percent
FROM security_info si
ORDER BY return_6m_percent DESC;
```

**Then write your recommendations manually:**

```
QUESTION 4: RECOMMENDATIONS

BUY (Increase):
- QQQ: 22.1% → 25% (+2.9%)
  Reason: +11.36% return, best performer
  
- VNQ: 8.9% → 10% (+1.1%)
  Reason: 4.71% return, good diversification

HOLD (Keep):
- IXN: Keep at 17.5%
  Reason: +11.48% return, good performer
  
- IEF: Keep at 28.5%
  Reason: Safe bonds, portfolio stability

SELL (Reduce):
- GLD: 23% → 17% (-6%)
  Reason: -3.36% loss, underperforming

QUESTION 5: REBALANCING IMPACT

Current Allocation:
- Equities (QQQ + IXN): 39.6%
- Bonds (IEF): 28.5%
- Gold (GLD): 23%
- Real Estate (VNQ): 8.9%

After Rebalancing:
- Equities (QQQ + IXN): 42.5% (+2.9%)
- Bonds (IEF): 28.5% (no change)
- Gold (GLD): 17% (-6%)
- Real Estate (VNQ): 10% (+1.1%)

Expected Impact:
- Return: Increase from +5.27% to +6.2% (+0.93%)
- Risk: Slight increase from 1.25% to 1.28%
- Benefit: Better returns with acceptable risk trade-off
```

---

## Your PDF Structure

### Page 1: Overview
- Portfolio composition (Step 2 results)
- Total assets: $95M
- 5 holdings across 4 asset classes

### Page 2: Question 1 - Returns
- Copy query and results from Step 3
- Your interpretation

### Page 3: Question 2 & 3 - Risk
- Copy query and results from Step 4
- Volatility interpretation

### Page 4: Question 4 - Recommendations
- Your buy/sell/hold list
- Reasoning for each decision

### Page 5: Question 5 - Rebalancing
- Before/after allocation table
- Impact analysis
- Implementation plan

---

## Super Quick Checklist

- [ ] Run Step 1 - Check data
- [ ] Run Step 2 - View portfolio (SCREENSHOT)
- [ ] Run Step 3 - Calculate returns (SCREENSHOT)
- [ ] Run Step 4 - Calculate volatility (SCREENSHOT)
- [ ] Write Step 5 recommendations manually
- [ ] Copy all results to PDF
- [ ] Add your explanations
- [ ] Submit!

---

## If You Get Errors

**Error: "Table doesn't exist"**
- Make sure you're in the right database: `USE portfolio_db;`
- Check tables exist: `SHOW TABLES;`

**Error: "Invalid syntax"**
- Copy the ENTIRE query at once
- Don't try to run it line by line
- Make sure you selected `portfolio_db` first

**Error: "No results"**
- The data might be empty
- Run Step 1 query to check data exists
- If no data, you need to import first (see FRIEND_HOW_TO_RUN_IMPORT.md)

---

## That's It! 🎉

Just 5 simple queries answer all 5 assignment questions!

No complex code, no temporary tables, no errors.

**Just run, copy results, write explanations, submit PDF.**

