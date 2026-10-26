-- =====================================================================
-- 01_SETUP_AND_LOAD.sql
-- Maven Fuzzy Factory (toy-store e-commerce) -> Snowflake
-- Run as ACCOUNTADMIN in a Snowsight SQL worksheet, top to bottom.
-- Every object is fully qualified (DATABASE.SCHEMA.OBJECT) so nothing can
-- land in the default PUBLIC schema by accident.
-- =====================================================================

USE ROLE ACCOUNTADMIN;

-- ---------------------------------------------------------------------
-- 1. Compute: a small, cheap warehouse that switches itself off
--    X-SMALL = 1 credit/hour, billed per second, suspends after 60s idle
-- ---------------------------------------------------------------------
CREATE WAREHOUSE IF NOT EXISTS FUZZY_WH
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE;

USE WAREHOUSE FUZZY_WH;

-- ---------------------------------------------------------------------
-- 2. Storage: database + schema
-- ---------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS FUZZY_FACTORY_DB;
CREATE SCHEMA IF NOT EXISTS FUZZY_FACTORY_DB.ECOMMERCE;
USE SCHEMA FUZZY_FACTORY_DB.ECOMMERCE;

-- ---------------------------------------------------------------------
-- 3. File format: comma-separated, 1 header row, the text NULL = real NULL,
--    some timestamps are wrapped in double quotes
-- ---------------------------------------------------------------------
CREATE OR REPLACE FILE FORMAT FUZZY_FACTORY_DB.ECOMMERCE.CSV_FORMAT
  TYPE = CSV
  FIELD_DELIMITER = ','
  SKIP_HEADER = 1
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  NULL_IF = ('NULL', '')
  EMPTY_FIELD_AS_NULL = TRUE;

-- ---------------------------------------------------------------------
-- 4. Stage: a landing area for the CSV files
-- ---------------------------------------------------------------------
CREATE OR REPLACE STAGE FUZZY_FACTORY_DB.ECOMMERCE.RAW_STAGE
  FILE_FORMAT = FUZZY_FACTORY_DB.ECOMMERCE.CSV_FORMAT;

-- ---------------------------------------------------------------------
-- 5. Tables (6 tables, ~1.7M rows in total)
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE FUZZY_FACTORY_DB.ECOMMERCE.PRODUCTS (
  product_id      INTEGER PRIMARY KEY,
  created_at      TIMESTAMP_NTZ,
  product_name    VARCHAR(100)
);

CREATE OR REPLACE TABLE FUZZY_FACTORY_DB.ECOMMERCE.WEBSITE_SESSIONS (
  website_session_id  INTEGER PRIMARY KEY,
  created_at          TIMESTAMP_NTZ,
  user_id             INTEGER,
  is_repeat_session   INTEGER,
  utm_source          VARCHAR(50),
  utm_campaign        VARCHAR(50),
  utm_content         VARCHAR(50),
  device_type         VARCHAR(20),
  http_referer        VARCHAR(100)
);

CREATE OR REPLACE TABLE FUZZY_FACTORY_DB.ECOMMERCE.WEBSITE_PAGEVIEWS (
  website_pageview_id INTEGER PRIMARY KEY,
  created_at          TIMESTAMP_NTZ,
  website_session_id  INTEGER,
  pageview_url        VARCHAR(100)
);

CREATE OR REPLACE TABLE FUZZY_FACTORY_DB.ECOMMERCE.ORDERS (
  order_id            INTEGER PRIMARY KEY,
  created_at          TIMESTAMP_NTZ,
  website_session_id  INTEGER,
  user_id             INTEGER,
  primary_product_id  INTEGER,
  items_purchased     INTEGER,
  price_usd           NUMBER(10,2),
  cogs_usd            NUMBER(10,2)
);

CREATE OR REPLACE TABLE FUZZY_FACTORY_DB.ECOMMERCE.ORDER_ITEMS (
  order_item_id   INTEGER PRIMARY KEY,
  created_at      TIMESTAMP_NTZ,
  order_id        INTEGER,
  product_id      INTEGER,
  is_primary_item INTEGER,
  price_usd       NUMBER(10,2),
  cogs_usd        NUMBER(10,2)
);

