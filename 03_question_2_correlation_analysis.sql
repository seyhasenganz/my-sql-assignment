-- =====================================================
-- QUESTION 2: CORRELATION ANALYSIS
-- =====================================================
-- Purpose: Analyze correlations between assets
-- Framework: If CORR() not available, we calculate variance and daily returns

-- =====================================================
-- QUERY 2.1: Daily Returns for All Securities (Last 12 Months)
-- =====================================================
-- This subquery creates daily returns which we'll use for correlation analysis
SELECT
    ticker,
    price_date,
    adjusted_close,
    LAG(adjusted_close, 1) OVER (PARTITION BY ticker ORDER BY price_date) as prev_price,
    ROUND(
        ((adjusted_close - LAG(adjusted_close, 1) OVER (PARTITION BY ticker ORDER BY price_date))
         / LAG(adjusted_close, 1) OVER (PARTITION BY ticker ORDER BY price_date)) * 100,
        4
    ) as daily_return_pct
FROM pricing_daily
WHERE price_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
ORDER BY ticker, price_date;

-- =====================================================
-- QUERY 2.2: Monthly Returns for Correlation Analysis
-- =====================================================
-- Group returns by month for better correlation metrics
SELECT
    ticker,
    DATE_TRUNC(price_date, MONTH) as month,
    ROUND(
        ((MAX(adjusted_close) - MIN(adjusted_close)) / MIN(adjusted_close)) * 100,
        2
    ) as monthly_return_pct
FROM pricing_daily
WHERE price_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY ticker, DATE_TRUNC(price_date, MONTH)
ORDER BY ticker, month;

-- =====================================================
-- QUERY 2.3: Variance of Daily Returns (Proxy for Correlation)
-- =====================================================
-- Calculate variance for each ticker for the last 12 months
SELECT
    ticker,
    ROUND(AVG(daily_return_pct), 4) as avg_daily_return,
    ROUND(STDDEV_POP(daily_return_pct), 4) as daily_volatility,
    ROUND(VARIANCE(daily_return_pct), 6) as variance_daily_returns,
    ROUND(MIN(daily_return_pct), 4) as min_daily_return,
    ROUND(MAX(daily_return_pct), 4) as max_daily_return
FROM (
    SELECT
        ticker,
        price_date,
        ROUND(
            ((adjusted_close - LAG(adjusted_close, 1) OVER (PARTITION BY ticker ORDER BY price_date))
             / LAG(adjusted_close, 1) OVER (PARTITION BY ticker ORDER BY price_date)) * 100,
            4
        ) as daily_return_pct
    FROM pricing_daily
    WHERE price_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
) returns_data
WHERE daily_return_pct IS NOT NULL
GROUP BY ticker
ORDER BY variance_daily_returns DESC;

-- =====================================================
-- QUERY 2.4: Create Wide Format for Manual Correlation (If CORR() Not Available)
-- =====================================================
-- Pivot daily returns to wide format for manual correlation analysis
SELECT
    price_date,
    MAX(CASE WHEN ticker = 'IXN' THEN daily_return_pct END) as IXN_return,
    MAX(CASE WHEN ticker = 'QQQ' THEN daily_return_pct END) as QQQ_return,
    MAX(CASE WHEN ticker = 'IEF' THEN daily_return_pct END) as IEF_return,
    MAX(CASE WHEN ticker = 'VNQ' THEN daily_return_pct END) as VNQ_return,
    MAX(CASE WHEN ticker = 'GLD' THEN daily_return_pct END) as GLD_return
FROM (
    SELECT
        ticker,
        price_date,
        ROUND(
            ((adjusted_close - LAG(adjusted_close, 1) OVER (PARTITION BY ticker ORDER BY price_date))
             / LAG(adjusted_close, 1) OVER (PARTITION BY ticker ORDER BY price_date)) * 100,
            4
        ) as daily_return_pct
    FROM pricing_daily
    WHERE price_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
) returns_data
GROUP BY price_date
ORDER BY price_date;

-- =====================================================
-- QUERY 2.5: Covariance Matrix Components (6-Month Window)
-- =====================================================
-- Calculate covariance between pairs of securities
-- Covariance(X,Y) = AVG((X - AVG(X)) * (Y - AVG(Y)))
WITH returns_6m AS (
    SELECT
        ticker,
        price_date,
        ROUND(
            ((adjusted_close - LAG(adjusted_close, 1) OVER (PARTITION BY ticker ORDER BY price_date))
             / LAG(adjusted_close, 1) OVER (PARTITION BY ticker ORDER BY price_date)) * 100,
            4
        ) as daily_return_pct
    FROM pricing_daily
    WHERE price_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
)
SELECT
    'IXN vs QQQ' as asset_pair,
    ROUND(
        (SUM((ixn.daily_return_pct - ixn_avg.avg_ret) * (qqq.daily_return_pct - qqq_avg.avg_ret))
         / COUNT(*)),
        6
    ) as covariance
