USE portfolio_db;

SELECT
    si.ticker,
    si.security_name,
    si.current_percent,
    ROUND(100 * (
        (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker ORDER BY trading_date DESC LIMIT 1)
        - 
        (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker 
         AND trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
         ORDER BY trading_date DESC LIMIT 1)
    ) / (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker 
         AND trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
         ORDER BY trading_date DESC LIMIT 1), 2) as return_6m_pct,
    CASE
        WHEN ROUND(100 * (
            (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker ORDER BY trading_date DESC LIMIT 1)
            - 
            (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker 
             AND trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
             ORDER BY trading_date DESC LIMIT 1)
        ) / (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker 
             AND trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
             ORDER BY trading_date DESC LIMIT 1), 2) > 10 THEN 'BUY - STRONG PERFORMER'
        WHEN ROUND(100 * (
            (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker ORDER BY trading_date DESC LIMIT 1)
            - 
            (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker 
             AND trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
             ORDER BY trading_date DESC LIMIT 1)
        ) / (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker 
             AND trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
             ORDER BY trading_date DESC LIMIT 1), 2) BETWEEN 5 AND 10 THEN 'HOLD - GOOD'
        WHEN ROUND(100 * (
            (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker ORDER BY trading_date DESC LIMIT 1)
            - 
            (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker 
             AND trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
             ORDER BY trading_date DESC LIMIT 1)
        ) / (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker 
             AND trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
             ORDER BY trading_date DESC LIMIT 1), 2) BETWEEN 0 AND 5 THEN 'HOLD - STABLE'
        WHEN ROUND(100 * (
            (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker ORDER BY trading_date DESC LIMIT 1)
            - 
            (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker 
             AND trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
             ORDER BY trading_date DESC LIMIT 1)
        ) / (SELECT close_price FROM daily_stock_prices WHERE ticker = si.ticker 
             AND trading_date <= DATE_SUB((SELECT MAX(trading_date) FROM daily_stock_prices), INTERVAL 180 DAY)
             ORDER BY trading_date DESC LIMIT 1), 2) < 0 THEN 'SELL - UNDERPERFORMER'
        ELSE 'REVIEW'
    END as recommendation
FROM security_info si
ORDER BY si.current_percent DESC;

