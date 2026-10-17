-- =====================================================================
-- SUBMISSION QUERY - Maven Fuzzy Factory (online teddy-bear retailer)
--
-- BUSINESS QUESTION:
--   Which marketing channels bring in the most revenue, and which ones turn
--   website visits into orders most efficiently?
--
-- WHAT IT DOES:
--   1. Classifies every website session (Mar-2012 to Mar-2015, ~473k sessions)
--      into a marketing channel using its UTM tags and HTTP referer:
--        - no UTM + no referer   -> Direct type-in (user typed the URL)
--        - no UTM + referer      -> Organic search (free search traffic)
--        - socialbook            -> Paid social
--        - everything else       -> Paid search, split by brand/nonbrand + engine
--   2. Joins sessions to orders and refunds.
--   3. Per channel: sessions, orders, conversion rate, revenue,
--      revenue per session, net margin after product cost and refunds,
--      and share of total revenue.
--
-- INSIGHT IT PRODUCES:
--   Paid nonbrand gsearch drives the most revenue (~58%) but converts below
--   average, so the business is heavily dependent on one paid channel.
--   Brand search, organic search and direct type-in convert better and earn
--   more per session at no or low ad cost - growing these reduces risk.
--   Paid social converts worst (~3%) and is a candidate for budget cuts.
-- =====================================================================

USE ROLE FUZZY_READER;
USE WAREHOUSE FUZZY_WH;

WITH session_channels AS (
    SELECT
        website_session_id,
        CASE
            WHEN utm_source IS NULL AND http_referer IS NULL THEN 'Direct type-in'
            WHEN utm_source IS NULL                          THEN 'Organic search'
            WHEN utm_source = 'socialbook'                   THEN 'Paid social (socialbook)'
            ELSE 'Paid ' || utm_campaign || ' search (' || utm_source || ')'
        END AS channel
    FROM FUZZY_FACTORY_DB.ECOMMERCE.WEBSITE_SESSIONS
),
order_refunds AS (
    SELECT order_id, SUM(refund_amount_usd) AS refund_usd
    FROM FUZZY_FACTORY_DB.ECOMMERCE.ORDER_ITEM_REFUNDS
    GROUP BY order_id
)
SELECT
    s.channel,
    COUNT(*)                                                    AS sessions,
    COUNT(o.order_id)                                           AS orders,
    ROUND(100.0 * COUNT(o.order_id) / COUNT(*), 2)              AS conversion_rate_pct,
    ROUND(SUM(o.price_usd), 0)                                  AS revenue_usd,
    ROUND(SUM(o.price_usd) / COUNT(*), 2)                       AS revenue_per_session_usd,
    ROUND(SUM(o.price_usd - o.cogs_usd - COALESCE(r.refund_usd, 0)), 0)
                                                                AS net_margin_usd,
    ROUND(100.0 * SUM(o.price_usd) / SUM(SUM(o.price_usd)) OVER (), 1)
                                                                AS share_of_revenue_pct
FROM session_channels s
LEFT JOIN FUZZY_FACTORY_DB.ECOMMERCE.ORDERS o
       ON o.website_session_id = s.website_session_id
LEFT JOIN order_refunds r
       ON r.order_id = o.order_id
GROUP BY s.channel
ORDER BY revenue_usd DESC;
