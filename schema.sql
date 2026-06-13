-- ===================================
-- UHNW PORTFOLIO ANALYSIS - DATABASE SCHEMA
-- Actual Table Structure (For Reference)
-- ===================================
-- Note: These tables should already exist in your database
-- This file documents the ACTUAL structure you have

USE invest_portfolio;

-- ===================================
-- 1. PRICING DATA TABLE (MAIN DATA SOURCE)
-- ===================================
-- This table contains all daily pricing data for the 5 ETFs
-- Each day has multiple rows: Open, High, Low, Close, Adj Close, Volume

CREATE TABLE pricing_daily (
    date       DATE  NOT NULL,              -- Trading date (DD-MM-YY format from data)
    ticker     VARCHAR(3) NOT NULL,         -- ETF ticker: IXN, QQQ, IEF, VNQ, GLD
    price_type VARCHAR(10) NOT NULL,        -- Type: 'Open', 'High', 'Low', 'Close', 'Adj Close', 'Volume'
    value      NUMERIC(11,2) NOT NULL,     -- Price value or volume number

    PRIMARY KEY (date, ticker, price_type),
    INDEX idx_ticker_date (ticker, date),
    INDEX idx_price_type (price_type)
);

-- Example data structure:
-- date       | ticker | price_type | value
-- 2024-06-12 | IXN    | Open       | 138.50
-- 2024-06-12 | IXN    | High       | 140.48
-- 2024-06-12 | IXN    | Low        | 137.60
-- 2024-06-12 | IXN    | Close      | 139.73
-- 2024-06-12 | IXN    | Adj Close  | 139.73
-- 2024-06-12 | IXN    | Volume     | 186178

-- ===================================
-- 2. SECURITY MASTER LIST
-- ===================================
-- Reference table for all securities in the portfolio

CREATE TABLE security_masterlist (
    ticker VARCHAR(3) PRIMARY KEY,
    security_name VARCHAR(200),
    security_type VARCHAR(100),
    major_asset_class VARCHAR(100),        -- equity, fixed_income, real_assets, commodities
    minor_asset_class VARCHAR(100),        -- technology, large_cap, government_bond, real_estate, gold
    country VARCHAR(100)
);

INSERT INTO security_masterlist
(ticker, security_name, security_type, major_asset_class, minor_asset_class, country)
VALUES
('IXN', 'iShares Global Tech ETF', 'etf', 'equity', 'technology', 'Global'),
('QQQ', 'Invesco QQQ Trust', 'etf', 'equity', 'large_cap', 'USA'),
('IEF', 'iShares 7-10 Year Treasury Bond ETF', 'etf', 'fixed_income', 'government_bond', 'USA'),
('VNQ', 'Vanguard Real Estate ETF', 'etf', 'real_assets', 'real_estate', 'USA'),
('GLD', 'SPDR Gold Shares', 'etf', 'commodities', 'gold', 'Global');

-- ===================================
-- 3. CUSTOMER DETAILS TABLE
-- ===================================
-- Client information

CREATE TABLE customer_details (
    customer_id INT PRIMARY KEY,
    full_name VARCHAR(250),
    first_name VARCHAR(250),
    last_name VARCHAR(250),
    email VARCHAR(250),
    customer_location VARCHAR(250),
    client_type VARCHAR(100),              -- Ultra High Net Worth, High Net Worth, etc.
    company_name VARCHAR(250)
);

INSERT INTO customer_details
(customer_id, full_name, first_name, last_name, email, customer_location, client_type, company_name)
VALUES
(1, 'Palo Alto UHNW Client', 'Palo Alto', 'Client', 'client@portfolio.com', 'Palo Alto, California', 'Ultra High Net Worth', NULL);

-- ===================================
-- 4. ACCOUNT DIMENSION TABLE
-- ===================================
-- Portfolio account information