FROM returns_6m ixn
JOIN returns_6m qqq ON ixn.price_date = qqq.price_date AND ixn.ticker = 'IXN' AND qqq.ticker = 'QQQ'
CROSS JOIN (SELECT AVG(daily_return_pct) as avg_ret FROM returns_6m WHERE ticker = 'IXN' AND daily_return_pct IS NOT NULL) ixn_avg
CROSS JOIN (SELECT AVG(daily_return_pct) as avg_ret FROM returns_6m WHERE ticker = 'QQQ' AND daily_return_pct IS NOT NULL) qqq_avg
WHERE ixn.daily_return_pct IS NOT NULL AND qqq.daily_return_pct IS NOT NULL
UNION ALL
SELECT
    'IXN vs IEF' as asset_pair,
    ROUND(
        (SUM((ixn.daily_return_pct - ixn_avg.avg_ret) * (ief.daily_return_pct - ief_avg.avg_ret))
         / COUNT(*)),
        6
    ) as covariance
FROM returns_6m ixn
JOIN returns_6m ief ON ixn.price_date = ief.price_date AND ixn.ticker = 'IXN' AND ief.ticker = 'IEF'
CROSS JOIN (SELECT AVG(daily_return_pct) as avg_ret FROM returns_6m WHERE ticker = 'IXN' AND daily_return_pct IS NOT NULL) ixn_avg
CROSS JOIN (SELECT AVG(daily_return_pct) as avg_ret FROM returns_6m WHERE ticker = 'IEF' AND daily_return_pct IS NOT NULL) ief_avg
WHERE ixn.daily_return_pct IS NOT NULL AND ief.daily_return_pct IS NOT NULL
UNION ALL
SELECT
    'QQQ vs IEF' as asset_pair,
    ROUND(
        (SUM((qqq.daily_return_pct - qqq_avg.avg_ret) * (ief.daily_return_pct - ief_avg.avg_ret))
         / COUNT(*)),
        6
    ) as covariance
FROM returns_6m qqq
JOIN returns_6m ief ON qqq.price_date = ief.price_date AND qqq.ticker = 'QQQ' AND ief.ticker = 'IEF'
CROSS JOIN (SELECT AVG(daily_return_pct) as avg_ret FROM returns_6m WHERE ticker = 'QQQ' AND daily_return_pct IS NOT NULL) qqq_avg
CROSS JOIN (SELECT AVG(daily_return_pct) as avg_ret FROM returns_6m WHERE ticker = 'IEF' AND daily_return_pct IS NOT NULL) ief_avg
WHERE qqq.daily_return_pct IS NOT NULL AND ief.daily_return_pct IS NOT NULL;

-- =====================================================
-- QUERY 2.6: Asset Class Correlation Summary
-- =====================================================
SELECT
    sml1.major_asset_class as asset_class_1,
    sml2.major_asset_class as asset_class_2,
    COUNT(*) as pair_count,
    ROUND(STDDEV_POP(returns1.daily_return_pct), 4) as volatility_class_1,
    ROUND(STDDEV_POP(returns2.daily_return_pct), 4) as volatility_class_2
FROM security_masterlist sml1
CROSS JOIN security_masterlist sml2
LEFT JOIN (
    SELECT
        ticker,
        ROUND(
            ((adjusted_close - LAG(adjusted_close, 1) OVER (PARTITION BY ticker ORDER BY price_date))
             / LAG(adjusted_close, 1) OVER (PARTITION BY ticker ORDER BY price_date)) * 100,
            4
        ) as daily_return_pct
    FROM pricing_daily
    WHERE price_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
) returns1 ON sml1.ticker = returns1.ticker
LEFT JOIN (
    SELECT
        ticker,
        ROUND(
            ((adjusted_close - LAG(adjusted_close, 1) OVER (PARTITION BY ticker ORDER BY price_date))
             / LAG(adjusted_close, 1) OVER (PARTITION BY ticker ORDER BY price_date)) * 100,
            4
        ) as daily_return_pct
    FROM pricing_daily
    WHERE price_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
) returns2 ON sml2.ticker = returns2.ticker
WHERE sml1.ticker < sml2.ticker
GROUP BY sml1.major_asset_class, sml2.major_asset_class
ORDER BY sml1.major_asset_class, sml2.major_asset_class;
