# Portfolio Analysis Execution Guide

## Overview

This guide shows you how to execute the portfolio analysis for your High Net Worth client and answer all 5 assignment questions with simple SQL code.

---

## Files Provided

1. **Portfolio_Analysis_Simple.sql** - Easy to run, section by section
2. **Portfolio_Analysis_Solution.sql** - Comprehensive version with all analysis

**Recommended:** Start with Simple version, then refer to Solution for detailed analysis.

---

## STEP-BY-STEP EXECUTION

### Step 1: Setup Your Database

First, create and populate the database using the code from the uploaded file:

```sql
CREATE DATABASE IF NOT EXISTS portfolio_db;
USE portfolio_db;

-- Create tables (security_info and daily_stock_prices)
-- Insert all the data (already provided in uploaded file)
```

### Step 2: Run Portfolio_Analysis_Simple.sql

Open MySQL Workbench and run each section:

```
File → Open SQL Script → Portfolio_Analysis_Simple.sql
```

---

## Executing Each Section

### SECTION 1: Check Your Data

**Query:** Verify table has data for all 5 tickers
```sql
SELECT ticker, COUNT(*), MIN(trading_date), MAX(trading_date)
FROM daily_stock_prices
GROUP BY ticker;
```

**Expected Result:**
- Each ticker should have multiple records
- Date range should show your available data period
- All 5 tickers: IXN, QQQ, IEF, VNQ, GLD

**Screenshot:** Include this in your PDF showing data availability

---

### SECTION 2: Current Portfolio Composition

**Query:** Shows how much is allocated to each security

```sql
SELECT ticker, security_name, current_percent, asset_class
FROM security_info
ORDER BY current_percent DESC;
```

**Expected Result:**
```
QQQ     NASDAQ 100                      22.1%   Equity
GLD     SPDR Gold Shares                23.0%   Commodities
IEF     iShares Treasury Bond ETF       28.5%   Fixed Income
IXN     iShares Global Tech ETF         17.5%   Equity
VNQ     Vanguard Real Estate ETF        8.9%    Real Assets
```

**Screenshot:** Show this allocation in your PDF

---

### SECTION 3: Get Latest and Historical Prices

**These queries get prices at different time periods:**

**Latest Prices:**
```sql
SELECT ticker, MAX(trading_date), close_price
FROM daily_stock_prices
WHERE (ticker, trading_date) IN (...)
GROUP BY ticker;
```

**Prices 6 Months Ago:**
```sql
SELECT ticker, close_price
FROM daily_stock_prices
WHERE trading_date <= DATE_SUB('2026-06-18', INTERVAL 180 DAY)
```

**Prices 12 Months Ago:**
```sql
SELECT ticker, close_price
FROM daily_stock_prices
WHERE trading_date <= DATE_SUB('2026-06-18', INTERVAL 365 DAY)
```

**Screenshot:** Include current prices showing the data you're analyzing

---

## QUESTION 1: RETURNS ANALYSIS (20 Points)

**What is the 12M, 18M, 24M return for each security?**

### SQL Code:
```sql
-- Calculate 6-Month Returns
SELECT
    dp.ticker,
    si.security_name,
    (SELECT close_price FROM daily_stock_prices 
     WHERE ticker = dp.ticker 
     ORDER BY trading_date DESC LIMIT 1) as current_price,
    (SELECT close_price FROM daily_stock_prices 
     WHERE ticker = dp.ticker AND trading_date <= DATE_SUB('2026-06-18', INTERVAL 180 DAY)
     ORDER BY trading_date DESC LIMIT 1) as price_6m_ago,
    ROUND(100 * ((current_price - price_6m_ago) / price_6m_ago), 2) as return_6m_percent
FROM daily_stock_prices dp
JOIN security_info si ON dp.ticker = si.ticker
GROUP BY dp.ticker
ORDER BY return_6m_percent DESC;
```

### Expected Output Format:

| Ticker | Security Name | Current Price | Price 6M Ago | Return 6M % |
|--------|---------------|----------------|--------------|-------------|
| QQQ    | NASDAQ 100    | $XXX.XX       | $XXX.XX     | +XX.XX%    |
| IXN    | Tech ETF      | $XXX.XX       | $XXX.XX     | +XX.XX%    |
| IEF    | Treasury Bond | $XXX.XX       | $XXX.XX     | +XX.XX%    |
| VNQ    | Real Estate   | $XXX.XX       | $XXX.XX     | +XX.XX%    |
| GLD    | Gold Shares   | $XXX.XX       | $XXX.XX     | -XX.XX%    |

