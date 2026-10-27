# Tutorial Video Script – "Snowflake for Beginners: Load Data and Share It Safely"

Slides: https://claude.ai/artifact/TjcNk3FwiaWq9xkzJcA4Ak (4 slides; speaker notes match this script)
Target: **about 2:30** (instructions 2–3 min; rubric 1–2 min → keep it tight). Slides ≈ 35 s, live Snowflake demo ≈ 2 min.

---

## Before you hit record

**Open these, in this order:**
1. **Tab 1 – Slides** (present full screen).
2. **Tab 2 – Snowflake as SSENG**, with three worksheets ready:
   - **A:** `01_setup_and_load.sql`, scrolled to the `COPY INTO` lines, plus the table-overview query below.
   - **B:** Databases → FUZZY_FACTORY_DB → ECOMMERCE → **Stages → RAW_STAGE** (shows the 6 files).
   - **C:** new SQL file with the **ACCESS SQL** below.
3. **Window 2 – Incognito** at `https://jdkuhsr-qk22783.snowflakecomputing.com`.
4. **Phone** with Google or Microsoft Authenticator.
5. Browser zoom **125%**, notifications off. Record with **Win + Shift + R**, microphone on (camera in a corner = more engaging).

**Don’t re-upload files or re-run COPY INTO on camera** – the data is already loaded, Snowflake would skip the files. Just *show* them.

### Table-overview query (worksheet A)
```sql
WITH counts AS (
              SELECT 'PRODUCTS' AS table_name, COUNT(*) AS row_count FROM FUZZY_FACTORY_DB.ECOMMERCE.PRODUCTS
    UNION ALL SELECT 'WEBSITE_SESSIONS',   COUNT(*) FROM FUZZY_FACTORY_DB.ECOMMERCE.WEBSITE_SESSIONS
    UNION ALL SELECT 'WEBSITE_PAGEVIEWS',  COUNT(*) FROM FUZZY_FACTORY_DB.ECOMMERCE.WEBSITE_PAGEVIEWS
    UNION ALL SELECT 'ORDERS',             COUNT(*) FROM FUZZY_FACTORY_DB.ECOMMERCE.ORDERS
    UNION ALL SELECT 'ORDER_ITEMS',        COUNT(*) FROM FUZZY_FACTORY_DB.ECOMMERCE.ORDER_ITEMS
    UNION ALL SELECT 'ORDER_ITEM_REFUNDS', COUNT(*) FROM FUZZY_FACTORY_DB.ECOMMERCE.ORDER_ITEM_REFUNDS
)
SELECT table_name, row_count FROM counts
UNION ALL
SELECT 'TOTAL', SUM(row_count) FROM counts
ORDER BY row_count;
```
Expected: PRODUCTS 4 … WEBSITE_PAGEVIEWS 1,188,124, then TOTAL 1,735,068.

### ACCESS SQL (worksheet C)
```sql
USE ROLE ACCOUNTADMIN;

-- STEP 1: create a role = what the person may do (read my tables only)
CREATE ROLE IF NOT EXISTS FUZZY_READER;
GRANT USAGE  ON WAREHOUSE FUZZY_WH                              TO ROLE FUZZY_READER;
GRANT USAGE  ON DATABASE  FUZZY_FACTORY_DB                      TO ROLE FUZZY_READER;
GRANT USAGE  ON SCHEMA    FUZZY_FACTORY_DB.ECOMMERCE            TO ROLE FUZZY_READER;
GRANT SELECT ON ALL TABLES IN SCHEMA FUZZY_FACTORY_DB.ECOMMERCE TO ROLE FUZZY_READER;

-- STEP 2: create a user = the person
CREATE USER DEMO_VIEWER
  PASSWORD = '<your password>'          -- type your real password here in Snowflake only
  EMAIL = 'seyhasenganz@gmail.com'
  TYPE = PERSON
  DEFAULT_ROLE = FUZZY_READER
  DEFAULT_WAREHOUSE = FUZZY_WH
  DEFAULT_NAMESPACE = 'FUZZY_FACTORY_DB.ECOMMERCE'
  MUST_CHANGE_PASSWORD = FALSE;

-- STEP 3: give the role to the user, and require MFA
GRANT ROLE FUZZY_READER TO USER DEMO_VIEWER;
ALTER USER DEMO_VIEWER SET AUTHENTICATION POLICY FUZZY_FACTORY_DB.ECOMMERCE.REQUIRE_MFA;
```

