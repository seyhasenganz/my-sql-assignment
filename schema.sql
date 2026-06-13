-- ===================================
-- UHNW PORTFOLIO ANALYSIS
-- Database Schema
-- ===================================

CREATE DATABASE IF NOT EXISTS investment_portfolio;
USE investment_portfolio;

-- Tables from assignment
CREATE TABLE security_masterlist (
    ticker VARCHAR(3),
    security_name VARCHAR(200),
    security_type VARCHAR(100),
    major_asset_class VARCHAR(100),
    minor_asset_class VARCHAR(100),
    country VARCHAR(100),
    PRIMARY KEY (ticker)
);

INSERT INTO security_masterlist VALUES
('IXN', 'iShares Global Tech ETF', 'etf', 'equity', 'technology', 'Global'),
('QQQ', 'Invesco QQQ Trust', 'etf', 'equity', 'large_cap', 'USA'),
('IEF', 'iShares 7-10 Year Treasury Bond ETF', 'etf', 'fixed_income', 'government_bond', 'USA'),
('VNQ', 'Vanguard Real Estate ETF', 'etf', 'real_assets', 'real_estate', 'USA'),
('GLD', 'SPDR Gold Shares', 'etf', 'commodities', 'gold', 'Global');

CREATE TABLE acct_dim (
    account_id INT,
    customer_id INT,
    account_name VARCHAR(100),
    account_type VARCHAR(50),
    strategy VARCHAR(100),
    acct_open_date DATE,
    acct_open_status TINYINT,
    PRIMARY KEY (account_id)
);

INSERT INTO acct_dim VALUES
(1001, 1, 'Palo Alto UHNW Portfolio', 'Managed Portfolio', 'Strategic Asset Allocation', '2024-01-01', 1);

CREATE TABLE customer_details (
    customer_id INT,
    full_name VARCHAR(250),
    first_name VARCHAR(250),
    last_name VARCHAR(250),
    email VARCHAR(250),
    customer_location VARCHAR(250),
    client_type VARCHAR(100),
    company_name VARCHAR(250),
    PRIMARY KEY (customer_id)
);

INSERT INTO customer_details VALUES
(1, 'Palo Alto UHNW Client', 'Palo Alto', 'Client', 'client@portfolio.com', 'Palo Alto, California', 'Ultra High Net Worth', NULL);

CREATE TABLE holdings_dim (
    account_id INT,
    ticker VARCHAR(3),
    portfolio_weight DECIMAL(5,2),
    market_value_million DECIMAL(15,3),
    PRIMARY KEY (account_id, ticker)
);

INSERT INTO holdings_dim VALUES
(1001, 'IXN', 17.50, 16.625),
(1001, 'QQQ', 22.10, 20.995),
(1001, 'IEF', 28.50, 27.075),
(1001, 'VNQ', 8.90, 8.455),
(1001, 'GLD', 23.00, 21.850);

-- Pricing table - Load your downloaded data here
CREATE TABLE pricing_daily (
    ticker VARCHAR(10),
    price_date DATE,
    open_price DECIMAL(10,4),
    high_price DECIMAL(10,4),
    low_price DECIMAL(10,4),
    close_price DECIMAL(10,4),
    adjusted_close DECIMAL(10,4),
    volume BIGINT,
    PRIMARY KEY (ticker, price_date),
    INDEX idx_ticker_date (ticker, price_date)
);
