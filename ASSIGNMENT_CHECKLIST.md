# UHNW Portfolio Analysis Assignment - Completion Checklist

## Pre-Project Setup
- [ ] Review the assignment requirements
- [ ] Read README_GUIDE.md for overview
- [ ] Read ANALYSIS_RECOMMENDATIONS.md for framework understanding
- [ ] Download 3 years of daily pricing data for all 5 tickers
  - [ ] IXN - iShares Global Tech ETF
  - [ ] QQQ - Invesco QQQ Trust (NASDAQ 100)
  - [ ] IEF - iShares 7-10 Year Treasury ETF
  - [ ] VNQ - Vanguard Real Estate ETF
  - [ ] GLD - SPDR Gold Shares

## Step 1: Database Setup
- [ ] Open MySQL Workbench
- [ ] Create new database schema
- [ ] Execute 01_schema_setup.sql
  - [ ] Verify security_masterlist table created
  - [ ] Verify customer_details table created
  - [ ] Verify acct_dim table created
  - [ ] Verify holdings_dim table created (with sample data)
  - [ ] Verify pricing_daily table created (empty)

## Step 2: Data Loading
- [ ] Prepare CSV files with pricing data
  - [ ] Verify file format: Date, Open, High, Low, Close, Adj Close, Volume
  - [ ] Verify date range: 3 years minimum (24+ months)
  - [ ] Verify all 5 tickers have data
- [ ] Load data into pricing_daily table
  - [ ] Choose method: LOAD DATA INFILE, Workbench GUI, or INSERT
  - [ ] Load IXN data (~750 records)
  - [ ] Load QQQ data (~750 records)
  - [ ] Load IEF data (~750 records)
  - [ ] Load VNQ data (~750 records)
  - [ ] Load GLD data (~750 records)
- [ ] Verify data loaded successfully
  - [ ] Run verification queries from 07_data_load_template.sql
  - [ ] Check: SELECT COUNT(*) FROM pricing_daily GROUP BY ticker
  - [ ] Expected: ~750 records per ticker
  - [ ] Check for NULL values (should be none)
  - [ ] Check date ranges (should be ~3 years)

## Step 3: Screenshots for Database Setup
- [ ] Take screenshot of pricing_daily table structure in MySQL Workbench
- [ ] Take screenshot of sample data in pricing_daily (first 10 rows)
- [ ] Take screenshot of row count verification query
- [ ] Include all screenshots in PDF (Section: Step 2)

## Question 1: Returns Analysis (20 Points)
- [ ] Execute 02_question_1_returns_analysis.sql
  - [ ] Run Query 1.1: 12-Month Returns
  - [ ] Run Query 1.2: 18-Month Returns
  - [ ] Run Query 1.3: 24-Month Returns
  - [ ] Run Query 1.4: Portfolio Weighted Returns
- [ ] Document all SQL code used
- [ ] Take screenshots of all results
- [ ] Write explanations for your client:
  - [ ] Which securities performed best?
  - [ ] Which performed worst?
  - [ ] How does portfolio return compare to individual securities?
  - [ ] What does this tell us about diversification?
  - [ ] Are results consistent across time periods?
- [ ] Provide simple language explanations (not technical jargon)
- [ ] Score: ___/20

## Question 2: Correlation Analysis (20 Points)
- [ ] Execute 03_question_2_correlation_analysis.sql
  - [ ] Run Query 2.1: Daily Returns
  - [ ] Run Query 2.2: Monthly Returns
  - [ ] Run Query 2.3: Variance Analysis
  - [ ] Run Query 2.4: Wide Format Returns
  - [ ] Run Query 2.5: Covariance Matrix
  - [ ] Run Query 2.6: Asset Class Correlation Summary
- [ ] Document all SQL code used
- [ ] Take screenshots of all results (especially covariance matrix)
- [ ] Write explanations:
  - [ ] What does variance tell us?
  - [ ] Which assets are positively correlated?
  - [ ] Which assets are negatively correlated (good for diversification)?
  - [ ] Interesting correlations to note?
  - [ ] How does correlation help portfolio risk?
- [ ] Discuss specific interesting findings (minimum 3)
  - [ ] Finding #1: ...
  - [ ] Finding #2: ...
  - [ ] Finding #3: ...
- [ ] Score: ___/20