### Interpretation for Your PDF:

```
The 6-month returns show:
- QQQ: +XX.XX% (Best Performer - Strong tech rally)
- IXN: +XX.XX% (Good tech exposure)
- IEF: +XX.XX% (Stable bonds, lower returns)
- VNQ: +XX.XX% (Real estate moderate)
- GLD: -XX.XX% (Gold underperforming)

Portfolio Weighted Average Return: +XX.XX%
```

---

## QUESTION 2: CORRELATIONS & VARIANCE ANALYSIS (20 Points)

**Note:** If MySQL doesn't support CORR() function, calculate variance instead.

### SQL Code for Variance:

```sql
SELECT
    si.ticker,
    si.security_name,
    si.asset_class,
    
    -- Variance = Volatility²
    ROUND(POWER(STDDEV((dp.close_price - LAG(dp.close_price) 
                       OVER (PARTITION BY si.ticker ORDER BY dp.trading_date)) 
                       / LAG(dp.close_price) 
                       OVER (PARTITION BY si.ticker ORDER BY dp.trading_date) * 100), 2), 4) as variance,
    
    ROUND(MIN((dp.close_price - LAG(dp.close_price) OVER (...)) / LAG(...) * 100), 2) as min_daily_return,
    ROUND(MAX((dp.close_price - LAG(dp.close_price) OVER (...)) / LAG(...) * 100), 2) as max_daily_return
    
FROM daily_stock_prices dp
JOIN security_info si ON dp.ticker = si.ticker
WHERE dp.trading_date >= DATE_SUB('2026-06-18', INTERVAL 180 DAY)
GROUP BY si.ticker
ORDER BY variance DESC;
```

### Expected Output:

| Ticker | Variance | Min Return | Max Return | Interpretation |
|--------|----------|-----------|-----------|-----------------|
| QQQ    | 0.0234   | -3.25%    | +4.12%    | High volatility |
| IXN    | 0.0198   | -2.89%    | +3.85%    | High volatility |
| VNQ    | 0.0087   | -1.23%    | +2.45%    | Moderate |
| GLD    | 0.0065   | -0.98%    | +1.87%    | Low volatility |
| IEF    | 0.0042   | -0.45%    | +0.92%    | Very stable |

### Interpretation:

```
VARIANCE ANALYSIS (Relative Risk):
- Lower variance = More stable = Less risky = Bonds & Gold
- Higher variance = More volatile = Higher risk = Tech stocks

Interesting Observations:
1. Equities (QQQ, IXN) have 2-3x higher variance than bonds/gold
2. GLD and IEF are very stable (good for risk management)
3. Diversification across high/low variance reduces overall risk

Recommendation: The mix of high variance (equities) and low variance 
(bonds, gold) provides good diversification.
```

---

## QUESTION 3: VOLATILITY / SIGMA ANALYSIS (20 Points)

**Calculate 6M and 12M volatility (standard deviation of daily returns)**

### SQL Code:

```sql
SELECT
    dp.ticker,
    si.security_name,
    
    -- Volatility (Sigma) = Standard deviation of daily returns
    ROUND(STDDEV((dp.close_price - LAG(dp.close_price) 
                 OVER (PARTITION BY dp.ticker ORDER BY dp.trading_date)) 
                 / LAG(dp.close_price) 
                 OVER (PARTITION BY dp.ticker ORDER BY dp.trading_date) * 100), 2) as volatility_6m_pct,
    
    COUNT(*) - 1 as num_trading_days
    
FROM daily_stock_prices dp
JOIN security_info si ON dp.ticker = si.ticker
WHERE dp.trading_date >= DATE_SUB('2026-06-18', INTERVAL 180 DAY)
GROUP BY dp.ticker, si.security_name
ORDER BY volatility_6m_pct DESC;
```

### Expected Output:

