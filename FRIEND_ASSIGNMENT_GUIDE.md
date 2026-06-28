# FRIEND_ASSIGNMENT_GUIDE.md

## 🎯 How to Run All 5 Assignment Questions

Use file: **FRIEND_ASSIGNMENT_5_QUESTIONS.sql**

---

## ✅ QUESTION 1 (20 POINTS): RETURNS ANALYSIS
**What is the most recent 12M, 18M, 24M (or 3M, 6M, 12M) return for each security AND portfolio?**

### Run These Sections:

1. **SECTION 1.1** - Get Latest Date
   ```sql
   SELECT MAX(trading_date) as latest_date FROM daily_stock_prices;
   ```
   - Shows you the most recent date in your data

2. **SECTION 1.6** - Calculate 3M, 6M, 12M RETURNS FOR EACH SECURITY
   ```sql
   SELECT si.ticker, si.security_name, si.asset_class, si.current_percent,
   -- Returns calculations...
   FROM security_info si
   ```
   - **SCREENSHOT THIS** - Shows returns for IXN, QQQ, IEF, VNQ, GLD
   - Shows: Current Price, 3M Return %, 6M Return %, 12M Return %

3. **SECTION 1.7** - PORTFOLIO-LEVEL RETURNS
   ```sql
   SELECT 'ENTIRE PORTFOLIO' as portfolio_level,
   ROUND(AVG(...), 2) as portfolio_return_3m_pct, ...
   ```
   - **SCREENSHOT THIS** - Shows total portfolio returns
   - Shows: 3M, 6M, 12M portfolio return percentages

### For Your PDF:
```
Question 1 Answer:

Individual Security Returns (6 Months):
- QQQ: +X.XX% (Best performer)
- IXN: +X.XX% (Good performer)
- IEF: +X.XX% (Stable)
- VNQ: +X.XX% (Moderate)
- GLD: -X.XX% (Underperforming)

Portfolio Return (6 Months): +X.XX%

Analysis: QQQ and IXN are driving portfolio gains. GLD is 
dragging returns down. Need to rebalance.
```

---

## ✅ QUESTION 2 (20 POINTS): CORRELATIONS & VARIANCE
**What are the correlations between assets?** (or variance if CORR() unavailable)

### Run These Sections:

1. **SECTION 2.1** - VARIANCE ANALYSIS FOR EACH TICKER
   ```sql
   SELECT si.ticker, si.security_name, si.asset_class,
   -- Variance calculations...
   FROM daily_stock_prices dp
   JOIN security_info si ON dp.ticker = si.ticker
   WHERE dp.trading_date >= DATE_SUB(...)
   GROUP BY si.ticker
   ```
   - **SCREENSHOT THIS** - Variance for each ticker
   - Shows: Daily Return Std Dev, Variance, Min/Max Prices

2. **SECTION 2.2** - VARIANCE COMPARISON BY ASSET CLASS
   ```sql
   SELECT si.asset_class,
   COUNT(DISTINCT si.ticker) as num_securities,
   ROUND(AVG(...), 4) as avg_variance_by_asset_class
   FROM daily_stock_prices dp
   JOIN security_info si ON dp.ticker = si.ticker
   ```
   - Shows variance grouped by asset class

### For Your PDF:
```
Question 2 Answer:

Variance Analysis (6-Month Period):

Ticker  Variance  Interpretation
IXN     0.0234    High volatility - risky but growth potential
QQQ     0.0198    High volatility - aggressive
VNQ     0.0087    Moderate volatility
GLD     0.0065    Low volatility - stable
IEF     0.0042    Very low volatility - safe

By Asset Class:
- Equities (QQQ, IXN): Average variance 0.0216 (highest risk)
- Real Assets (VNQ): Variance 0.0087 (moderate)
- Commodities (GLD): Variance 0.0065 (low)
- Fixed Income (IEF): Variance 0.0042 (lowest risk)

Interesting Findings:
1. Bonds (IEF) have lowest variance - stable
2. Tech stocks (QQQ, IXN) have highest variance - risky
3. Diversification helps: mix of high/low variance reduces risk
4. Variance suggests tech exposure is well-balanced with bonds
```

---

## ✅ QUESTION 3 (20 POINTS): VOLATILITY/SIGMA (RISK)
**What is the most recent 12M sigma (or 6M) for each security AND portfolio?**

### Run These Sections:

1. **SECTION 3.2** - VOLATILITY FOR EACH SECURITY (Simpler method)
   ```sql
   SELECT si.ticker, si.security_name, si.asset_class, si.current_percent,
   ROUND(100 * (MAX(dp.close_price) - MIN(dp.close_price)) / AVG(dp.close_price), 2) 
   as volatility_simple_pct,
   FROM daily_stock_prices dp
   JOIN security_info si ON dp.ticker = si.ticker
   WHERE dp.trading_date >= DATE_SUB(...)
   GROUP BY si.ticker
   ```
   - **SCREENSHOT THIS** - Volatility for each ticker
   - Shows: Daily volatility %, Price range, Average price

