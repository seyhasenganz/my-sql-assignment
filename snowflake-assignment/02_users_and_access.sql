-- =====================================================================
-- 02_USERS_AND_ACCESS.sql
-- Read-only role + external user + 2 instructor users
-- Run as ACCOUNTADMIN after 01_setup_and_load.sql.
--
-- Idea in one line:  permissions -> ROLE -> USER
--   (grant what may be used to a role, then give the role to people)
-- =====================================================================

USE ROLE ACCOUNTADMIN;

-- ---------------------------------------------------------------------
-- 1. A read-only role for anyone who should query the data
-- ---------------------------------------------------------------------
CREATE ROLE IF NOT EXISTS FUZZY_READER
  COMMENT = 'Read-only access to FUZZY_FACTORY_DB.ECOMMERCE';

-- The role needs every layer: warehouse (to run queries) -> database -> schema -> tables
GRANT USAGE  ON WAREHOUSE FUZZY_WH                               TO ROLE FUZZY_READER;
GRANT USAGE  ON DATABASE  FUZZY_FACTORY_DB                       TO ROLE FUZZY_READER;
GRANT USAGE  ON SCHEMA    FUZZY_FACTORY_DB.ECOMMERCE             TO ROLE FUZZY_READER;
GRANT SELECT ON ALL TABLES    IN SCHEMA FUZZY_FACTORY_DB.ECOMMERCE TO ROLE FUZZY_READER;
GRANT SELECT ON FUTURE TABLES IN SCHEMA FUZZY_FACTORY_DB.ECOMMERCE TO ROLE FUZZY_READER;

-- Let ACCOUNTADMIN also use the role (handy for testing)
GRANT ROLE FUZZY_READER TO ROLE SYSADMIN;

-- ---------------------------------------------------------------------
-- 2. Users
--    TYPE = PERSON          -> a human login; Snowflake requires MFA for
--                              password sign-in, so each person is asked to
--                              enrol MFA (authenticator app / passkey) at
--                              their FIRST login. You cannot enrol it for them.
--    MUST_CHANGE_PASSWORD   -> FALSE so the password you hand over keeps working
--    DEFAULT_*              -> user lands directly in the right role/warehouse/schema
--
--    >>> Replace every password below with your own strong password (14+ chars,
--        upper, lower, digit, symbol) and the personal email with yours. <<<
-- ---------------------------------------------------------------------

-- 2a. External test user (your personal, non-Hult email)
CREATE USER IF NOT EXISTS EXT_TEST_USER
  LOGIN_NAME        = 'EXT_TEST_USER'
  DISPLAY_NAME      = 'External Test User'
  EMAIL             = 'your.personal.email@gmail.com'
  PASSWORD          = 'Replace-Me-Ext-2026!'
  MUST_CHANGE_PASSWORD = FALSE
  TYPE              = PERSON
  DEFAULT_ROLE      = FUZZY_READER
  DEFAULT_WAREHOUSE = FUZZY_WH
  DEFAULT_NAMESPACE = 'FUZZY_FACTORY_DB.ECOMMERCE';

-- 2b. Instructor 1
CREATE USER IF NOT EXISTS LESCAMILLA
  LOGIN_NAME        = 'LESCAMILLA'
  DISPLAY_NAME      = 'Luis Escamilla'
  EMAIL             = 'luis.escamilla@faculty.hult.edu'
  PASSWORD          = 'Replace-Me-Luis-2026!'
  MUST_CHANGE_PASSWORD = FALSE
  TYPE              = PERSON
  DEFAULT_ROLE      = FUZZY_READER
  DEFAULT_WAREHOUSE = FUZZY_WH
  DEFAULT_NAMESPACE = 'FUZZY_FACTORY_DB.ECOMMERCE';

-- 2c. Instructor 2
CREATE USER IF NOT EXISTS ECALICIBETE
  LOGIN_NAME        = 'ECALICIBETE'
  DISPLAY_NAME      = 'E. Calicibete'
  EMAIL             = 'ecalicibete@ef.com'
  PASSWORD          = 'Replace-Me-Eca-2026!'
  MUST_CHANGE_PASSWORD = FALSE
  TYPE              = PERSON
  DEFAULT_ROLE      = FUZZY_READER
  DEFAULT_WAREHOUSE = FUZZY_WH
  DEFAULT_NAMESPACE = 'FUZZY_FACTORY_DB.ECOMMERCE';

-- ---------------------------------------------------------------------
-- 3. Give the role to the users
-- ---------------------------------------------------------------------
GRANT ROLE FUZZY_READER TO USER EXT_TEST_USER;
GRANT ROLE FUZZY_READER TO USER LESCAMILLA;
GRANT ROLE FUZZY_READER TO USER ECALICIBETE;

-- ---------------------------------------------------------------------
-- 4. Verify (screenshot these for the document / video)
-- ---------------------------------------------------------------------
SHOW GRANTS TO ROLE FUZZY_READER;
SHOW GRANTS OF ROLE FUZZY_READER;
SHOW USERS LIKE '%';

-- ---------------------------------------------------------------------
-- 5. Test as the external user (manual):
--    a) Open an incognito/private browser window -> your Snowflake login URL
--    b) Sign in as EXT_TEST_USER -> enrol MFA when prompted
--    c) Run:  SELECT COUNT(*) FROM FUZZY_FACTORY_DB.ECOMMERCE.ORDERS;   -- 32313
--    d) Prove read-only: this must FAIL with "insufficient privileges":
--       DELETE FROM FUZZY_FACTORY_DB.ECOMMERCE.PRODUCTS;
-- ---------------------------------------------------------------------

-- Find your account identifier for the Word document:
SELECT CURRENT_ORGANIZATION_NAME() || '-' || CURRENT_ACCOUNT_NAME() AS account_identifier,
       CURRENT_ACCOUNT()                                            AS account_locator;
