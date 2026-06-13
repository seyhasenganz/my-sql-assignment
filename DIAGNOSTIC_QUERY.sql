-- ===================================
-- DIAGNOSTIC QUERIES - Check Your Data
-- ===================================

-- 1. Check if Adj Close prices exist
SELECT
    'Total Adj Close records' as check_type,
    COUNT(*) as count
FROM pricing_daily
WHERE price_type = 'Adj Close';

-- 2. Check date range of your data
SELECT
    'Date Range' as check_type,
    MIN(date) as earliest_date,
    MAX(date) as latest_date,
    DATEDIFF(MAX(date), MIN(date)) as days_span
FROM pricing_daily
WHERE price_type = 'Adj Close';

-- 3. Check how many tickers have data
SELECT
    'Tickers with Adj Close' as check_type,
    ticker,
    COUNT(*) as record_count,
    MIN(date) as earliest,
    MAX(date) as latest
FROM pricing_daily
WHERE price_type = 'Adj Close'
GROUP BY ticker;

-- 4. Sample of actual Adj Close data for IXN
SELECT
    'Sample IXN Adj Close Prices' as check_type,
    date,
    ticker,
    price_type,
    value
FROM pricing_daily
WHERE ticker = 'IXN'
AND price_type = 'Adj Close'
ORDER BY date DESC
LIMIT 20;

-- 5. Check if start_price_12m can find any dates
SELECT
    'Date lookup test for 12M' as check_type,
    (SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close') as today_date,
    DATE_SUB((SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close'), INTERVAL 252 DAY) as target_12m_date,
    (SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close'
     AND date <= DATE_SUB((SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close'), INTERVAL 252 DAY)) as actual_12m_date;

-- 6. Get actual prices if they exist
SELECT
    sml.ticker,
    sml.security_name,
    end_price.value as today_price,
    start_price_12m.value as price_12m_ago,
    ROUND(((end_price.value - start_price_12m.value) / start_price_12m.value) * 100, 2) as return_pct
FROM security_masterlist sml
LEFT JOIN (
    SELECT ticker, value
    FROM pricing_daily
    WHERE price_type = 'Adj Close'
    AND date = (SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close')
) end_price ON sml.ticker = end_price.ticker
LEFT JOIN (
    SELECT ticker, value
    FROM pricing_daily
    WHERE price_type = 'Adj Close'
    AND date = (
        SELECT MAX(date) FROM pricing_daily
        WHERE price_type = 'Adj Close'
        AND date <= DATE_SUB((SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close'), INTERVAL 252 DAY)
    )
) start_price_12m ON sml.ticker = start_price_12m.ticker;
