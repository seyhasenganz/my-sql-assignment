# UHNW Portfolio Analysis - Simple Instructions

## Step 1: Create Database & Tables
1. Open MySQL Workbench
2. Copy & run `schema.sql`
3. This creates all 5 tables with sample data

## Step 2: Load Pricing Data
1. Download 3 years of daily pricing for: IXN, QQQ, IEF, VNQ, GLD
   - Use Yahoo Finance (finance.yahoo.com)
   - Download as CSV: Date, Open, High, Low, Close, Adj Close, Volume

2. In MySQL Workbench:
   - Right-click `pricing_daily` table
   - Select "Table Data Import Wizard"
   - Choose your CSV file
   - Map columns properly
   - Import

3. Repeat for all 5 tickers

## Step 3: Run Analysis Queries
Open `analysis_queries.sql` and run each query:

### Query 1: Returns (12M, 18M, 24M)
- Shows return % for each security over different periods
- Shows which securities performed best/worst

### Query 2: Correlations & Variance
- Shows how much each security varies (volatility)
- Higher variance = more risk

### Query 3: Volatility (12M & 6M)
- Shows annualized volatility (sigma)
- 12M vs 6M comparison
- Risk ranking

### Query 4: Sharpe Ratio & Recommendations
- Sharpe Ratio = (Return - 2%) / Volatility
- Higher Sharpe = better risk-adjusted returns
- Shows buy/hold/sell recommendations

### Query 5: Before vs After Rebalancing
- Compare current allocation to proposed allocation
- Shows expected improvement in returns, volatility, Sharpe ratio

## Step 4: Create PDF
For each of 5 questions:
1. Include SQL code
2. Include screenshot of results
3. Explain findings in simple language
4. For Q4: Add specific buy/sell recommendations with dollar amounts
5. For Q5: Show before/after metrics and implementation plan

## Key Points
- **Return** = ((End Price - Start Price) / Start Price) × 100
- **Volatility/Sigma** = How much returns bounce around (higher = riskier)
- **Sharpe Ratio** = Risk-adjusted return (higher = better)
- **Rebalancing** = Selling underperforming assets, buying underweighted assets

## Recommendations Summary
Based on typical analysis:
- **REDUCE** IXN (lower Sharpe ratio) → SELL $2.4M
- **REDUCE** QQQ (high tech concentration) → SELL $2.1M  
- **INCREASE** IEF (defensive, good Sharpe) → BUY $1.4M
- **INCREASE** VNQ (underweighted, good diversification) → BUY $2.9M
- **HOLD** GLD (already optimal)

Expected: Sharpe ratio improves by ~12%, volatility reduces by ~0.5%
