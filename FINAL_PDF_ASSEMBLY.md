# HOW TO BUILD YOUR PDF - Final Assembly Guide

## Files You Now Have

1. **questions_with_real_data.sql** - The 5 SQL queries to run
2. **DETAILED_EXPLANATIONS.md** - Complete written content for your PDF
3. **USING_YOUR_DATA.md** - Quick reference with sample results
4. **This file** - Assembly instructions

---

## Step-by-Step PDF Creation

### PART 1: Run Queries & Get Screenshots (30 minutes)

1. Open MySQL Workbench
2. For each query in `questions_with_real_data.sql`:
   - Copy the query
   - Paste into MySQL Workbench
   - Run the query
   - **Take a screenshot** of the results
   - Save screenshot with clear name (Q1_Returns.png, Q2_Variance.png, etc.)

3. You now have 5 screenshots of your actual data

---

### PART 2: Create PDF Document (2-3 hours)

Use Microsoft Word, Google Docs, or any PDF creator. Here's the structure:

#### PAGE 1: TITLE PAGE
```
UHNW Portfolio Analysis & Recommendations

For: Palo Alto Ultra High Net Worth Client
Portfolio Value: $95,000,000

Prepared by: [Your Name]
Date: [Today's Date]
Course: [Your Course Name/Section]
```

#### PAGES 2-3: DATABASE SETUP (Step 2 from assignment)

**Screenshots to include:**
- Screenshot of pricing_daily_new table structure
- Screenshot of sample data (first 10-20 rows showing all 5 tickers)
- Text: "Your data table pricing_daily_new contains [X] rows of pricing data spanning from [date] to [date], covering all 5 securities (IXN, QQQ, IEF, VNQ, GLD)"

---

#### PAGES 4-7: QUESTION 1 - RETURNS ANALYSIS (20 Points)

**Copy-paste from DETAILED_EXPLANATIONS.md:**
- "### What This Question Asks" section
- "### SQL Logic Explained" section
- "### Expected Results & Interpretation" section
- "### Detailed Explanation for Your Client" section

**Add:**
- Screenshot of your Q1 query results
- "### What This Tells You About Your Portfolio" section
- "### Recommendation After Question 1" section

**Word count: 800-1000 words expected**

---

#### PAGES 8-11: QUESTION 2 - CORRELATIONS & VARIANCE (20 Points)

**Copy-paste from DETAILED_EXPLANATIONS.md:**
- "### What This Question Asks" section
- "### SQL Logic Explained" section
- "### Expected Results & Interpretation" section
- "### Detailed Explanation for Your Client" section
- "### The Correlation Story" section
- "### Interesting Findings" section

**Add:**
- Screenshot of your Q2 variance query results
- "### Recommendation After Question 2" section

**Word count: 1000-1200 words expected**

---

#### PAGES 12-16: QUESTION 3 - VOLATILITY/SIGMA (20 Points)

**Copy-paste from DETAILED_EXPLANATIONS.md:**
- "### What This Question Asks" section
- "### SQL Logic Explained" section
- "### Expected Results & Interpretation" section
- "### Detailed Explanation for Your Client" section
- "### Value at Risk (VaR) Analysis" section
- "### Risk Trend Analysis: 12M vs 6M" section
- "### Risk Classification" section

**Add:**
- Screenshot of your Q3 volatility query results
- "### Recommendation After Question 3" section

**Word count: 1200-1400 words expected**

---

#### PAGES 17-28: QUESTION 4 - SHARPE RATIO & REBALANCING (20 Points) **MOST IMPORTANT**

**Copy-paste from DETAILED_EXPLANATIONS.md:**
- "### What This Question Asks" section
- "### SQL Logic Explained" section
- "### Expected Results & Interpretation" section
- "### Detailed Explanation for Your Client" section (explains all 5 securities)
- All 5 RECOMMENDATIONS sections (these are critical):
  * RECOMMENDATION 1: REDUCE IXN by $2.4M
  * RECOMMENDATION 2: REDUCE QQQ by $2.0M
  * RECOMMENDATION 3: INCREASE IEF by $1.4M
  * RECOMMENDATION 4: INCREASE VNQ by $2.9M (KEY)
  * RECOMMENDATION 5: ADD SCHD $2.5M
- "### Summary of Recommendations" section

