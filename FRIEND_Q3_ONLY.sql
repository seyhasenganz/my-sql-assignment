USE portfolio_db;

SELECT
    si.ticker,
    si.security_name,
    si.asset_class,
    si.current_percent,
    ROUND(100 * (MAX(dp.close_price) - MIN(dp.close_price)) / AVG(dp.close_price), 2) as volatility_6m_pct,
    ROUND(MAX(dp.close_price) - MIN(dp.close_price), 2) as price_range,
    ROUND(AVG(dp.close_price), 2) as avg_price,
    ROUND(MIN(dp.close_price), 2) as min_price,
    ROUND(MAX(dp.close_price), 2) as max_price,
    COUNT(DISTINCT dp.trading_date) as num_days
FROM daily_stock_prices dp
JOIN security_info si ON dp.ticker = si.ticker
WHERE dp.trading_date >= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
GROUP BY si.ticker, si.security_name, si.asset_class, si.current_percent
ORDER BY volatility_6m_pct DESC;

