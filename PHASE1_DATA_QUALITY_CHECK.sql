-- ===================================
-- PHASE 1: DATA QUALITY VERIFICATION
-- Using REAL data from pricing_daily
-- ===================================

USE invest_portfolio;

-- ===================================
-- Check 1: Overall Table Statistics
-- ===================================
SELECT
    'PRICING_DAILY TABLE STATS' as check_name,
    COUNT(*) as total_rows,
    COUNT(DISTINCT date) as unique_dates,
    COUNT(DISTINCT ticker) as unique_tickers,
    COUNT(DISTINCT price_type) as unique_price_types,
    MIN(date) as earliest_date,
    MAX(date) as latest_date,
    DATEDIFF(MAX(date), MIN(date)) as days_span
FROM pricing_daily;

-- ===================================
-- Check 2: Verify Date Range (Should be 2024-2026, not 2001-2031)
-- ===================================
SELECT
    'DATE RANGE CHECK' as check_name,
    MIN(date) as earliest_date,
    MAX(date) as latest_date,
    COUNT(DISTINCT date) as unique_dates,
    -- Calculate expected trading days (252 per year × years)
    ROUND(DATEDIFF(MAX(date), MIN(date)) / 365.25, 2) as years_span
FROM pricing_daily
WHERE price_type = 'Adj Close';

-- ===================================
-- Check 3: Ticker Presence (All 5 tickers should exist)
-- ===================================
SELECT
    ticker,
    COUNT(*) as row_count,
    COUNT(DISTINCT date) as trading_days,
    COUNT(DISTINCT price_type) as price_types
FROM pricing_daily
GROUP BY ticker
ORDER BY ticker;

-- ===================================
-- Check 4: Most Recent Data (Latest date and prices)
-- ===================================
SELECT
    'LATEST PRICES' as check_type,
    ticker,
    date as latest_date,
    price_type,
    value as price
FROM pricing_daily
WHERE price_type = 'Adj Close'
AND date = (SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close')
ORDER BY ticker;

-- ===================================
-- Check 5: Data Density (rows per date should be 30 = 5 tickers × 6 price types)
-- ===================================
SELECT
    'DATA DENSITY' as check_name,
    date,
    COUNT(*) as rows_per_date
FROM pricing_daily
WHERE date >= DATE_SUB((SELECT MAX(date) FROM pricing_daily), INTERVAL 10 DAY)
GROUP BY date
ORDER BY date DESC
LIMIT 10;

-- ===================================
-- Check 6: Price Type Coverage (All price types present?)
-- ===================================
SELECT
    price_type,
    COUNT(*) as row_count,
    COUNT(DISTINCT ticker) as tickers_with_type,
    COUNT(DISTINCT date) as dates_with_type
FROM pricing_daily
GROUP BY price_type
ORDER BY price_type;

-- ===================================
-- Check 7: Adj Close Prices for 12M, 18M, 24M lookback
-- ===================================
SELECT
    'PRICE AVAILABILITY FOR LOOKBACK PERIODS' as check_name,

    -- Today's prices
    (SELECT COUNT(*) FROM pricing_daily
     WHERE price_type = 'Adj Close'
     AND date = (SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close')) as today_count,

    -- 252 days ago (12M)
    (SELECT COUNT(*) FROM pricing_daily
     WHERE price_type = 'Adj Close'
     AND date = (SELECT MAX(date) FROM pricing_daily
                 WHERE price_type = 'Adj Close'
                 AND date <= DATE_SUB((SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close'), INTERVAL 252 DAY))) as price_252d_ago_count,

    -- 378 days ago (18M)
    (SELECT COUNT(*) FROM pricing_daily
     WHERE price_type = 'Adj Close'
     AND date = (SELECT MAX(date) FROM pricing_daily
                 WHERE price_type = 'Adj Close'
                 AND date <= DATE_SUB((SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close'), INTERVAL 378 DAY))) as price_378d_ago_count,

    -- 504 days ago (24M)
    (SELECT COUNT(*) FROM pricing_daily
     WHERE price_type = 'Adj Close'
     AND date = (SELECT MAX(date) FROM pricing_daily
                 WHERE price_type = 'Adj Close'
                 AND date <= DATE_SUB((SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close'), INTERVAL 504 DAY))) as price_504d_ago_count
FROM pricing_daily
LIMIT 1;

-- ===================================
-- Check 8: Verify Holdings Dimension (Portfolio allocation)
-- ===================================
SELECT
    'PORTFOLIO ALLOCATION' as allocation_check,
    h.ticker,
    s.security_name,
    h.portfolio_weight,
    h.market_value_million
FROM holdings_dim h
LEFT JOIN security_masterlist s ON h.ticker = s.ticker
WHERE h.account_id = 1001
ORDER BY h.portfolio_weight DESC;

-- ===================================
-- Check 9: Data Quality Summary
-- ===================================
SELECT
    CASE
        WHEN MIN(pd.date) >= '2024-01-01' AND MAX(pd.date) <= '2026-12-31' THEN '✓ DATE RANGE OK (2024-2026)'
        ELSE '✗ DATE RANGE ISSUE'
    END as date_check,

    CASE
        WHEN COUNT(DISTINCT pd.ticker) = 5 THEN '✓ ALL 5 TICKERS PRESENT'
        ELSE '✗ MISSING TICKERS'
    END as ticker_check,

    CASE
        WHEN COUNT(*) >= 15000 THEN '✓ SUFFICIENT DATA ROWS'
        ELSE '✗ INSUFFICIENT DATA'
    END as data_volume_check,

    COUNT(DISTINCT pd.date) as trading_days_available
FROM pricing_daily pd;

-- ===================================
-- EXPLANATION
-- ===================================
/*
WHAT WE'RE CHECKING:

1. Overall Statistics:
   - Total rows should be ~15,000-16,000 (5 tickers × 6 price types × 502 dates)
   - Unique dates should be ~502
   - Date range should be 2024-2026 (after DD-MM-YY fix)

2. Date Range Verification:
   - Earliest: Should be June 2024 or later
   - Latest: Should be June 2026
   - If showing 2001-2031, date fix didn't work

3. Ticker Presence:
   - GLD, IXN, QQQ, VNQ, IEF should all exist
   - Each should have ~3,000+ rows (502 dates × 6 price types)

4. Latest Prices:
   - Should show current prices for all 5 tickers
   - These are needed for 12M/18M/24M return calculations

5. Data Density:
   - Each date should have 30 rows (5 tickers × 6 price types)
   - Recent dates should have complete data

6. Price Types:
   - Should have 6 types: Open, High, Low, Close, Adj Close, Volume
   - Use 'Adj Close' for return calculations

7. Historical Lookback:
   - Need prices from 252, 378, 504 days ago
   - If dates are correct, should find data for all periods

8. Holdings Dimension:
   - Confirms portfolio weights sum to 100%
   - Shows dollar allocation per holding

9. Final Quality Summary:
   - Automated checks to confirm data is ready for analysis
*/