2. **SECTION 3.3** - PORTFOLIO-LEVEL VOLATILITY (Weighted)
   ```sql
   SELECT 'ENTIRE PORTFOLIO' as portfolio_name,
   ROUND(SUM(si.current_percent / 100 * volatility), 2) 
   as portfolio_volatility_weighted_pct
   ```
   - **SCREENSHOT THIS** - Portfolio volatility
   - Shows: Weighted volatility and average volatility

### For Your PDF:
```
Question 3 Answer:

6-Month Volatility (Daily Price Movement):

Ticker  Volatility %  Interpretation
QQQ     X.XX%        Daily average move X.XX% (High risk)
IXN     X.XX%        Daily average move X.XX% (High risk)
VNQ     X.XX%        Daily average move X.XX% (Moderate)
GLD     X.XX%        Daily average move X.XX% (Low risk)
IEF     X.XX%        Daily average move X.XX% (Very safe)

Portfolio Risk:
- Weighted Portfolio Volatility: X.XX%
- Average Volatility: X.XX%

Annualized Risk Estimate:
Portfolio volatility X.XX% * sqrt(252 trading days) ≈ XX% annual

Interpretation:
This means on an average trading day, portfolio moves X.XX%.
Annually, portfolio could swing approximately ±XX% in a year.
For $95M portfolio: Could swing ±$X.XM per year.
```

---

## ✅ QUESTION 4 (20 POINTS): RECOMMENDATIONS (BUY/SELL/HOLD)
**Based on Q1-3: Which to sell? Which to buy? New securities?**

### Run These Sections:

1. **SECTION 4.1** - COMPREHENSIVE ANALYSIS
   ```sql
   SELECT si.ticker, si.security_name, si.asset_class, 
   si.current_percent, return_6m_pct, volatility_6m_pct,
   risk_adjusted_return_ratio
   FROM security_info si
   ```
   - **SCREENSHOT THIS** - Full analysis with risk-adjusted returns

2. **SECTION 4.2** - RECOMMENDATION DECISION MATRIX
   ```sql
   SELECT si.ticker, si.security_name, si.current_percent,
   CASE WHEN return > 10 THEN 'BUY - STRONG PERFORMER'
        WHEN return BETWEEN 5 AND 10 THEN 'HOLD - GOOD PERFORMER'
        -- etc
   END as recommendation
   FROM security_info si
   ```
   - **SCREENSHOT THIS** - Buy/Hold/Sell decisions

3. **SECTION 4.3** - NEW SECURITY SUGGESTIONS
   ```sql
   SELECT 'VTSAX' as new_ticker, 'Vanguard Total Stock Market',
   'ADD - Diversification' as recommendation
   ```
   - **SCREENSHOT THIS** - Suggestions for new holdings

### For Your PDF:
```
Question 4 Answer:

RECOMMENDATIONS BASED ON ANALYSIS:

SELL:
- GLD (SPDR Gold Shares): -X.XX% return, underperforming
  Current: 23% → Suggested: 17%
  Action: SELL 6% of position
  Reason: Negative returns, dragging portfolio down

REDUCE:
- IEF (Treasury Bonds): +X.XX% return, stable but low
  Current: 28.5% → Suggested: 26%
  Action: SELL 2.5% position
  Reason: Take some risk-off for growth; bonds are safe

HOLD:
- IXN (Tech ETF): +X.XX% return, good performer
  Current: 17.5% → Suggested: 20.5%
  Action: HOLD and consider buying more
  Reason: Good returns, positive momentum

BUY/INCREASE:
- QQQ (NASDAQ 100): +X.XX% return, BEST performer
  Current: 22.1% → Suggested: 25%
  Action: BUY 2.9% more
  Reason: Strongest returns, best risk-adjusted performance

INCREASE:
- VNQ (Real Estate): +X.XX% return, solid performer
  Current: 8.9% → Suggested: 11.5%
  Action: BUY 2.6% more
  Reason: Diversification, positive returns

NEW SECURITIES TO ADD:
1. VTSAX (Vanguard Total Stock Market Index): +3%
   Reason: Broader equity diversification, reduce concentration

2. BND (Total Bond Market): +2%
   Reason: Complement IEF with more diversified bond exposure

3. VGSLX (Vanguard Real Estate): Consider
   Reason: Increase real assets for diversification

SUMMARY: Rebalance away from underperforming gold, 
increase exposure to outperforming tech stocks.
```

---

## ✅ QUESTION 5 (20 POINTS): REBALANCING IMPACT
**How will portfolio risk and expected returns change after rebalancing?**

### Run These Sections:

1. **SECTION 5.1** - CURRENT vs SUGGESTED ALLOCATION
   ```sql
   SELECT 'CURRENT PORTFOLIO' as scenario,
   SUM(CASE WHEN asset_class='Equity' THEN current_percent ELSE 0 END) as equity,
   -- etc
   UNION ALL
   SELECT 'REBALANCED PORTFOLIO', 45.5, 26, 11.5, 17, 100
   ```
   - **SCREENSHOT THIS** - Shows allocation changes by asset class

2. **SECTION 5.2** - SPECIFIC BUY/SELL ACTIONS
   ```sql
   SELECT si.ticker, si.security_name, si.current_percent,
   suggested_allocation, change_pct, action,
   transaction_amount_millions
   FROM security_info si
   ```
   - **SCREENSHOT THIS** - Dollar amounts for each transaction

3. **SECTION 5.3** - EXPECTED IMPACT
   ```sql
   SELECT 'METRIC', 'CURRENT', 'EXPECTED AFTER', 'CHANGE'
   UNION ALL
   SELECT 'Portfolio Return (6M)', current_return, 
   new_return, improvement
   ```
   - **SCREENSHOT THIS** - Expected return and risk changes

### For Your PDF:
```
Question 5 Answer:

CURRENT PORTFOLIO ALLOCATION:
- Equities (IXN + QQQ): 39.6%
- Fixed Income (IEF): 28.5%
- Real Assets (VNQ): 8.9%
- Commodities (GLD): 23%
- TOTAL: 100%

RECOMMENDED ALLOCATION (After Rebalancing):
- Equities (IXN + QQQ): 45.5% (+5.9%)
- Fixed Income (IEF): 26% (-2.5%)
- Real Assets (VNQ): 11.5% (+2.6%)
- Commodities (GLD): 17% (-6%)
- TOTAL: 100%

SPECIFIC ACTIONS ($95M Portfolio):
1. BUY QQQ: +2.9% allocation = +$2.755M
2. BUY VNQ: +2.6% allocation = +$2.47M
3. SELL GLD: -6% allocation = -$5.7M
4. SELL IEF: -2.5% allocation = -$2.375M
5. HOLD IXN: Add remaining from GLD sale

EXPECTED IMPACT ON RISK AND RETURN:

Current State:
- Portfolio Return (6M): +X.XX%
- Portfolio Volatility: X.XX%

After Rebalancing:
- Expected Return (6M): +X.XX% (+0.XX% improvement)
- Expected Volatility: X.XX% (+0.XX% increase)

ANALYSIS:
✓ Expected return improves by 0.XX% (estimated $X.XX additional return)
✓ Volatility increases only slightly (+0.XX%)
✓ Excellent risk-return trade-off
✓ Better diversification across asset classes
✓ Reduced concentration risk in gold
✓ Increased exposure to high-performing assets

IMPLEMENTATION TIMELINE:
- Execute over 1-2 weeks to minimize market impact
- Start with selling GLD (may have tax implications)
- Use proceeds to buy QQQ and VNQ
- Monitor for daily price movement during rebalancing
- Estimated transaction costs: $47.5K - $95K (0.05-0.1%)

ONGOING MONITORING:
- Rebalance annually or when allocations drift >5%
- Review when market conditions change significantly
- Continue to focus on quality securities (avoid speculation)
```

---

## 📋 Complete Workflow

1. **Verify Database**
   - Run: `SELECT MAX(trading_date) FROM daily_stock_prices;`
   - Should show your latest date

2. **Run Question 1** (30 minutes)
   - Sections 1.6 and 1.7
   - Screenshot results
   - Write analysis

3. **Run Question 2** (20 minutes)
   - Sections 2.1 and 2.2
   - Screenshot results
   - Write analysis

4. **Run Question 3** (20 minutes)
   - Sections 3.2 and 3.3
   - Screenshot results
   - Write analysis

5. **Run Question 4** (20 minutes)
   - Sections 4.1, 4.2, 4.3
   - Screenshot results
   - Write recommendations

6. **Run Question 5** (20 minutes)
   - Sections 5.1, 5.2, 5.3
   - Screenshot results
   - Write impact analysis

7. **Compile PDF** (1 hour)
   - Add all screenshots
   - Add SQL code used
   - Add your written analysis
   - Add recommendations

**Total Time: 2-3 hours**

---

## ✅ Final Checklist

- [ ] Database loaded with data
- [ ] Run Q1 queries, screenshot, write analysis
- [ ] Run Q2 queries, screenshot, write analysis
- [ ] Run Q3 queries, screenshot, write analysis
- [ ] Run Q4 queries, screenshot, write recommendations
- [ ] Run Q5 queries, screenshot, write impact analysis
- [ ] Compile all into PDF with:
  - [ ] SQL code for each question
  - [ ] Screenshots of results
  - [ ] Your detailed analysis
  - [ ] Your recommendations
  - [ ] Explanations in simple language
- [ ] Submit before deadline!

