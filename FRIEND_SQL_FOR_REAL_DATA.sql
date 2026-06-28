-- ============================================================================
-- FRIEND_SQL_FOR_REAL_DATA.sql
-- Advanced SQL Queries for Stock Market Analysis
-- ============================================================================
-- Use these queries to analyze real stock market data in your
-- daily_stock_prices table. These are production-ready queries!

-- ============================================================================
-- 1. TICKER OVERVIEW & SUMMARY
-- ============================================================================

-- Comprehensive ticker summary
SELECT
    ticker,
    COUNT(*) as total_trading_days,
    MIN(trading_date) as first_date,
    MAX(trading_date) as last_date,
    DATEDIFF(MAX(trading_date), MIN(trading_date)) as days_span,
    ROUND(MIN(low_price), 2) as lowest_price,
    ROUND(MAX(high_price), 2) as highest_price,
    ROUND(AVG(close_price), 2) as avg_close,
    ROUND(STDDEV(close_price), 2) as price_volatility,
    ROUND(AVG(volume), 0) as avg_daily_volume
FROM daily_stock_prices
GROUP BY ticker
ORDER BY ticker;


-- ============================================================================
-- 2. PRICE STATISTICS
-- ============================================================================

-- Find the most expensive stock (by closing price)
SELECT
    trading_date,
    ticker,
    close_price
FROM daily_stock_prices
ORDER BY close_price DESC
LIMIT 1;

-- Find the cheapest stock
SELECT
    trading_date,
    ticker,
    close_price
FROM daily_stock_prices
ORDER BY close_price ASC
LIMIT 1;

-- Price categories by ticker
SELECT
    ticker,
    COUNT(*) as count,
    CASE
        WHEN close_price < 50 THEN 'Under $50'
        WHEN close_price BETWEEN 50 AND 100 THEN '$50-100'
        WHEN close_price BETWEEN 100 AND 150 THEN '$100-150'
        WHEN close_price BETWEEN 150 AND 200 THEN '$150-200'
        ELSE 'Over $200'
    END as price_range
FROM daily_stock_prices
GROUP BY ticker, price_range
ORDER BY ticker, price_range;


-- ============================================================================
-- 3. VOLUME ANALYSIS
-- ============================================================================

-- Highest volume trading days (top 20)
SELECT
    trading_date,
    ticker,
    volume,
    close_price,
    (high_price - low_price) as daily_range
FROM daily_stock_prices
ORDER BY volume DESC
LIMIT 20;

-- Volume spikes (days with volume > 2x average for that ticker)
SELECT
    dp.trading_date,
    dp.ticker,
    dp.volume,
    ROUND(avg_vol.avg_volume, 0) as avg_volume,
    ROUND(dp.volume / avg_vol.avg_volume, 2) as volume_multiple
FROM daily_stock_prices dp
JOIN (
    SELECT ticker, AVG(volume) as avg_volume
    FROM daily_stock_prices
    GROUP BY ticker
) avg_vol ON dp.ticker = avg_vol.ticker
WHERE dp.volume > avg_vol.avg_volume * 2
ORDER BY dp.volume DESC
LIMIT 30;

-- Average volume by ticker (useful for liquidity analysis)
SELECT
    ticker,
    ROUND(AVG(volume), 0) as avg_volume,
    ROUND(STDDEV(volume), 0) as volume_std_dev,
    MIN(volume) as min_volume,
    MAX(volume) as max_volume
FROM daily_stock_prices
GROUP BY ticker
ORDER BY avg_volume DESC;


-- ============================================================================
-- 4. PRICE MOVEMENT ANALYSIS
-- ============================================================================

-- Daily price changes (showing positive and negative moves)
SELECT
    trading_date,
    ticker,
    open_price,
    close_price,
    (close_price - open_price) as price_change,
    ROUND((close_price - open_price) / open_price * 100, 2) as percent_change,
    CASE
        WHEN close_price > open_price THEN 'UP'
        WHEN close_price < open_price THEN 'DOWN'
        ELSE 'FLAT'
    END as direction
FROM daily_stock_prices
ORDER BY trading_date DESC, ticker
LIMIT 50;

-- Count bullish and bearish days by ticker
SELECT
    ticker,
    COUNT(CASE WHEN close_price > open_price THEN 1 END) as bullish_days,
    COUNT(CASE WHEN close_price < open_price THEN 1 END) as bearish_days,
    COUNT(CASE WHEN close_price = open_price THEN 1 END) as flat_days,
    COUNT(*) as total_days,
    ROUND(COUNT(CASE WHEN close_price > open_price THEN 1 END) / COUNT(*) * 100, 2) as bullish_percent
FROM daily_stock_prices
GROUP BY ticker
ORDER BY bullish_percent DESC;

-- Average gain on bullish days vs loss on bearish days
SELECT
    ticker,
    ROUND(AVG(CASE WHEN close_price > open_price THEN (close_price - open_price) / open_price * 100 END), 2) as avg_daily_gain,
    ROUND(AVG(CASE WHEN close_price < open_price THEN (close_price - open_price) / open_price * 100 END), 2) as avg_daily_loss