## Question 3: Volatility/Risk Analysis (20 Points)
- [ ] Execute 04_question_3_risk_volatility_analysis.sql
  - [ ] Run Query 3.1: 12-Month Volatility
  - [ ] Run Query 3.2: 6-Month Volatility
  - [ ] Run Query 3.3: Portfolio Risk
  - [ ] Run Query 3.4: Volatility Ranking
  - [ ] Run Query 3.5: Value at Risk (VaR)
- [ ] Document all SQL code used
- [ ] Take screenshots of all results
- [ ] Write explanations:
  - [ ] What is sigma/volatility? (simple language)
  - [ ] Which securities are highest risk?
  - [ ] Which are lowest risk?
  - [ ] What is portfolio volatility?
  - [ ] How does diversification reduce risk?
  - [ ] What does Value at Risk tell us?
- [ ] Create risk ranking table:
  - [ ] High Risk (>25% volatility): ...
  - [ ] Moderate Risk (15-25%): ...
  - [ ] Low Risk (<15%): ...
- [ ] Score: ___/20

## Question 4: Rebalancing Recommendations (20 Points)
- [ ] Execute 05_question_4_rebalancing_recommendations.sql
  - [ ] Run Query 4.1: Sharpe Ratio Analysis
  - [ ] Run Query 4.2: Allocation Analysis
  - [ ] Run Query 4.3: Asset Class Concentration
  - [ ] Run Query 4.4: Sector Rotation
  - [ ] Run Query 4.5: Diversification Assessment
- [ ] Document all SQL code used
- [ ] Take screenshots of all results (especially Sharpe ratios)
- [ ] Write detailed recommendations:
  - [ ] Which holdings would you SELL? (minimum 2, with amounts)
    - [ ] SELL #1: Ticker, Amount, Reason
    - [ ] SELL #2: Ticker, Amount, Reason
  - [ ] Which holdings would you BUY? (minimum 2, with amounts)
    - [ ] BUY #1: Ticker, Amount, Reason
    - [ ] BUY #2: Ticker, Amount, Reason
  - [ ] Any outside securities to recommend? (minimum 1)
    - [ ] Recommendation: Ticker, Why, Expected benefit
- [ ] Explain Sharpe Ratio in simple terms
- [ ] Discuss concentration risks
- [ ] Provide detailed rationale for each recommendation
- [ ] Include specific dollar amounts ($M) for all trades
- [ ] Score: ___/20

## Question 5: Post-Rebalancing Impact (20 Points)
- [ ] Execute 06_question_5_post_rebalancing_impact.sql
  - [ ] Run Query 5.1: Current Portfolio Metrics
  - [ ] Run Query 5.2: Proposed Allocation
  - [ ] Run Query 5.3: Post-Rebalancing Metrics
  - [ ] Run Query 5.4: Before vs After Comparison
  - [ ] Run Query 5.5: Implementation Plan
- [ ] Document all SQL code used
- [ ] Take screenshots of all results
- [ ] Create Before/After Comparison Table:
  - [ ] Metric | Current | Proposed | Change | Benefit
  - [ ] Expected Return: % | % | % | ...
  - [ ] Portfolio Volatility: % | % | % | ...
  - [ ] Sharpe Ratio: | | | ...
  - [ ] Value at Risk: % | % | % | ...
  - [ ] Diversification: | | | ...
- [ ] Analyze impact in different market scenarios:
  - [ ] Bull Market (stocks up 15%): Impact = ...
  - [ ] Correction (stocks down 20%): Impact = ...
  - [ ] Crisis (stocks down 30%, bonds up): Impact = ...
- [ ] Create implementation timeline:
  - [ ] Week 1: Actions and specific securities
  - [ ] Week 2: Actions and specific securities
  - [ ] Week 3: Monitoring and verification
- [ ] Estimate transaction costs
- [ ] Discuss tax implications
- [ ] Explain how rebalancing helps in different scenarios
- [ ] Score: ___/20

## PDF Document Structure
1. [ ] **Title Page**
   - [ ] Assignment Title: "UHNW Portfolio Analysis for Palo Alto Client"
   - [ ] Your Name
   - [ ] Date
   - [ ] Course/Section

2. [ ] **Table of Contents**
   - [ ] List all major sections with page numbers

3. [ ] **Executive Summary** (1-2 pages)
   - [ ] Client profile overview
   - [ ] Current portfolio summary
   - [ ] Key findings (bullet points)
   - [ ] Overall recommendations (summary)

4. [ ] **Step 1: Database Setup** (1-2 pages)
   - [ ] Screenshot of pricing_daily table structure
   - [ ] Screenshot of sample data
   - [ ] Description of data loaded
   - [ ] Verification results

