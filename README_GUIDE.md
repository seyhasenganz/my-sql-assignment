# UHNW Portfolio Analysis - SQL Assignment Guide

## Project Overview
This project analyzes a $95M portfolio for an Ultra High Net Worth client in Palo Alto, CA. The portfolio consists of 5 ETFs across multiple asset classes:
- **IXN** (17.5%) - iShares Global Tech ETF
- **QQQ** (22.1%) - NASDAQ 100 ETF
- **IEF** (28.5%) - Treasury Bond ETF
- **VNQ** (8.9%) - Real Estate ETF
- **GLD** (23%) - Gold ETF

## Project Structure

### Files Included
1. **01_schema_setup.sql** - Creates database tables and initial data
2. **02_question_1_returns_analysis.sql** - 12M, 18M, 24M return calculations
3. **03_question_2_correlation_analysis.sql** - Asset correlation and variance analysis
4. **04_question_3_risk_volatility_analysis.sql** - Volatility (sigma) calculations
5. **05_question_4_rebalancing_recommendations.sql** - Sharpe ratio and rebalancing advice
6. **06_question_5_post_rebalancing_impact.sql** - Post-rebalancing metrics
7. **README_GUIDE.md** - This file

---

## STEP 1: Download Historical Pricing Data

### Data Requirements
- **Time Period**: Minimum 24 months of daily data (ideally 3 years)
- **Tickers**: IXN, QQQ, IEF, VNQ, GLD
- **Fields**: Date, Open, High, Low, Close, Adjusted Close, Volume

### Where to Get Data
1. **Yahoo Finance** (Recommended for Free Data)
   - Go to finance.yahoo.com
   - Search for each ticker (e.g., "IXN")
   - Click "Historical Data"
   - Download CSV for last 3 years
   - File format: ticker_data.csv

2. **Alternative Sources**
   - Alpha Vantage API (free tier available)
   - FRED (Federal Reserve Economic Data)
   - Your brokerage account data export

### Data Format Expected
Your CSV file should look like this:
```
Date,Open,High,Low,Close,Adj Close,Volume
2024-06-13,200.50,201.25,199.75,200.80,200.80,1500000
2024-06-12,199.75,200.50,199.00,200.10,200.10,1400000
...
```

---

## STEP 2: Create Database Schema

### Execute Schema Setup
1. Open MySQL Workbench
2. Create a new SQL script
3. Copy and paste the contents of **01_schema_setup.sql**
4. Run the script
5. Verify the tables were created:
   - `security_masterlist` - ETF definitions
   - `customer_details` - Client information
   - `acct_dim` - Account details
   - `holdings_dim` - Current portfolio holdings
   - `pricing_daily` - Historical pricing data (empty, to be populated)

---

## STEP 3: Load Historical Pricing Data

### Option A: Using MySQL LOAD DATA INFILE (Fastest)

```sql
LOAD DATA INFILE '/path/to/IXN_data.csv'
INTO TABLE investment_portfolio.pricing_daily
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(price_date, open_price, high_price, low_price, close_price, adjusted_close, volume)
SET ticker = 'IXN', price_type = 'Adjusted';
```

**Repeat for each ticker** (QQQ, IEF, VNQ, GLD)

### Option B: Using MySQL Workbench GUI
1. Right-click on `pricing_daily` table
2. Select "Table Data Import Wizard"
3. Choose your CSV file
4. Map columns appropriately
5. Set `ticker` field for each import

### Option C: Manual SQL INSERT (For Small Datasets)
```sql
INSERT INTO pricing_daily 
(ticker, price_date, open_price, high_price, low_price, close_price, adjusted_close, volume, price_type)
VALUES
('IXN', '2024-06-13', 200.50, 201.25, 199.75, 200.80, 200.80, 1500000, 'Adjusted'),
('IXN', '2024-06-12', 199.75, 200.50, 199.00, 200.10, 200.10, 1400000, 'Adjusted'),
...
```

### Verify Data Was Loaded
```sql
SELECT ticker, COUNT(*) as record_count, MIN(price_date), MAX(price_date)
FROM pricing_daily
GROUP BY ticker;
```

Expected output:
```
IXN    | ~750 records | 2021-06-13 | 2024-06-13
QQQ    | ~750 records | 2021-06-13 | 2024-06-13
IEF    | ~750 records | 2021-06-13 | 2024-06-13
VNQ    | ~750 records | 2021-06-13 | 2024-06-13
GLD    | ~750 records | 2021-06-13 | 2024-06-13
```