CREATE OR REPLACE TABLE FUZZY_FACTORY_DB.ECOMMERCE.ORDER_ITEM_REFUNDS (
  order_item_refund_id INTEGER PRIMARY KEY,
  created_at           TIMESTAMP_NTZ,
  order_item_id        INTEGER,
  order_id             INTEGER,
  refund_amount_usd    NUMBER(10,2)
);

-- ---------------------------------------------------------------------
-- 6. UPLOAD THE FILES TO THE STAGE (manual step in Snowsight, not SQL)
--    Databases -> FUZZY_FACTORY_DB -> ECOMMERCE -> Stages -> RAW_STAGE
--    -> "+ Files" -> select these 6 CSVs -> Upload:
--      products.csv, website_sessions.csv, website_pageviews.csv,
--      orders.csv, order_items.csv, order_item_refunds.csv
--    (Skip maven_fuzzy_factory_data_dictionary.csv - it is documentation.)
-- ---------------------------------------------------------------------
LIST @FUZZY_FACTORY_DB.ECOMMERCE.RAW_STAGE;   -- should show the 6 files

-- ---------------------------------------------------------------------
-- 7. Load stage -> tables
-- ---------------------------------------------------------------------
COPY INTO FUZZY_FACTORY_DB.ECOMMERCE.PRODUCTS
  FROM @FUZZY_FACTORY_DB.ECOMMERCE.RAW_STAGE FILES = ('products.csv');
COPY INTO FUZZY_FACTORY_DB.ECOMMERCE.WEBSITE_SESSIONS
  FROM @FUZZY_FACTORY_DB.ECOMMERCE.RAW_STAGE FILES = ('website_sessions.csv');
COPY INTO FUZZY_FACTORY_DB.ECOMMERCE.WEBSITE_PAGEVIEWS
  FROM @FUZZY_FACTORY_DB.ECOMMERCE.RAW_STAGE FILES = ('website_pageviews.csv');
COPY INTO FUZZY_FACTORY_DB.ECOMMERCE.ORDERS
  FROM @FUZZY_FACTORY_DB.ECOMMERCE.RAW_STAGE FILES = ('orders.csv');
COPY INTO FUZZY_FACTORY_DB.ECOMMERCE.ORDER_ITEMS
  FROM @FUZZY_FACTORY_DB.ECOMMERCE.RAW_STAGE FILES = ('order_items.csv');
COPY INTO FUZZY_FACTORY_DB.ECOMMERCE.ORDER_ITEM_REFUNDS
  FROM @FUZZY_FACTORY_DB.ECOMMERCE.RAW_STAGE FILES = ('order_item_refunds.csv');

-- ---------------------------------------------------------------------
-- 8. Check row counts. Expected:
--    PRODUCTS 4 | WEBSITE_SESSIONS 472,871 | WEBSITE_PAGEVIEWS 1,188,124
--    ORDERS 32,313 | ORDER_ITEMS 40,025 | ORDER_ITEM_REFUNDS 1,731
-- ---------------------------------------------------------------------
SELECT 'PRODUCTS' AS table_name, COUNT(*) AS row_count FROM FUZZY_FACTORY_DB.ECOMMERCE.PRODUCTS
UNION ALL SELECT 'WEBSITE_SESSIONS',   COUNT(*) FROM FUZZY_FACTORY_DB.ECOMMERCE.WEBSITE_SESSIONS
UNION ALL SELECT 'WEBSITE_PAGEVIEWS',  COUNT(*) FROM FUZZY_FACTORY_DB.ECOMMERCE.WEBSITE_PAGEVIEWS
UNION ALL SELECT 'ORDERS',             COUNT(*) FROM FUZZY_FACTORY_DB.ECOMMERCE.ORDERS
UNION ALL SELECT 'ORDER_ITEMS',        COUNT(*) FROM FUZZY_FACTORY_DB.ECOMMERCE.ORDER_ITEMS
UNION ALL SELECT 'ORDER_ITEM_REFUNDS', COUNT(*) FROM FUZZY_FACTORY_DB.ECOMMERCE.ORDER_ITEM_REFUNDS;
