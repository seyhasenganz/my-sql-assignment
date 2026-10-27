# Tutorial Video Script – "Snowflake for Beginners: Load Data and Share It Safely"

Target length: **about 2:30** (instructions: 2–3 min; rubric: 1–2 min → keep it tight).
Style: friendly, simple, like showing a friend. ≈ 360 spoken words.
Flow: **the data → how it got in → who can see it (users, roles, MFA) → live test**.

**The big idea (one picture to remember):** Snowflake works like an office building.
- A **role** is a **key card** – it says which doors open.
- A **user** is a **person**.
- You give the person the key card.
- **MFA** is the extra code from their phone, so a stolen password is not enough.

---

## Before you hit record – prepare these tabs
1. **Slide / image:** the "Data loaded" table (6 tables, 1,735,068 rows, 19 MB) – screenshot from `06_poc_measurements.md`.
2. **Window 1 (normal, SSENG):**
   - Tab A: `01_setup_and_load.sql` worksheet, scrolled to the `COPY INTO` lines.
   - Tab B: Databases → FUZZY_FACTORY_DB → ECOMMERCE → **Stages → RAW_STAGE** (shows the 6 files).
   - Tab C: new SQL file with the **ACCESS SQL** below pasted in.
3. **Window 2 (incognito):** open at `https://jdkuhsr-qk22783.snowflakecomputing.com`.
4. Phone with **Google or Microsoft Authenticator** ready.
5. Browser zoom **125%**, other tabs and notifications closed. Record with **Win + Shift + R**, microphone on (camera in a corner = more engaging).

**Do not re-upload or re-run COPY INTO on camera** – the data is already loaded, so it would just skip the files. *Show* the stage, the COPY lines and the row count instead.

### Row-count query (keep ready in Tab A)
```sql
SELECT 'ORDERS' AS table_name, COUNT(*) AS row_count FROM FUZZY_FACTORY_DB.ECOMMERCE.ORDERS
UNION ALL SELECT 'WEBSITE_SESSIONS', COUNT(*) FROM FUZZY_FACTORY_DB.ECOMMERCE.WEBSITE_SESSIONS
UNION ALL SELECT 'WEBSITE_PAGEVIEWS', COUNT(*) FROM FUZZY_FACTORY_DB.ECOMMERCE.WEBSITE_PAGEVIEWS;
```

### ACCESS SQL (paste in Tab C before recording)
```sql
USE ROLE ACCOUNTADMIN;

-- STEP 1: make the key card (a role) and choose which doors it opens
CREATE ROLE IF NOT EXISTS FUZZY_READER;
GRANT USAGE  ON WAREHOUSE FUZZY_WH                              TO ROLE FUZZY_READER;
GRANT USAGE  ON DATABASE  FUZZY_FACTORY_DB                      TO ROLE FUZZY_READER;
GRANT USAGE  ON SCHEMA    FUZZY_FACTORY_DB.ECOMMERCE            TO ROLE FUZZY_READER;
GRANT SELECT ON ALL TABLES IN SCHEMA FUZZY_FACTORY_DB.ECOMMERCE TO ROLE FUZZY_READER;

-- STEP 2: create the person (the user)
CREATE USER DEMO_VIEWER
  PASSWORD = '<your password>'          -- type your real password here in Snowflake only
  EMAIL = 'seyhasenganz@gmail.com'
  TYPE = PERSON
  DEFAULT_ROLE = FUZZY_READER
  DEFAULT_WAREHOUSE = FUZZY_WH
  DEFAULT_NAMESPACE = 'FUZZY_FACTORY_DB.ECOMMERCE'
  MUST_CHANGE_PASSWORD = FALSE;

-- STEP 3: hand over the key card, and require MFA
GRANT ROLE FUZZY_READER TO USER DEMO_VIEWER;
ALTER USER DEMO_VIEWER SET AUTHENTICATION POLICY FUZZY_FACTORY_DB.ECOMMERCE.REQUIRE_MFA;
```
(The role, grants and MFA policy already exist – re-running them is harmless and shows each step on camera.)

---

## Script

| Time | On screen | Say |
|---|---|---|
| **0:00–0:10** Hook | Snowflake home as SSENG | “Want to put your data in the cloud and let someone look at it – without letting them change anything? Let me show you how in Snowflake, step by step.” |
| **0:10–0:25** The data | "Data loaded" table, then Database Explorer showing the 6 tables | “Here’s my data: an online toy store. Six tables, 1.7 million rows – website visits, orders and refunds. In Snowflake it takes only 19 megabytes.” |
| **0:25–0:55** How it got in | Tab B: RAW_STAGE with 6 files → Tab A: COPY INTO lines → run row-count query | “How did it get in? Two simple moves. First, I uploaded my six CSV files into a **stage** – think of it as a waiting room for files. Then one command, **COPY INTO**, moves each file into its table. Let’s check it worked… 32,313 orders, all there.” |
| **0:55–1:05** The idea | Tab C: ACCESS SQL | “Now, who can see this data? Think of Snowflake like an office building. A **role** is a key card. A **user** is a person. Three steps.” |
| **1:05–1:20** Step 1 | Highlight STEP 1 → Run | “Step one: make the key card. This role can use the computer that runs queries and open my tables – but only to **SELECT**. That means read only.” |
| **1:20–1:35** Step 2 | Highlight STEP 2 → Run | “Step two: create the person – a name, password and email. TYPE equals PERSON means a real human, and they land straight in the right data.” |
| **1:35–1:45** Step 3 | Highlight STEP 3 → Run | “Step three: hand over the key card – and turn on MFA, so a password alone isn’t enough.” |
| **1:45–2:05** Test: MFA | Incognito → log in as DEMO_VIEWER → **Set up MFA** → Authenticator → scan QR → enter code | “Let’s test it as the new user. Snowflake asks for MFA. I scan the code with my phone, type the six numbers… and I’m in.” |
| **2:05–2:15** Test: it works | Run `SELECT COUNT(*) FROM FUZZY_FACTORY_DB.ECOMMERCE.ORDERS;` → **32,313** | “Can they read the data? Yes – 32,313 orders.” |
| **2:15–2:25** Test: it’s safe | Run `DELETE FROM FUZZY_FACTORY_DB.ECOMMERCE.PRODUCTS;` → **Insufficient privileges** | “Can they delete something? Access denied. Read only, exactly as planned.” |
| **2:25–2:35** Wrap-up | Window 1 → `SHOW USERS;` (EXT_TEST_USER, LESCAMILLA, ECALICIBETE) | “I did the same for my test user and both instructors. Load the data, make the key card, hand it over, add MFA. Thanks for watching!” |

---

## Tips to make it engaging
- **Smile and keep a good pace** – energy matters more than perfection.
- Say the two pictures slowly: **stage = waiting room for files**, **role = key card**. Beginners remember these.
- Pause one second after each **Run**, so viewers see the result.
- Small mistake? Keep going – it looks natural.
- Running long? Shorten the "How it got in" part first; users and access are what this video is graded on.

## After recording
1. Watch it once – voice clear, code readable, under ~2:45.
2. Upload to **YouTube → Unlisted** (not Private). Title: *“Snowflake for Beginners: Load Data and Share It Safely (Users, Roles & MFA)”*.
3. Captions start processing automatically – check later in YouTube Studio → Subtitles.
4. Optional cleanup after upload: `DROP USER DEMO_VIEWER;` (keep EXT_TEST_USER and the instructor users!).
