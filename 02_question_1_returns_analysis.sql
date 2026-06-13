-- =====================================================
-- QUESTION 1: 12M, 18M, 24M RETURN ANALYSIS
-- =====================================================
-- Purpose: Calculate returns for different time periods
-- Framework: Simple Period Return = (Price_End - Price_Start) / Price_Start * 100

-- Get current date reference
-- SELECT CURDATE() as analysis_date;

-- =====================================================
-- QUERY 1.1: Calculate 12-Month (1 Year) Returns
-- =====================================================
SELECT
    'Analysis Period' as metric_type,
    DATE_FORMAT(CURDATE(), '%Y-%m-%d') as analysis_date,
    DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 12 MONTH), '%Y-%m-%d') as period_start,
    DATE_FORMAT(CURDATE(), '%Y-%m-%d') as period_end
UNION ALL
SELECT
    CONCAT(sml.ticker, ' - ', sml.security_name) as metric_type,
    CONCAT(
        'Return: ',
        ROUND(
            ((end_price.adjusted_close - start_price.adjusted_close) / start_price.adjusted_close) * 100,
            2
        ),
        '%'
    ) as analysis_date,
    CONCAT('Start Price: $', ROUND(start_price.adjusted_close, 2)) as period_start,
    CONCAT('End Price: $', ROUND(end_price.adjusted_close, 2)) as period_end
FROM security_masterlist sml
LEFT JOIN (
    SELECT ticker, adjusted_close
    FROM pricing_daily
    WHERE price_date <= CURDATE()
    AND price_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
    AND price_date = (
        SELECT MAX(price_date)
        FROM pricing_daily pd2
        WHERE pd2.ticker = pricing_daily.ticker
        AND pd2.price_date <= CURDATE()
        AND pd2.price_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
    )
) end_price ON sml.ticker = end_price.ticker
LEFT JOIN (
    SELECT ticker, adjusted_close
    FROM pricing_daily
    WHERE price_date = (
        SELECT MIN(price_date)
        FROM pricing_daily pd3
        WHERE pd3.ticker = pricing_daily.ticker
        AND pd3.price_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
    )
) start_price ON sml.ticker = start_price.ticker
ORDER BY sml.ticker;

-- =====================================================
-- QUERY 1.2: Calculate 18-Month Returns
-- =====================================================
SELECT
    sml.ticker,
    sml.security_name,
    '18-Month Return' as period,
    ROUND(start_price.adjusted_close, 2) as start_price_18m,
    ROUND(end_price.adjusted_close, 2) as end_price_18m,
    ROUND(
        ((end_price.adjusted_close - start_price.adjusted_close) / start_price.adjusted_close) * 100,
        2
    ) as return_percent_18m
FROM security_masterlist sml
LEFT JOIN (
    SELECT ticker, adjusted_close
    FROM pricing_daily
    WHERE price_date <= CURDATE()
    AND price_date >= DATE_SUB(CURDATE(), INTERVAL 18 MONTH)
    AND price_date = (
        SELECT MAX(price_date)
        FROM pricing_daily pd2
        WHERE pd2.ticker = pricing_daily.ticker
        AND pd2.price_date <= CURDATE()
        AND pd2.price_date >= DATE_SUB(CURDATE(), INTERVAL 18 MONTH)
    )
) end_price ON sml.ticker = end_price.ticker
LEFT JOIN (
    SELECT ticker, adjusted_close
    FROM pricing_daily
    WHERE price_date = (
        SELECT MIN(price_date)
        FROM pricing_daily pd3
        WHERE pd3.ticker = pricing_daily.ticker
        AND pd3.price_date >= DATE_SUB(CURDATE(), INTERVAL 18 MONTH)
    )
) start_price ON sml.ticker = start_price.ticker
ORDER BY sml.ticker;

-- =====================================================
-- QUERY 1.3: Calculate 24-Month (2 Year) Returns
-- =====================================================
SELECT
    sml.ticker,
    sml.security_name,
    '24-Month Return' as period,
    ROUND(start_price.adjusted_close, 2) as start_price_24m,
    ROUND(end_price.adjusted_close, 2) as end_price_24m,
    ROUND(
        ((end_price.adjusted_close - start_price.adjusted_close) / start_price.adjusted_close) * 100,
        2
    ) as return_percent_24m
