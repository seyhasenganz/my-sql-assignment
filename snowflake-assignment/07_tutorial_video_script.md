# Tutorial Video Script – "Give someone access to your Snowflake data in 2 minutes"

Target length: **~2:00** (rubric says 1–2 min, instructions say 2–3 min → 2:00 satisfies both).
Narration ≈ 270 words at a calm pace.

## Before you hit record
1. **Window 1 (normal):** logged in as **SSENG**, new SQL file containing the DEMO SQL below.
2. **Window 2 (incognito):** open at `https://jdkuhsr-qk22783.snowflakecomputing.com` (login page).
3. Phone with authenticator app ready (for MFA).
4. Close other tabs/notifications; zoom browser to 125% so code is readable.
5. Record: Windows **Win + Shift + R** (Snipping Tool) or Xbox Game Bar **Win + G**, with microphone on.

We create a **fresh user (DEMO_VIEWER)** on camera so the MFA enrolment screen appears live.
(EXT_TEST_USER and the instructor users already exist – mention them at the end.)

### DEMO SQL (paste in Window 1 before recording)
```sql
USE ROLE ACCOUNTADMIN;

-- Step 1: a read-only role and what it may use
CREATE ROLE IF NOT EXISTS FUZZY_READER;
GRANT USAGE  ON WAREHOUSE FUZZY_WH                              TO ROLE FUZZY_READER;
GRANT USAGE  ON DATABASE  FUZZY_FACTORY_DB                      TO ROLE FUZZY_READER;
GRANT USAGE  ON SCHEMA    FUZZY_FACTORY_DB.ECOMMERCE            TO ROLE FUZZY_READER;
GRANT SELECT ON ALL TABLES IN SCHEMA FUZZY_FACTORY_DB.ECOMMERCE TO ROLE FUZZY_READER;

-- Step 2: the external user
CREATE USER DEMO_VIEWER
  PASSWORD = '<your password>'   -- type your real password here in Snowflake only
  EMAIL = 'seyhasenganz@gmail.com'
  TYPE = PERSON
  DEFAULT_ROLE = FUZZY_READER
  DEFAULT_WAREHOUSE = FUZZY_WH
  DEFAULT_NAMESPACE = 'FUZZY_FACTORY_DB.ECOMMERCE'
  MUST_CHANGE_PASSWORD = FALSE;

-- Step 3: give the role to the user and require MFA
GRANT ROLE FUZZY_READER TO USER DEMO_VIEWER;
ALTER USER DEMO_VIEWER SET AUTHENTICATION POLICY FUZZY_FACTORY_DB.ECOMMERCE.REQUIRE_MFA;
```
(The role and grants already exist – re-running them is harmless and shows the steps on camera.)

---

## Script

| Time | On screen | Say |
|---|---|---|
| 0:00–0:15 | Snowflake home as SSENG | "Hi, I'm Seyha. In two minutes I'll show you how to give someone outside your company secure, read-only access to data in Snowflake – even if you've never opened Snowflake before." |
| 0:15–0:30 | Database Explorer: FUZZY_FACTORY_DB → ECOMMERCE → 6 tables | "Here's my data: an online toy store with 1.7 million rows across six tables – website sessions, orders and refunds." |
| 0:30–0:55 | Highlight Step 1 lines, run them | "Snowflake never gives permissions directly to people. You give them to a **role**, then give the role to people. My role, FUZZY_READER, may use one small warehouse to run queries, see this database and schema, and only **SELECT** from the tables – no changes allowed." |
| 0:55–1:15 | Highlight Step 2, run it | "Now the user. TYPE equals PERSON tells Snowflake this is a human – so multi-factor authentication will be required. I set a default role, warehouse and schema so the user lands in the right place." |
| 1:15–1:25 | Highlight Step 3, run it | "Last step: grant the role to the user, and attach an authentication policy that makes MFA enrolment required. That's it – three steps." |
| 1:25–1:45 | Incognito window: log in as DEMO_VIEWER → MFA setup → scan QR → enter code | "Let's test it as the new user. Because Snowflake no longer allows password-only sign-in, the user must enrol in MFA on the first login – I scan this QR code with my authenticator app and enter the code." |
| 1:45–1:55 | Run `SELECT COUNT(*) FROM FUZZY_FACTORY_DB.ECOMMERCE.ORDERS;` → 32,313 | "The user can query the data – 32,313 orders." |
| 1:55–2:05 | Run `DELETE FROM FUZZY_FACTORY_DB.ECOMMERCE.PRODUCTS;` → insufficient privileges | "But if they try to delete anything – access denied. Read-only, exactly as designed." |
| 2:05–2:15 | Back to Window 1, `SHOW USERS;` showing EXT_TEST_USER, LESCAMILLA, ECALICIBETE | "I used the same steps for my external test user and both instructors. Role, user, grant, MFA – that's secure access in Snowflake. Thanks for watching!" |

## After recording
1. Watch it once – check voice is clear and code readable.
2. Upload to **YouTube → Unlisted** (not Private), title: *"Snowflake Tutorial: Create External Users & Grant Read-Only Access (with MFA)"*.
3. Captions start processing automatically – check back later in YouTube Studio → Subtitles.
4. Optional cleanup after upload: `DROP USER DEMO_VIEWER;` (keep EXT_TEST_USER and the instructor users!).
