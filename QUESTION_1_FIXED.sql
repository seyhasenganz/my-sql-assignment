-- ===================================
-- QUESTION 1: RETURNS (12M, 18M, 24M) - FIXED VERSION
-- ===================================

-- INDIVIDUAL SECURITY RETURNS
SELECT
    sml.ticker,
    sml.security_name,
    ROUND(((end_price.value - start_price_12m.value) / start_price_12m.value) * 100, 2) as return_12m_pct,
    ROUND(((end_price.value - start_price_18m.value) / start_price_18m.value) * 100, 2) as return_18m_pct,
    ROUND(((end_price.value - start_price_24m.value) / start_price_24m.value) * 100, 2) as return_24m_pct,
    hd.portfolio_weight as current_weight_pct
FROM security_masterlist sml
LEFT JOIN holdings_dim hd ON sml.ticker = hd.ticker AND hd.account_id = 1001
LEFT JOIN (
    -- Most recent Adj Close price (TODAY)
    SELECT ticker, value, date
    FROM pricing_daily
    WHERE price_type = 'Adj Close'
    AND date = (SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close')
) end_price ON sml.ticker = end_price.ticker
LEFT JOIN (
    -- 12 MONTHS AGO price
    SELECT ticker, value, date
    FROM pricing_daily
    WHERE price_type = 'Adj Close'
    AND date = (
        SELECT MAX(date) FROM pricing_daily
        WHERE price_type = 'Adj Close'
        AND DATEDIFF((SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close'), date) BETWEEN 200 AND 300
    )
) start_price_12m ON sml.ticker = start_price_12m.ticker
LEFT JOIN (
    -- 18 MONTHS AGO price
    SELECT ticker, value, date
    FROM pricing_daily
    WHERE price_type = 'Adj Close'
    AND date = (
        SELECT MAX(date) FROM pricing_daily
        WHERE price_type = 'Adj Close'
        AND DATEDIFF((SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close'), date) BETWEEN 300 AND 450
    )
) start_price_18m ON sml.ticker = start_price_18m.ticker
LEFT JOIN (
    -- 24 MONTHS AGO price
    SELECT ticker, value, date
    FROM pricing_daily
    WHERE price_type = 'Adj Close'
    AND date = (
        SELECT MAX(date) FROM pricing_daily
        WHERE price_type = 'Adj Close'
        AND DATEDIFF((SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close'), date) BETWEEN 400 AND 600
    )
) start_price_24m ON sml.ticker = start_price_24m.ticker
ORDER BY return_12m_pct DESC;

-- PORTFOLIO LEVEL RETURNS
SELECT
    'TOTAL PORTFOLIO' as portfolio_metric,
    ROUND(SUM(hd.portfolio_weight * ((end_price.value - start_price_12m.value) / start_price_12m.value)) / 100, 2) as portfolio_return_12m_pct,
    ROUND(SUM(hd.portfolio_weight * ((end_price.value - start_price_18m.value) / start_price_18m.value)) / 100, 2) as portfolio_return_18m_pct,
    ROUND(SUM(hd.portfolio_weight * ((end_price.value - start_price_24m.value) / start_price_24m.value)) / 100, 2) as portfolio_return_24m_pct
FROM holdings_dim hd
LEFT JOIN (
    SELECT ticker, value
    FROM pricing_daily
    WHERE price_type = 'Adj Close'
    AND date = (SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close')
) end_price ON hd.ticker = end_price.ticker
LEFT JOIN (
    SELECT ticker, value
    FROM pricing_daily
    WHERE price_type = 'Adj Close'
    AND date = (
        SELECT MAX(date) FROM pricing_daily
        WHERE price_type = 'Adj Close'
        AND DATEDIFF((SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close'), date) BETWEEN 200 AND 300
    )
) start_price_12m ON hd.ticker = start_price_12m.ticker
LEFT JOIN (
    SELECT ticker, value
    FROM pricing_daily
    WHERE price_type = 'Adj Close'
    AND date = (
        SELECT MAX(date) FROM pricing_daily
        WHERE price_type = 'Adj Close'
        AND DATEDIFF((SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close'), date) BETWEEN 300 AND 450
    )
) start_price_18m ON hd.ticker = start_price_18m.ticker
LEFT JOIN (
    SELECT ticker, value
    FROM pricing_daily
    WHERE price_type = 'Adj Close'
    AND date = (
        SELECT MAX(date) FROM pricing_daily
        WHERE price_type = 'Adj Close'
        AND DATEDIFF((SELECT MAX(date) FROM pricing_daily WHERE price_type = 'Adj Close'), date) BETWEEN 400 AND 600
    )
) start_price_24m ON hd.ticker = start_price_24m.ticker
WHERE hd.account_id = 1001;