FROM daily_stock_prices
GROUP BY ticker
ORDER BY ticker;


-- ============================================================================
-- 5. VOLATILITY & RANGE ANALYSIS
-- ============================================================================

-- Daily high-low spread (range)
SELECT
    trading_date,
    ticker,
    high_price,
    low_price,
    (high_price - low_price) as daily_range,
    ROUND((high_price - low_price) / open_price * 100, 2) as range_percent
FROM daily_stock_prices
ORDER BY daily_range DESC
LIMIT 20;

-- Average volatility by ticker (intraday range)
SELECT
    ticker,
    COUNT(*) as trading_days,
    ROUND(AVG(high_price - low_price), 2) as avg_daily_range,
    ROUND(STDDEV(high_price - low_price), 2) as volatility,
    ROUND(MAX(high_price - low_price), 2) as max_range,
    ROUND(MIN(high_price - low_price), 2) as min_range
FROM daily_stock_prices
GROUP BY ticker
ORDER BY volatility DESC;

-- Days with gap up (open > previous close)
SELECT
    a.trading_date,
    a.ticker,
    b.close_price as previous_close,
    a.open_price as today_open,
    (a.open_price - b.close_price) as gap,
    ROUND((a.open_price - b.close_price) / b.close_price * 100, 2) as gap_percent
FROM daily_stock_prices a
JOIN daily_stock_prices b
ON a.ticker = b.ticker
AND DATE_ADD(b.trading_date, INTERVAL 1 DAY) = a.trading_date
WHERE a.open_price > b.close_price
ORDER BY gap DESC
LIMIT 20;


-- ============================================================================
-- 6. TREND ANALYSIS
-- ============================================================================

-- Get closing price for last N days by ticker
SELECT
    ticker,
    trading_date,
    close_price,
    ROW_NUMBER() OVER (PARTITION BY ticker ORDER BY trading_date DESC) as days_ago
FROM daily_stock_prices
WHERE ROW_NUMBER() OVER (PARTITION BY ticker ORDER BY trading_date DESC) <= 30
ORDER BY ticker, trading_date DESC;

-- Compare week-over-week prices
SELECT
    ticker,
    WEEK(trading_date) as week,
    MIN(close_price) as week_low,
    MAX(close_price) as week_high,
    AVG(close_price) as week_avg
FROM daily_stock_prices
GROUP BY ticker, WEEK(trading_date)
ORDER BY ticker, WEEK(trading_date) DESC
LIMIT 50;

-- Monthly summary
SELECT
    ticker,
    YEAR(trading_date) as year,
    MONTH(trading_date) as month,
    COUNT(*) as trading_days,
    ROUND(MIN(low_price), 2) as month_low,
    ROUND(MAX(high_price), 2) as month_high,
    ROUND(AVG(close_price), 2) as month_avg,
    ROUND(SUM(volume), 0) as total_volume
FROM daily_stock_prices
GROUP BY ticker, YEAR(trading_date), MONTH(trading_date)
ORDER BY ticker, year DESC, month DESC;


-- ============================================================================
-- 7. CORRELATION & COMPARISON
-- ============================================================================

-- Compare price levels across tickers on same date
SELECT
    trading_date,
    GROUP_CONCAT(CONCAT(ticker, ':', ROUND(close_price, 2)) SEPARATOR ' | ') as prices_by_ticker
FROM daily_stock_prices
GROUP BY trading_date
ORDER BY trading_date DESC
LIMIT 30;

-- Price leaders and laggards (by percent change from date start)
WITH first_day AS (
    SELECT
        ticker,
        MIN(trading_date) as first_date,
        MAX(CASE WHEN trading_date = MIN(trading_date) THEN close_price END) as first_close
    FROM daily_stock_prices
    GROUP BY ticker
),
last_day AS (
    SELECT
        ticker,
        MAX(trading_date) as last_date,
        MAX(CASE WHEN trading_date = MAX(trading_date) THEN close_price END) as last_close
    FROM daily_stock_prices
    GROUP BY ticker
)
SELECT
    f.ticker,
    f.first_close,
    l.last_close,
    ROUND((l.last_close - f.first_close), 2) as price_change,
    ROUND((l.last_close - f.first_close) / f.first_close * 100, 2) as percent_change
FROM first_day f
JOIN last_day l ON f.ticker = l.ticker
ORDER BY percent_change DESC;


-- ============================================================================
-- 8. OUTLIER DETECTION
-- ============================================================================

-- Find unusual price movements (> 2 standard deviations)
SELECT
    dp.trading_date,
    dp.ticker,
    dp.close_price,
    ROUND(stats.avg_price, 2) as avg_price,
    ROUND(stats.std_dev, 2) as std_dev,
    ROUND((dp.close_price - stats.avg_price) / stats.std_dev, 2) as std_deviations
FROM daily_stock_prices dp
JOIN (
    SELECT
        ticker,
        AVG(close_price) as avg_price,
        STDDEV(close_price) as std_dev
    FROM daily_stock_prices
    GROUP BY ticker
) stats ON dp.ticker = stats.ticker
WHERE ABS((dp.close_price - stats.avg_price) / stats.std_dev) > 2
ORDER BY ABS((dp.close_price - stats.avg_price) / stats.std_dev) DESC
LIMIT 30;