CREATE TABLE acct_dim (
    account_id INT PRIMARY KEY,
    customer_id INT,
    account_name VARCHAR(100),
    account_type VARCHAR(50),              -- Managed Portfolio, Investment Account, etc.
    strategy VARCHAR(100),                 -- Strategic Asset Allocation
    acct_open_date DATE,
    acct_open_status TINYINT,              -- 1 = Active, 0 = Inactive

    FOREIGN KEY (customer_id) REFERENCES customer_details(customer_id)
);

INSERT INTO acct_dim
(account_id, customer_id, account_name, account_type, strategy, acct_open_date, acct_open_status)
VALUES
(1001, 1, 'Palo Alto UHNW Portfolio', 'Managed Portfolio', 'Strategic Asset Allocation', '2024-01-01', 1);

-- ===================================
-- 5. HOLDINGS DIMENSION TABLE
-- ===================================
-- Current portfolio holdings and allocations

CREATE TABLE holdings_dim (
    account_id INT,
    ticker VARCHAR(3),
    portfolio_weight DECIMAL(5,2),         -- Percentage allocation (e.g., 17.50 for 17.5%)
    market_value_million DECIMAL(15,3),    -- Current market value in millions

    PRIMARY KEY (account_id, ticker),
    FOREIGN KEY (account_id) REFERENCES acct_dim(account_id),
    FOREIGN KEY (ticker) REFERENCES security_masterlist(ticker)
);

INSERT INTO holdings_dim
(account_id, ticker, portfolio_weight, market_value_million)
VALUES
(1001, 'IXN', 17.50, 16.625),              -- 17.5% of $95M = $16.625M
(1001, 'QQQ', 22.10, 20.995),              -- 22.1% of $95M = $20.995M
(1001, 'IEF', 28.50, 27.075),              -- 28.5% of $95M = $27.075M
(1001, 'VNQ', 8.90, 8.455),                -- 8.9% of $95M = $8.455M
(1001, 'GLD', 23.00, 21.850);              -- 23.0% of $95M = $21.850M

-- Total: 100% allocation = $95.000M

-- ===================================
-- KEY POINTS FOR ANALYSIS
-- ===================================

-- 1. PRICING_DAILY Table:
--    - Contains 6 price types per ticker per day: Open, High, Low, Close, Adj Close, Volume
--    - Use price_type = 'Adj Close' for return calculations
--    - Dates span approximately 2-3 years of trading data
--    - For 5 tickers × 6 price types × ~250 trading days/year × 2-3 years
--    - Approximately 18,000-27,000 rows total

-- 2. RETURNS CALCULATION:
--    - Formula: ((End Price - Start Price) / Start Price) × 100
--    - Use 'Adj Close' price_type for all return calculations
--    - Time periods: 12M (12 months), 18M (18 months), 24M (24 months)

-- 3. VOLATILITY CALCULATION:
--    - Daily Returns = ((Today's Adj Close - Yesterday's Adj Close) / Yesterday's Adj Close) × 100
--    - Sigma (Volatility) = STDEV of daily returns
--    - Annualized Sigma = Daily Sigma × √252 (252 trading days per year)

-- 4. CORRELATIONS:
--    - Compare variance of daily returns between securities
--    - High variance = high risk
--    - Low correlation between securities = good diversification

-- 5. PORTFOLIO METRICS:
--    - Portfolio Return = SUM(Weight × Security Return)
--    - Portfolio Volatility = SQRT(SUM(Weight² × Variance) + 2×SUM(Correlation terms))
--    - Sharpe Ratio = (Portfolio Return - Risk-Free Rate) / Portfolio Volatility
--    - Risk-Free Rate = 2% (US Treasury baseline)

-- ===================================
-- QUERIES TO RUN
-- ===================================
-- Use the SQL queries in: questions_with_real_data.sql
-- These queries work with this exact table structure

-- Query 1: Returns Analysis (12M, 18M, 24M)
-- Query 2: Correlations & Variance Analysis
-- Query 3: Volatility (Sigma) Analysis (12M, 6M)
-- Query 4: Sharpe Ratio & Buy/Sell Recommendations
-- Query 5: Post-Rebalancing Impact Analysis
