-- =====================================================================
-- 12_PRESENTATION_QUERIES.sql – two short queries to run live in videos
-- Run as SSENG or as the external user (read-only role works).
-- =====================================================================

USE WAREHOUSE FUZZY_WH;

-- QUERY 1: Which product sells the most, and which one gets returned the most?
-- Expected: Original Mr. Fuzzy 24,226 items / $1,211,058 / 5.1% refunds;
--           Birthday Sugar Panda highest refund rate (6.0%); Hudson River Mini bear lowest (1.3%).
SELECT p.product_name,
       COUNT(oi.order_item_id)                                                    AS items_sold,
       ROUND(SUM(oi.price_usd), 0)                                                AS revenue_usd,
       ROUND(COUNT(r.order_item_refund_id) * 100.0 / COUNT(oi.order_item_id), 1)  AS refund_rate_pct
FROM FUZZY_FACTORY_DB.ECOMMERCE.ORDER_ITEMS oi
JOIN FUZZY_FACTORY_DB.ECOMMERCE.PRODUCTS p                ON p.product_id = oi.product_id
LEFT JOIN FUZZY_FACTORY_DB.ECOMMERCE.ORDER_ITEM_REFUNDS r ON r.order_item_id = oi.order_item_id
GROUP BY p.product_name
ORDER BY revenue_usd DESC;

-- QUERY 2: Do visitors buy more on desktop or on mobile?
-- Expected: desktop 327,027 visits / 27,805 orders / 8.50%;
--           mobile 145,844 visits / 4,508 orders / 3.09%.
SELECT s.device_type,
       COUNT(s.website_session_id)                                        AS visits,
       COUNT(o.order_id)                                                  AS orders,
       ROUND(COUNT(o.order_id) * 100.0 / COUNT(s.website_session_id), 2)  AS conversion_rate_pct
FROM FUZZY_FACTORY_DB.ECOMMERCE.WEBSITE_SESSIONS s
LEFT JOIN FUZZY_FACTORY_DB.ECOMMERCE.ORDERS o ON o.website_session_id = s.website_session_id
GROUP BY s.device_type
ORDER BY conversion_rate_pct DESC;