-- Find unusual volume days
SELECT
    dp.trading_date,
    dp.ticker,
    dp.volume,
    ROUND(vol_stats.avg_vol, 0) as avg_volume,
    ROUND(vol_stats.std_dev, 0) as std_dev,
    ROUND(ABS(dp.volume - vol_stats.avg_vol) / vol_stats.std_dev, 2) as std_deviations
FROM daily_stock_prices dp
JOIN (
    SELECT
        ticker,
        AVG(volume) as avg_vol,
        STDDEV(volume) as std_dev
    FROM daily_stock_prices
    GROUP BY ticker
) vol_stats ON dp.ticker = vol_stats.ticker
WHERE ABS(dp.volume - vol_stats.avg_vol) / vol_stats.std_dev > 2
ORDER BY ABS(dp.volume - vol_stats.avg_vol) / vol_stats.std_dev DESC
LIMIT 30;


-- ============================================================================
-- 9. TRADING METRICS
-- ============================================================================

-- Calculate trading range and volume efficiency
SELECT
    trading_date,
    ticker,
    close_price,
    (high_price - low_price) as intraday_range,
    ROUND((high_price - low_price) / close_price * 100, 2) as range_percent,
    volume,
    ROUND(volume / (high_price - low_price + 0.01), 2) as volume_per_price_range
FROM daily_stock_prices
ORDER BY volume_per_price_range DESC
LIMIT 30;

-- Price efficiency ratio (trend strength)
SELECT
    ticker,
    COUNT(*) as trading_days,
    SUM(ABS(close_price - LAG(close_price) OVER (PARTITION BY ticker ORDER BY trading_date))) as total_movement,
    ABS(MAX(close_price) - MIN(close_price)) as net_change,
    ROUND(ABS(MAX(close_price) - MIN(close_price)) / 
          SUM(ABS(close_price - LAG(close_price) OVER (PARTITION BY ticker ORDER BY trading_date))) * 100, 2) as efficiency_ratio
FROM daily_stock_prices
GROUP BY ticker;


-- ============================================================================
-- 10. PERFORMANCE METRICS
-- ============================================================================

-- Return analysis (best performing days)
SELECT
    ticker,
    trading_date,
    close_price,
    LAG(close_price) OVER (PARTITION BY ticker ORDER BY trading_date) as previous_close,
    ROUND((close_price - LAG(close_price) OVER (PARTITION BY ticker ORDER BY trading_date)) /
          LAG(close_price) OVER (PARTITION BY ticker ORDER BY trading_date) * 100, 2) as daily_return
FROM daily_stock_prices
WHERE LAG(close_price) OVER (PARTITION BY ticker ORDER BY trading_date) IS NOT NULL
ORDER BY daily_return DESC
LIMIT 30;

-- Cumulative performance by ticker (from earliest to latest date)
SELECT
    ticker,
    COUNT(*) as days_data,
    ROUND(MIN(close_price), 2) as lowest_close,
    ROUND(MAX(close_price), 2) as highest_close,
    ROUND(MAX(close_price) - MIN(close_price), 2) as total_movement,
    ROUND((MAX(close_price) - MIN(close_price)) / MIN(close_price) * 100, 2) as total_return_percent
FROM daily_stock_prices
GROUP BY ticker
ORDER BY total_return_percent DESC;


-- ============================================================================
-- 11. QUICK INSIGHTS
-- ============================================================================

-- Recent price momentum (last 10 days vs previous 10 days average)
SELECT
    ticker,
    ROUND(AVG(CASE WHEN ROW_NUMBER() OVER (PARTITION BY ticker ORDER BY trading_date DESC) <= 10 
                   THEN close_price END), 2) as recent_10day_avg,
    ROUND(AVG(CASE WHEN ROW_NUMBER() OVER (PARTITION BY ticker ORDER BY trading_date DESC) BETWEEN 11 AND 20
                   THEN close_price END), 2) as previous_10day_avg
FROM daily_stock_prices
GROUP BY ticker;

-- Current status (latest price vs 52-week high/low)
SELECT
    ticker,
    MAX(CASE WHEN ROW_NUMBER() OVER (PARTITION BY ticker ORDER BY trading_date DESC) = 1
             THEN close_price END) as current_price,
    MAX(close_price) as year_high,
    MIN(close_price) as year_low,
    ROUND(((MAX(CASE WHEN ROW_NUMBER() OVER (PARTITION BY ticker ORDER BY trading_date DESC) = 1
                     THEN close_price END) - MIN(close_price)) /
           (MAX(close_price) - MIN(close_price)) * 100), 2) as price_percentile
FROM daily_stock_prices
GROUP BY ticker;

-- ============================================================================
-- TIPS:
-- 1. Use LIMIT when running exploratory queries
-- 2. Run summary queries first to understand data scope
-- 3. Use these as templates for your own analysis
-- 4. Combine queries to answer specific business questions
-- 5. Consider indexing on ticker and trading_date for performance
-- ============================================================================