**Add:**
- Screenshot of your Q4 Sharpe ratio query results
- Create a simple table showing:
  ```
  | Ticker | Current % | Proposed % | Action | Amount |
  | IXN    | 17.5%     | 15.0%      | REDUCE | $2.4M  |
  | QQQ    | 22.1%     | 20.0%      | REDUCE | $2.0M  |
  | IEF    | 28.5%     | 30.0%      | BUY    | $1.4M  |
  | VNQ    | 8.9%      | 12.0%      | BUY    | $2.9M  |
  | GLD    | 23.0%     | 23.0%      | HOLD   | —      |
  | SCHD   | —         | 2.6%       | ADD    | $2.5M  |
  ```

**Word count: 2000-2500 words expected (THIS IS YOUR MOST IMPORTANT SECTION)**

---

#### PAGES 29-36: QUESTION 5 - POST-REBALANCING IMPACT (20 Points)

**Copy-paste from DETAILED_EXPLANATIONS.md:**
- "### What This Question Asks" section
- "### Current vs Proposed Comparison" section (with tables)
- "### Detailed Explanation for Your Client" section
- "### Impact Analysis in Different Market Scenarios" section
  * Scenario 1: Bull Market
  * Scenario 2: Market Correction
  * Scenario 3: Crisis
  * Scenario 4: Stagflation
- "### Summary of Scenario Analysis" table
- "### Expected Returns Change" section
- "### Portfolio Risk Change" section
- "### Implementation Timeline" section
- "### Rebalancing Benefits Summary" section
- "### Risks & Considerations" section
- "### Conclusion for Your Client" section

**Add:**
- Screenshot of your Q5 before/after comparison query results
- Create visual before/after comparison:
  ```
  BEFORE          AFTER
  Return: 11.59%  Return: 10.8%    (-0.79%)
  Risk:   15.2%   Risk:   14.1%    (-1.1%) ✓
  Sharpe: 0.62    Sharpe: 0.65    (+0.03) ✓
  ```

**Word count: 2000-2500 words expected**

---

#### FINAL PAGES: APPENDICES & CONCLUSION

**Optional but recommended:**
- Copy of all 5 SQL queries in appendix
- Investment methodology references
- Glossary of terms (Sharpe Ratio, Volatility, Correlation, etc.)

**1-page Conclusion:**
- Summary of all recommendations
- Timeline for implementation
- Next steps for the client

---

## Total PDF Structure

| Section | Pages | Content |
|---------|-------|---------|
| Title Page | 1 | Title, date, course info |
| Database Setup | 2-3 | Schema screenshots, data verification |
| Q1: Returns | 4-7 | SQL, results, explanation, recommendations |
| Q2: Correlation | 8-11 | SQL, results, variance analysis, insights |
| Q3: Volatility | 12-16 | SQL, results, risk analysis, classifications |
| **Q4: Sharpe** | **17-28** | **SQL, results, 5 specific recommendations** |
| **Q5: Impact** | **29-36** | **4 scenarios, before/after, implementation plan** |
| Appendices | 37-40+ | SQL code, glossary, references |
| **TOTAL** | **~40 pages** | **Professional investment proposal** |

---

## Key Content to Include in Your PDF

### Q1 Content Checklist
- [ ] SQL code displayed
- [ ] Results screenshot
- [ ] 12M, 18M, 24M returns for each security
- [ ] Portfolio-weighted return calculation
- [ ] Explanation in simple language
- [ ] Comparison to market benchmarks

### Q2 Content Checklist
- [ ] SQL code displayed
- [ ] Variance results screenshot
- [ ] High/low variance discussion
- [ ] Correlation risk identified (IXN+QQQ)
- [ ] Diversification benefits explained
- [ ] 3+ interesting findings noted
- [ ] Recommendation for VNQ increase

### Q3 Content Checklist
- [ ] SQL code displayed
- [ ] Volatility results screenshot
- [ ] 12M vs 6M comparison
- [ ] Risk classification for each security
- [ ] Portfolio volatility calculation
- [ ] VaR analysis
- [ ] Volatility trend discussion
- [ ] Plain-language risk explanation

### Q4 Content Checklist (CRITICAL for 20 points)
- [ ] SQL code displayed
- [ ] Sharpe ratio results screenshot
- [ ] All 5 securities ranked by Sharpe
- [ ] **5 SPECIFIC RECOMMENDATIONS** with:
  - [ ] Exact dollar amounts ($2.4M, $2.0M, etc.)
  - [ ] Detailed rationale for each
  - [ ] Why/why not for each action
  - [ ] Implementation method
  - [ ] Timeline
  - [ ] Tax considerations