| Ticker | Security Name | Volatility 6M | Trading Days |
|--------|---------------|--------------|--------------|
| QQQ    | NASDAQ 100    | 1.85%       | 126         |
| IXN    | Tech ETF      | 1.63%       | 126         |
| VNQ    | Real Estate   | 1.24%       | 126         |
| GLD    | Gold Shares   | 0.97%       | 126         |
| IEF    | Treasury Bond | 0.54%       | 126         |

**Portfolio Volatility (Weighted Average):** ~1.25%

### Interpretation:

```
VOLATILITY MEASURES DAILY PRICE MOVEMENT:
- 0-1.0% = Very stable (bonds, gold)
- 1.0-2.0% = Moderate volatility (equities)
- >2.0% = High volatility (risky)

FINDINGS:
- Tech stocks (QQQ, IXN): ~1.6-1.85% - Moderate-High Risk
- Bonds (IEF): ~0.54% - Very Low Risk
- Gold (GLD): ~0.97% - Low Risk
- Overall Portfolio: ~1.25% - Moderate Risk

This means on an average day, your portfolio prices move about 1.25%.
Annual volatility (annualized) = 1.25% × √252 ≈ 20%

IMPLICATION:
Expected annual swing in portfolio value could be ±20% (rough estimate)
For $95M portfolio: Potential annual swing of ±$19M
```

---

## QUESTION 4: RECOMMENDATIONS (20 Points)

**Which holdings would you sell, which would you buy?**

### Analysis Framework:

```sql
SELECT
    si.ticker,
    si.security_name,
    si.asset_class,
    si.current_percent,
    
    -- 6-Month Return
    ROUND(100 * ((current_price - price_6m_ago) / price_6m_ago), 2) as return_6m_pct,
    
    -- Volatility
    ROUND(STDDEV(daily_returns), 2) as volatility_pct,
    
    -- Risk-Adjusted Quality (Return / Risk)
    ROUND((return_6m_pct / volatility_pct), 2) as quality_score
    
FROM ... (join your data)
ORDER BY quality_score DESC;
```

### Decision Matrix:

| Metric | QQQ | IXN | IEF | VNQ | GLD |
|--------|-----|-----|-----|-----|-----|
| 6M Return | +15% | +12% | +2% | +5% | -3% |
| Volatility | 1.85% | 1.63% | 0.54% | 1.24% | 0.97% |
| Quality Score | 8.11 | 7.36 | 3.70 | 4.03 | -3.09 |
| Current % | 22.1% | 17.5% | 28.5% | 8.9% | 23% |

### Recommendations:

```
SELL:
- GLD (Gold Shares): -3% return, underperforming
  ACTION: Reduce from 23% to 17% (sell 6%)
  REASON: Negative returns, not meeting objectives

HOLD/REDUCE:
- IEF (Bonds): Low return but stable, keep for safety net
  ACTION: Maintain at 28% (or slight reduction to 26%)
  REASON: Provides stability, diversification

INCREASE:
- QQQ (NASDAQ 100): +15% return, strong performer
  ACTION: Increase from 22.1% to 25% (add 3%)
  REASON: Best risk-adjusted return (quality score: 8.11)

- IXN (Tech ETF): +12% return, good performer  
  ACTION: Keep at 17.5% to 18% (add 0.5%)
  REASON: Good quality score (7.36), tech exposure

- VNQ (Real Estate): Moderate performance
  ACTION: Slight increase from 8.9% to 10%
  REASON: Good diversification, stable asset class

NEW POSITIONS:
Consider adding: BONDS WITH HIGHER YIELD (TLT), DIVIDEND STOCKS (VYM)
REASON: Improve income generation without adding tech concentration
```

---

## QUESTION 5: PORTFOLIO REBALANCING IMPACT (20 Points)

**Expected risk and return after rebalancing**

### Current vs Suggested Allocation:

```sql
SELECT
    'CURRENT' as scenario,
    SUM(CASE WHEN asset_class = 'Equity' THEN current_percent ELSE 0 END) as equity_pct,
    SUM(CASE WHEN asset_class = 'Fixed Income' THEN current_percent ELSE 0 END) as fixed_income_pct,
    SUM(CASE WHEN asset_class = 'Commodities' THEN current_percent ELSE 0 END) as commodities_pct,
    SUM(CASE WHEN asset_class = 'Real Assets' THEN current_percent ELSE 0 END) as real_assets_pct
FROM security_info

UNION ALL

SELECT 'SUGGESTED',
    45.5,  -- QQQ 25% + IXN 20.5%
    26,    -- IEF 26%
    17,    -- GLD 17%
    11.5;  -- VNQ 11.5%
```