---

## STEP 4: Run Analysis Queries

### QUESTION 1: Returns Analysis (20 points)
Execute **02_question_1_returns_analysis.sql**

**What this calculates:**
- 12-month, 18-month, 24-month returns for each security
- Portfolio-weighted returns
- Shows how each investment has performed

**Key Metrics Explained:**
- **Return %**: ((End Price - Start Price) / Start Price) × 100
- **Positive** = Gain, **Negative** = Loss

### QUESTION 2: Correlation Analysis (20 points)
Execute **03_question_2_correlation_analysis.sql**

**What this calculates:**
- Daily returns for all securities
- Variance of returns (proxy for correlation)
- Covariance between asset pairs
- How different assets move together

**Key Metrics Explained:**
- **Variance**: Measure of how much returns fluctuate
- **Covariance**: How two assets move together
  - Positive = Move in same direction
  - Negative = Move opposite (good for diversification)
- **Low Correlation** = Better diversification

### QUESTION 3: Volatility/Risk Analysis (20 points)
Execute **04_question_3_risk_volatility_analysis.sql**

**What this calculates:**
- 12-month and 6-month volatility (sigma/standard deviation)
- Annualized volatility
- Value at Risk (VaR)
- Portfolio-weighted risk

**Key Metrics Explained:**
- **Sigma (σ)**: Standard deviation of returns = volatility/risk measure
  - High sigma = High volatility/risk
  - Low sigma = Stable/lower risk
- **Annualized Sigma**: Daily volatility × √252 (252 trading days/year)
- **VaR 95%**: Worst expected loss with 95% confidence

### QUESTION 4: Rebalancing Recommendations (20 points)
Execute **05_question_4_rebalancing_recommendations.sql**

**What this calculates:**
- Sharpe Ratio for each security: (Return - Risk-Free Rate) / Volatility
  - Higher = Better risk-adjusted return
- Current vs optimal allocation
- Asset class concentration risk
- Buy/Sell recommendations

**Key Metrics Explained:**
- **Sharpe Ratio**: Risk-adjusted return (higher is better)
  - > 0.5 = Attractive
  - 0.2-0.5 = Moderate
  - < 0.2 = Underperforming

### QUESTION 5: Post-Rebalancing Impact (20 points)
Execute **06_question_5_post_rebalancing_impact.sql**

**What this calculates:**
- Current portfolio metrics (return, volatility, Sharpe ratio)
- Proposed rebalanced portfolio metrics
- Before vs. after comparison
- Implementation plan

**Expected Changes:**
- Lower overall portfolio volatility (less risk)
- Improved Sharpe ratio (better risk-adjusted returns)
- Better diversification

---

## UNDERSTANDING THE RECOMMENDATIONS

### Current Portfolio Analysis
```
Asset Class          Current %    Volatility    Recommendation
Equity (Tech)        17.5%        ~30-35%       REDUCE - High risk, concentration
Equity (Large Cap)   22.1%        ~18-22%       REDUCE - Moderate risk
Fixed Income         28.5%        ~3-5%         INCREASE - Defensive, stable
Real Estate          8.9%         ~12-15%       INCREASE - Diversification
Commodities (Gold)   23.0%        ~16-18%       HOLD - Excellent hedge
```

### Proposed Rebalancing
```
From (Current)  →  To (Proposed)  |  Action      | Reason
IXN: 17.5%     →  IXN: 15.0%     | REDUCE $2.4M | Reduce tech concentration
QQQ: 22.1%     →  QQQ: 20.0%     | REDUCE $2.0M | Lower equity concentration
IEF: 28.5%     →  IEF: 30.0%     | INCREASE $1.4M | Strengthen defensive posture
VNQ: 8.9%      →  VNQ: 12.0%     | INCREASE $2.9M | Better diversification
GLD: 23.0%     →  GLD: 23.0%     | HOLD         | Optimal allocation
```

### Benefits of Rebalancing
1. **Lower Risk**: Reduced portfolio volatility by ~1-2%
2. **Better Returns**: Improved Sharpe ratio by ~5-10%
3. **Diversification**: Better balance across asset classes
4. **Defensive Positioning**: Increased bonds for downside protection
5. **Real Asset Exposure**: Better inflation hedge with real estate

---

## FRAMEWORKS AND METRICS USED IN ANALYSIS