FROM security_masterlist sml
LEFT JOIN (
    SELECT ticker, adjusted_close
    FROM pricing_daily
    WHERE price_date <= CURDATE()
    AND price_date >= DATE_SUB(CURDATE(), INTERVAL 24 MONTH)
    AND price_date = (
        SELECT MAX(price_date)
        FROM pricing_daily pd2
        WHERE pd2.ticker = pricing_daily.ticker
        AND pd2.price_date <= CURDATE()
        AND pd2.price_date >= DATE_SUB(CURDATE(), INTERVAL 24 MONTH)
    )
) end_price ON sml.ticker = end_price.ticker
LEFT JOIN (
    SELECT ticker, adjusted_close
    FROM pricing_daily
    WHERE price_date = (
        SELECT MIN(price_date)
        FROM pricing_daily pd3
        WHERE pd3.ticker = pricing_daily.ticker
        AND pd3.price_date >= DATE_SUB(CURDATE(), INTERVAL 24 MONTH)
    )
) start_price ON sml.ticker = start_price.ticker
ORDER BY sml.ticker;

-- =====================================================
-- QUERY 1.4: Portfolio Weighted Returns
-- =====================================================
SELECT
    'Portfolio Total' as security,
    ROUND(
        SUM(
            CASE
                WHEN end_price_12m IS NOT NULL THEN (return_12m * weight / 100)
                ELSE 0
            END
        ),
        2
    ) as weighted_return_12m,
    ROUND(
        SUM(
            CASE
                WHEN end_price_18m IS NOT NULL THEN (return_18m * weight / 100)
                ELSE 0
            END
        ),
        2
    ) as weighted_return_18m,
    ROUND(
        SUM(
            CASE
                WHEN end_price_24m IS NOT NULL THEN (return_24m * weight / 100)
                ELSE 0
            END
        ),
        2
    ) as weighted_return_24m
FROM (
    SELECT
        hd.ticker,
        hd.portfolio_weight as weight,
        ((pd_end_12m.adjusted_close - pd_start_12m.adjusted_close) / pd_start_12m.adjusted_close) * 100 as return_12m,
        pd_end_12m.adjusted_close as end_price_12m,
        ((pd_end_18m.adjusted_close - pd_start_18m.adjusted_close) / pd_start_18m.adjusted_close) * 100 as return_18m,
        pd_end_18m.adjusted_close as end_price_18m,
        ((pd_end_24m.adjusted_close - pd_start_24m.adjusted_close) / pd_start_24m.adjusted_close) * 100 as return_24m,
        pd_end_24m.adjusted_close as end_price_24m
    FROM holdings_dim hd
    LEFT JOIN pricing_daily pd_start_12m ON hd.ticker = pd_start_12m.ticker
        AND pd_start_12m.price_date = (
            SELECT MIN(price_date)
            FROM pricing_daily
            WHERE ticker = hd.ticker
            AND price_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
        )
    LEFT JOIN pricing_daily pd_end_12m ON hd.ticker = pd_end_12m.ticker
        AND pd_end_12m.price_date = (
            SELECT MAX(price_date)
            FROM pricing_daily
            WHERE ticker = hd.ticker
            AND price_date <= CURDATE()
        )
    LEFT JOIN pricing_daily pd_start_18m ON hd.ticker = pd_start_18m.ticker
        AND pd_start_18m.price_date = (
            SELECT MIN(price_date)
            FROM pricing_daily
            WHERE ticker = hd.ticker
            AND price_date >= DATE_SUB(CURDATE(), INTERVAL 18 MONTH)
        )
    LEFT JOIN pricing_daily pd_end_18m ON hd.ticker = pd_end_18m.ticker
        AND pd_end_18m.price_date = (
            SELECT MAX(price_date)
            FROM pricing_daily
            WHERE ticker = hd.ticker
            AND price_date <= CURDATE()
        )
    LEFT JOIN pricing_daily pd_start_24m ON hd.ticker = pd_start_24m.ticker
        AND pd_start_24m.price_date = (
            SELECT MIN(price_date)
            FROM pricing_daily
            WHERE ticker = hd.ticker
            AND price_date >= DATE_SUB(CURDATE(), INTERVAL 24 MONTH)
        )
    LEFT JOIN pricing_daily pd_end_24m ON hd.ticker = pd_end_24m.ticker
        AND pd_end_24m.price_date = (
            SELECT MAX(price_date)
            FROM pricing_daily
            WHERE ticker = hd.ticker
            AND price_date <= CURDATE()
        )
    WHERE hd.account_id = 1001
);