- [ ] Concentration risk discussed
- [ ] New security (SCHD) proposal with reasoning
- [ ] Summary rebalancing table

### Q5 Content Checklist (CRITICAL for 20 points)
- [ ] SQL code displayed
- [ ] Before/after comparison table
- [ ] **4 market scenario analysis**:
  - [ ] Bull market details
  - [ ] Correction details with dollar impact
  - [ ] Crisis scenario with savings calculated
  - [ ] Stagflation scenario
- [ ] Expected return change explained
- [ ] Portfolio risk change explained
- [ ] Week-by-week implementation timeline
- [ ] Cost-benefit analysis
- [ ] Risk mitigation discussion
- [ ] Final recommendation

---

## How to Get Your Actual Results

### Run Each Query
```sql
-- Open MySQL Workbench
-- Connect to invest_portfolio database
-- Copy Query 1 from questions_with_real_data.sql
-- Run it
-- Screenshot the results
-- Repeat for Q2, Q3, Q4, Q5
```

### What You'll Actually See
Your queries will show **real numbers** from your `pricing_daily_new` table. These real numbers are what you put in your PDF, not the "sample" numbers I provided.

For example, if your actual Q1 query shows:
- IXN returned 18.5% (not 15.2%)
- QQQ returned 25.1% (not 22.5%)
- Your portfolio returned 13.2% (not 11.59%)

**Use your actual numbers!** That's the whole point of the assignment.

---

## Writing Tips for Full Marks

✓ **Use actual data**: Don't make up numbers
✓ **Explain simply**: Avoid unnecessary jargon
✓ **Show your work**: Include SQL code and results
✓ **Be specific**: "$2.4M" not "some amount"
✓ **Reference data**: "From our analysis, IXN returned 18.5%..."
✓ **Support recommendations**: "Because Sharpe ratio is..."
✓ **Consider risks**: "This assumes..."
✓ **Professional tone**: This is a $95M portfolio proposal
✓ **Professional formatting**: Consistent fonts, margins, headers
✓ **Clear tables**: Easy-to-read comparison tables

---

## Scoring Quick Reference

| Question | Points | Keys to Get Full 20 |
|----------|--------|-------------------|
| Q1 Returns | 20 | Show 12M/18M/24M data. Explain each security. Portfolio calculation. |
| Q2 Correlation | 20 | Variance analysis. IXN-QQQ concentration identified. 3+ interesting findings. |
| Q3 Volatility | 20 | 12M and 6M sigma. Risk classification. VaR analysis. Simple explanation. |
| Q4 Sharpe | 20 | **5 specific recommendations with $ amounts. Detailed rationale. New security proposal.** |
| Q5 Impact | 20 | **4 market scenarios analyzed. Before/after comparison. Implementation timeline.** |
| **TOTAL** | **100** | **Professional proposal with actual data and detailed recommendations.** |

---

## Final Checklist Before Submitting

- [ ] All 5 SQL queries executed with screenshots
- [ ] Title page complete
- [ ] Database setup documented with screenshots
- [ ] Q1: Returns fully explained with actual results
- [ ] Q2: Correlations analyzed with interesting findings
- [ ] Q3: Volatility analyzed with risk classifications
- [ ] Q4: Sharpe ratios shown with 5 specific recommendations
- [ ] Q5: 4 market scenarios analyzed with implementation plan
- [ ] All SQL code included (either inline or in appendix)
- [ ] All screenshots embedded and labeled
- [ ] Professional formatting throughout
- [ ] No spelling or grammar errors
- [ ] Professional tone (suitable for client presentation)
- [ ] ~40 pages total
- [ ] Saved as PDF with clear filename
- [ ] Backup copy created

---

## You're Ready!

You now have:
✓ SQL queries for your data
✓ Detailed explanations for all 5 questions
✓ Specific recommendations ($2.4M, $2.0M, etc.)
✓ Market scenario analysis
✓ Implementation timeline
✓ Professional content ready to paste into PDF

**Just run the queries, take screenshots, paste the content, and you'll have a professional 100-point assignment!**

Good luck! You've got this! 🎯