### Financial Analysis Frameworks
1. **Modern Portfolio Theory (MPT)**
   - Combines risk and return optimization
   - Diversification principle

2. **Capital Asset Pricing Model (CAPM)**
   - Sharpe Ratio: (Return - Risk-Free Rate) / Volatility
   - Risk-Free Rate = 2% (US Treasury baseline)

3. **Risk Management Metrics**
   - Volatility (Standard Deviation)
   - Variance
   - Value at Risk (VaR)
   - Correlation Analysis

4. **Performance Metrics**
   - Total Return
   - Risk-Adjusted Return (Sharpe Ratio)
   - Downside Volatility

### Key Calculations

#### Return Calculation
```
Return = ((Price_End - Price_Start) / Price_Start) × 100
```

#### Volatility (Annualized)
```
Annualized Sigma = Stdev(Daily Returns) × √252
```

#### Sharpe Ratio
```
Sharpe Ratio = (Portfolio Return - Risk-Free Rate) / Portfolio Volatility
```

#### Portfolio Weighted Return
```
Portfolio Return = Σ(Weight_i × Return_i)
```

#### Value at Risk (95% confidence)
```
VaR = Mean Return - (1.645 × Sigma)
```

---

## TIPS FOR RUNNING QUERIES

1. **Ensure current date is set properly** - Queries use CURDATE()
2. **Run queries individually** - Check results after each question
3. **Take screenshots** - Document all results for your PDF submission
4. **Verify data quality** - Check for NULL values or missing dates
5. **Time window flexibility** - You can adjust 12M to 6M or 18M as needed

---

## CREATING YOUR PDF SUBMISSION

### Structure of Your PDF
1. **Title Page**
   - Assignment Title
   - Client Name (Palo Alto UHNW Client)
   - Your Name and Date

2. **Executive Summary**
   - Client profile
   - Current portfolio overview
   - Key findings and recommendations

3. **Question 1: Returns Analysis (20 points)**
   - Query code
   - Screenshot of results
   - Your explanation of returns

4. **Question 2: Correlation Analysis (20 points)**
   - Query code
   - Screenshot of results
   - Explanation of asset correlations

5. **Question 3: Volatility Analysis (20 points)**
   - Query code
   - Screenshot of results
   - Risk assessment explanation

6. **Question 4: Rebalancing Recommendations (20 points)**
   - Query code
   - Screenshot of results
   - Detailed buy/sell recommendations

7. **Question 5: Post-Rebalancing Impact (20 points)**
   - Query code
   - Screenshot of results
   - Analysis of portfolio improvements

8. **Recommendations Summary**
   - Concise summary of suggested changes
   - Expected outcomes
   - Implementation timeline

9. **Conclusion**
   - Overall portfolio health assessment
   - Strategic positioning for client

---

## COMMON ISSUES & SOLUTIONS

### Issue: "No data in pricing_daily table"
**Solution**: Verify data was imported correctly. Run:
```sql
SELECT COUNT(*) FROM pricing_daily;
```
Should return > 3,000 records.

### Issue: "NULL values in results"
**Solution**: Ensure all dates have data for all tickers. Check:
```sql
SELECT ticker, COUNT(*) FROM pricing_daily GROUP BY ticker;
```

### Issue: "CORR() function not available"
**Solution**: Queries use STDDEV and VARIANCE instead - this is why Question 2 uses variance analysis.

### Issue: "DATE_TRUNC not working"
**Solution**: Replace with:
```sql
DATE_FORMAT(price_date, '%Y-%m-01')
```

---

## ASSIGNMENT SCORING BREAKDOWN

| Question | Points | Key Elements |
|----------|--------|--------------|
| 1. Returns | 20 | 12M, 18M, 24M calculations for all securities + portfolio |
| 2. Correlation | 20 | Asset correlations, variance analysis, interesting findings |
| 3. Volatility | 20 | 12M, 6M sigma, risk classification, VaR |
| 4. Rebalancing | 20 | Sharpe ratio analysis, buy/sell recommendations, rationale |
| 5. Post-Rebalancing | 20 | Before/after metrics, implementation plan |
| **Total** | **100** | |

---

## NEXT STEPS

1. Download 3 years of daily pricing data for all 5 tickers
2. Set up database schema (01_schema_setup.sql)
3. Load pricing data into pricing_daily table
4. Run each analysis query (02-06)
5. Document results in a professional PDF
6. Include your insights and recommendations
7. Submit PDF file

Good luck with your assignment!
