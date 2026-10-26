-- =====================================================================
-- SUBMISSION QUERY - Maven Fuzzy Factory (online teddy-bear store)
--
-- QUESTION: Which marketing channels bring in the most revenue,
--           and which ones turn website visits into orders best?
--
-- INSIGHT:  One paid channel (nonbrand gsearch) brings 58% of all revenue,
--           so the business depends heavily on it. Brand search, organic
--           search and direct visits convert better at little or no ad cost.
--           Paid social converts worst (3.2%) - a candidate for budget cuts.
-- =====================================================================

USE ROLE FUZZY_READER;
USE WAREHOUSE FUZZY_WH;
USE SCHEMA FUZZY_FACTORY_DB.ECOMMERCE;

-- Step 1: give every website visit (session) a marketing channel name
WITH visits AS (
    SELECT
        website_session_id,
        CASE
            WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN 'Paid nonbrand search (gsearch)'
            WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN 'Paid nonbrand search (bsearch)'
            WHEN utm_source = 'gsearch' AND utm_campaign = 'brand'    THEN 'Paid brand search (gsearch)'
            WHEN utm_source = 'bsearch' AND utm_campaign = 'brand'    THEN 'Paid brand search (bsearch)'
            WHEN utm_source = 'socialbook'                            THEN 'Paid social (socialbook)'
            WHEN utm_source IS NULL AND http_referer IS NOT NULL      THEN 'Organic search'
            ELSE 'Direct type-in'   -- no ad tag and no referring website
        END AS channel
    FROM website_sessions
),

-- Step 2: total refund for each order
refunds AS (
    SELECT order_id, SUM(refund_amount_usd) AS refund_usd
    FROM order_item_refunds
    GROUP BY order_id
)

-- Step 3: results per channel
SELECT
    v.channel,
    COUNT(v.website_session_id)                                         AS sessions,
    COUNT(o.order_id)                                                   AS orders,
    ROUND(COUNT(o.order_id) * 100.0 / COUNT(v.website_session_id), 2)   AS conversion_rate_pct,
    ROUND(SUM(o.price_usd), 0)                                          AS revenue_usd,
    ROUND(SUM(o.price_usd) / COUNT(v.website_session_id), 2)            AS revenue_per_session_usd,
    ROUND(SUM(o.price_usd - o.cogs_usd - IFNULL(r.refund_usd, 0)), 0)   AS net_margin_usd,  -- revenue - product cost - refunds
    ROUND(SUM(o.price_usd) * 100.0 / (SELECT SUM(price_usd) FROM orders), 1) AS share_of_revenue_pct
FROM visits v
LEFT JOIN orders  o ON o.website_session_id = v.website_session_id   -- visits without an order are kept
LEFT JOIN refunds r ON r.order_id = o.order_id
GROUP BY v.channel
ORDER BY revenue_usd DESC;
