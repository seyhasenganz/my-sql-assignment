# ASSIGNMENT VALIDATION PLAN - Using Real MySQL Data

## Overview
Validate all 5 questions using ACTUAL data from your pricing_daily table, not estimates.

---

## STEP-BY-STEP PLAN

### Phase 1: Verify Data Quality
- [ ] Check pricing_daily table row count and date range
- [ ] Verify date format is correct (2024-2026, not 2001-2031)
- [ ] Confirm we have all 5 tickers with Adj Close prices
- [ ] Check data density (rows per date)

### Phase 2: Execute Q1 - Returns Analysis
- [ ] Query actual current prices for each ticker
- [ ] Query actual prices 252 days ago (12M)
- [ ] Query actual prices 378 days ago (18M)
- [ ] Query actual prices 504 days ago (24M)
- [ ] Calculate REAL returns for each security
- [ ] Calculate REAL portfolio return (weighted)
- [ ] RESULT: Fill table with actual numbers

### Phase 3: Execute Q2 - Variance/Correlation
- [ ] Calculate daily returns for each ticker (6-month window)
- [ ] Calculate variance for each security
- [ ] Calculate standard deviation
- [ ] Compare variance across holdings
- [ ] RESULT: Verify variance rankings (GLD > IXN > QQQ > VNQ > IEF)

### Phase 4: Execute Q3 - Volatility/Sigma
- [ ] Calculate daily returns (12-month window)
- [ ] Calculate daily volatility (STDDEV)
- [ ] Annualize volatility (multiply by √252)
- [ ] Calculate portfolio weighted volatility
- [ ] RESULT: Get actual sigma values for each security

### Phase 5: Execute Q4 & Q5 - Recommendations
- [ ] Use ACTUAL Q1-Q3 results
- [ ] Apply Sharpe ratio framework
- [ ] Make buy/sell recommendations based on REAL data
- [ ] Propose rebalancing (if supported by REAL data)
- [ ] RESULT: Final client recommendations

### Phase 6: Create Professional Report
- [ ] Screenshot MySQL Workbench with results
- [ ] Document all SQL queries used
- [ ] Show actual numbers in all tables
- [ ] Provide detailed explanations
- [ ] Explain how real results match/differ from expectations

---

## Expected Outputs

1. **Real Data Verification Report** - Confirm data quality
2. **Q1 Results** - Actual individual security returns
3. **Q2 Results** - Actual variance values
4. **Q3 Results** - Actual sigma/volatility values
5. **Q4 Results** - Based on real calculations
6. **Q5 Results** - Rebalancing impact with real numbers
7. **MySQL Screenshots** - Showing actual query execution
8. **PDF Report** - All findings with real data

---

## Success Criteria

✅ All numbers come from actual SQL queries (not estimates)
✅ Date range is correct (2024-2026, not 2001-2031)
✅ All 5 questions answered with REAL data
✅ Results documented with SQL code shown
✅ Professional recommendations based on actual metrics

---

## Let's Begin!

Starting with Phase 1: Verify Data Quality...