---

## The script – follow the slides

### Part 1 · SLIDE 1 – “Load your data. Share it safely.” (0:00–0:10)
**Show:** Slide 1.
**Say:**
> Want to put your data in the cloud and let someone look at it – without letting them change anything? Let me show you how in Snowflake, step by step.

### Part 2 · SLIDE 2 – “My data: an online toy store” (0:10–0:30)
**Show:** Slide 2 – point at the table, then at the three boxes on the right.
**Say:**
> Here’s my data: an online toy store. Six tables, 1.7 million rows – website visits, orders and refunds. In Snowflake it takes only 19 megabytes. How did it get in? Two simple moves. First, I uploaded my six CSV files into a stage – think of it as a waiting room for files. Then one command, COPY INTO, moves each file into its table.

### Part 3 · SNOWFLAKE – show the loading (0:30–0:55)
**Show:**
1. Worksheet **B**: RAW_STAGE with the 6 files.
2. Worksheet **A**: highlight the `COPY INTO` lines.
3. Run the **table-overview query** → 6 tables + TOTAL 1,735,068 rows.

**Say:**
> Here are my six files in the stage. And here’s the COPY INTO command that loaded them. Let’s check it worked. Here are all six tables – 1.7 million rows in total. Everything is there.

### Part 4 · SLIDE 3 – “Giving someone access: 3 steps” (0:55–1:10)
**Show:** Slide 3 – point at cards 1, 2, 3, then the MFA line.
**Say:**
> Now, who can see this data? Giving someone access takes three steps. One: create a role – that’s what the person is allowed to do. Mine can only read my tables. Two: create the user – that’s the person. Three: connect them – give the role to the user. And with MFA, they need their password and a code from their phone to log in.

### Part 5 · SNOWFLAKE – the three steps (1:10–1:45)
**Show:** Worksheet **C**. Highlight each step, then click **Run**.

| Step | Highlight & run | Say |
|---|---|---|
| 1 | STEP 1 lines | “Step one: create the role. It can use the computer that runs queries and open my tables – but only to SELECT. That means read only.” |
| 2 | STEP 2 lines | “Step two: create the user – a name, password and email. TYPE equals PERSON means a real human, and they land straight in the right data.” |
| 3 | STEP 3 lines | “Step three: give the role to the user – and turn on MFA.” |

### Part 6 · SNOWFLAKE – test as the new user (1:45–2:25)
**Show and say:**

| Do | Say |
|---|---|
| Incognito window → log in as **DEMO_VIEWER** | “Let’s test it as the new user.” |
| **Set up MFA** → Authenticator → scan the QR code with your phone → type the code | “Snowflake asks for MFA. I scan the code with my phone, type the six numbers… and I’m in.” |
| New SQL file → run `SELECT COUNT(*) FROM FUZZY_FACTORY_DB.ECOMMERCE.ORDERS;` → **32,313** | “Can they read the data? Yes – 32,313 orders.” |
| Run `DELETE FROM FUZZY_FACTORY_DB.ECOMMERCE.PRODUCTS;` → **Insufficient privileges** | “Can they delete something? Access denied. Read only, exactly as planned.” |

### Part 7 · SLIDE 4 – “Recap: what we proved” (2:25–2:40)
**Show:** Slide 4 – point at the blue box (✓ Can read), then the orange box (🔒 Can’t delete).
**Say:**
> Let’s recap what we proved. The new user can read the data – 32,313 orders came back. But they can’t delete anything – Snowflake said “Insufficient privileges.” That’s exactly what we want: safe, read-only access. I did the same for my test user and both instructors. Load the data, create a role, create a user, connect them, and add MFA. Thanks for watching!

---

## Tips
- **Smile and keep a good pace** – energy matters more than perfection.
- Say slowly: **stage = waiting room for files**, and the **3 steps: role → user → connect them**.
- Pause one second after each **Run** so viewers see the result.
- Small mistake? Keep going. Running long? Shorten Part 3 first – users and access are what this video is graded on.

## After recording
1. Watch it once – voice clear, code readable, about 2:30.
2. Upload to **YouTube → Unlisted** (not Private). Title: *“Snowflake for Beginners: Load Data and Share It Safely (Users, Roles & MFA)”*.
3. Captions start automatically – check later in YouTube Studio → Subtitles.
4. Optional cleanup after upload: `DROP USER DEMO_VIEWER;` (keep EXT_TEST_USER and the instructor users!).