5. [ ] **Question 1: Returns Analysis** (2-3 pages)
   - [ ] SQL code (nicely formatted)
   - [ ] Screenshot of results
   - [ ] Detailed explanation of findings
   - [ ] What this means for the portfolio

6. [ ] **Question 2: Correlation Analysis** (2-3 pages)
   - [ ] SQL code (nicely formatted)
   - [ ] Screenshot of correlation results
   - [ ] Screenshot of variance analysis
   - [ ] Detailed explanation
   - [ ] Minimum 3 interesting findings

7. [ ] **Question 3: Risk/Volatility Analysis** (2-3 pages)
   - [ ] SQL code (nicely formatted)
   - [ ] Screenshot of 12M volatility results
   - [ ] Screenshot of risk ranking
   - [ ] Detailed explanation of risk metrics
   - [ ] Value at Risk discussion

8. [ ] **Question 4: Rebalancing Recommendations** (3-4 pages)
   - [ ] SQL code (nicely formatted)
   - [ ] Screenshot of Sharpe ratio analysis
   - [ ] Screenshot of allocation analysis
   - [ ] Your specific recommendations (5 recommendations minimum)
   - [ ] Detailed rationale for each
   - [ ] Concentration risk discussion
   - [ ] Alternative investments discussion

9. [ ] **Question 5: Post-Rebalancing Impact** (3-4 pages)
   - [ ] SQL code (nicely formatted)
   - [ ] Before/After comparison table
   - [ ] Impact analysis in different scenarios
   - [ ] Implementation timeline
   - [ ] Transaction costs and tax implications
   - [ ] Long-term benefit analysis

10. [ ] **Recommendations Summary** (1-2 pages)
    - [ ] Concise summary of all recommendations
    - [ ] Expected portfolio improvements
    - [ ] Timeline for execution
    - [ ] Next steps for client

11. [ ] **Conclusion** (0.5-1 page)
    - [ ] Overall assessment of portfolio
    - [ ] Why these changes matter
    - [ ] Call to action

12. [ ] **Appendices** (Optional)
    - [ ] Additional charts/tables
    - [ ] Detailed calculations
    - [ ] Additional analysis

## Quality Checklist
- [ ] All SQL code is properly commented and explained
- [ ] All results are clearly presented with screenshots
- [ ] Explanations are in simple language (UHNW client can understand)
- [ ] All financial metrics explained (return, volatility, Sharpe ratio, etc.)
- [ ] Specific dollar amounts included ($M) for all recommendations
- [ ] Professional formatting and presentation
- [ ] No spelling or grammar errors
- [ ] All charts/tables properly labeled
- [ ] Calculations verified and cross-checked
- [ ] Recommendations backed by data
- [ ] PDF is complete and ready for submission

## Final Checklist Before Submission
- [ ] Count total pages: Should be 15-25 pages
- [ ] Verify all screenshots are clear and legible
- [ ] Check that all SQL code is included
- [ ] Confirm all 5 questions are thoroughly answered
- [ ] Verify all calculations are correct
- [ ] Check that recommendations are specific (not vague)
- [ ] Ensure professional tone throughout
- [ ] Proofread entire document
- [ ] Save PDF with clear filename: "UHNW_Portfolio_Analysis_[YourName].pdf"
- [ ] Keep backup copy

## Scoring Summary
| Question | Points Possible | Points Earned | Comments |
|----------|-----------------|---------------|----------|
| 1. Returns Analysis | 20 | | |
| 2. Correlation Analysis | 20 | | |
| 3. Volatility/Risk Analysis | 20 | | |
| 4. Rebalancing Recommendations | 20 | | |
| 5. Post-Rebalancing Impact | 20 | | |
| **TOTAL** | **100** | | |

## Notes & Reminders
- Use MYSQL WORKBENCH to run queries and take screenshots
- Include both SQL code AND results in PDF
- Explanations should be understandable to a non-technical client
- All financial terminology should be explained in simple terms
- Recommendations must be specific with dollar amounts
- Use actual market data (downloaded, not made up)
- Focus on data-driven insights, not opinions
- Provide rationale for every recommendation
- Discuss both risks and benefits
- Professional tone throughout
- Remember: This is a $95M portfolio for a UHNW client - quality matters!

Good luck with your assignment!
Remember: Show your work, explain your thinking, and back everything up with data!