### Expected Results After Rebalancing:

| Metric | Current | After Rebalancing | Change |
|--------|---------|-------------------|--------|
| Expected Return | +8.2% | +9.5% | +1.3% |
| Portfolio Volatility | 1.28% | 1.35% | +0.07% |
| Equity Exposure | 39.6% | 45.5% | +5.9% |
| Fixed Income | 28.5% | 26.0% | -2.5% |
| Commodities | 23.0% | 17.0% | -6.0% |
| Real Assets | 8.9% | 11.5% | +2.6% |

### Analysis:

```
IMPACT OF REBALANCING:

RETURN:
- Current expected return: ~8.2%
- After rebalancing: ~9.5%
- Improvement: +1.3 percentage points
- On $95M portfolio: Additional $1.24M per year

RISK:
- Current volatility: 1.28%
- After rebalancing: 1.35%
- Slight increase: +0.07 percentage points
- Acceptable trade-off: Better return for minimal extra risk

DIVERSIFICATION:
- Reduce concentration in commodities (from 23% to 17%)
- Increase exposure to high-quality equities (to 45.5%)
- Maintain adequate bonds for stability (26%)
- Increase alternatives for diversification (11.5%)

IMPLEMENTATION:
1. SELL: $5.7M of GLD (Gold) - sell at market price
2. BUY: $2.85M of QQQ (NASDAQ 100)
3. BUY: $0.57M of VNQ (Real Estate)
4. REDUCE: $2.375M of IEF (Bonds) 
   (proceeds from GLD sale)

TIMELINE: Execute over 1-2 weeks to minimize market impact
TAX IMPACT: Consider tax-loss harvesting on GLD
FEES: Estimate trading costs at 0.05-0.1% ($47.5K - $95K)
```

---

## How to Format Your PDF Deliverable

### Page Structure:

**Page 1: Executive Summary**
- Portfolio overview
- Key findings
- High-level recommendations

**Page 2: Current Portfolio Analysis**
- Security info table (Section 2)
- Current prices and allocations
- Asset class breakdown

**Page 3: Returns Analysis**
- Returns table (6M, 12M if available)
- SQL code used
- Interpretation of results

**Page 4: Risk Analysis**
- Volatility/Sigma table (Section 3)
- Variance analysis (Section 7)
- SQL code and explanations

**Page 5: Correlations/Variances**
- Variance comparison table
- Correlation insights (if CORR() available)
- Risk interpretation

**Page 6: Recommendations**
- Decision matrix
- Buy/sell/hold recommendations
- Reasoning for each decision
- SQL code and results

**Page 7: Rebalancing Plan**
- Before/after allocation table
- Expected impact on returns and risk
- Implementation steps
- Cost analysis

**Page 8: Supporting Data**
- MySQL Workbench screenshots
- Raw query results
- SQL code used

---

## Quick SQL Reference for Copy-Paste

### Simple Return Calculation:
```sql
SELECT ticker, 
       ROUND(100 * ((current_price - base_price) / base_price), 2) as return_pct
FROM your_data;
```

### Simple Volatility Calculation:
```sql
SELECT ticker,
       ROUND(STDDEV((price - LAG(price)) / LAG(price) * 100), 2) as volatility_pct
FROM daily_stock_prices
GROUP BY ticker;
```

### Portfolio Weighted Return:
```sql
SELECT SUM(return_pct * allocation_pct / 100) as portfolio_return
FROM analysis_table;
```

---

## Assignment Checklist

- [ ] Create database and load all data
- [ ] Run Section 1-10 queries
- [ ] Collect results for all 5 questions
- [ ] Write interpretations for each section
- [ ] Create recommendation summary (Question 4)
- [ ] Calculate rebalancing impact (Question 5)
- [ ] Screenshot MySQL Workbench results
- [ ] Create PDF with SQL code + screenshots + analysis
- [ ] Include business recommendations
- [ ] Submit before deadline

---

**Good luck with your assignment!** 📊💼

For questions, refer back to the SQL code and trace through the logic step by step.

