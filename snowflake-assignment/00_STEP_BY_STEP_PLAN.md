# A1 Snowflake – Step-by-Step Plan (due Sun 2-Nov-2026, 6 pm)

Target: submit **Sat 1-Nov** (1 day buffer). Captions need time → upload videos early.

| Day | Date | Work |
|---|---|---|
| 1 | Mon 26-Oct | Phase A – Snowflake setup, data, users, query (2–3 h) |
| 2 | Tue 27-Oct | Phase B – record + upload tutorial video |
| 3 | Wed 28-Oct | Phase C – Claude builds TCO, scoring, slides, explainer script; you review |
| 4 | Thu 29-Oct | Phase D – record + upload explainer video |
| 5 | Fri 30-Oct | Phase E – download transcripts; Claude assembles Word doc |
| 6 | Sat 31-Oct / Sun 1-Nov | Phase F – final checks, submit |

---

## Phase A – Snowflake (Steps 1–3 of the assignment)

### A0. Before you start
- [ ] Tell your trio: **dataset = Maven Fuzzy Factory, competitor = Google BigQuery**.
- [ ] Extract `Maven+Fuzzy+Factory.zip` to a folder (e.g. `Documents\fuzzy`). Do **not** open/save the CSVs in Excel.
- [ ] Start a timer – note your setup time (needed for TCO).

### A1. Create the trial account
1. Go to https://signup.snowflake.com
2. Use your **@student.hult.edu** email.
3. Choose **Enterprise** edition, **AWS**, region **US East (N. Virginia)** (or nearest).
4. Activate via the email, set username + password, enrol MFA when asked.
5. Write down the **trial end date** (30 days) – must still be active at grading.
6. 📸 Screenshot: Snowsight home page.

### A2. Run the setup script (create objects)
1. Snowsight → **Projects → Workspaces/Worksheets → + SQL Worksheet**.
2. Open `01_setup_and_load.sql`, copy sections **1–5** (down to the last `CREATE TABLE`), paste, **Run All** (Ctrl+Shift+Enter).
3. Check: left panel shows database `FUZZY_FACTORY_DB` → schema `ECOMMERCE` → 6 tables (empty).

### A3. Upload the CSV files to the stage
1. Left menu **Catalog** (or **Data**) → **Databases** → `FUZZY_FACTORY_DB` → `ECOMMERCE` → **Stages** → `RAW_STAGE`.
2. Click **+ Files** → select the 6 CSVs (NOT the data dictionary):
   products, website_sessions, website_pageviews, orders, order_items, order_item_refunds.
3. Click **Upload** and wait until done.

### A4. Load and verify
1. Back in the worksheet, run sections **6–8** (`LIST`, `COPY INTO`, row-count check).
2. Expected row counts:
   PRODUCTS 4 · WEBSITE_SESSIONS 472,871 · WEBSITE_PAGEVIEWS 1,188,124 · ORDERS 32,313 · ORDER_ITEMS 40,025 · ORDER_ITEM_REFUNDS 1,731
3. 📸 Screenshot: row-count result.

### A5. Create role + users (Step 2 of the assignment)
1. Open `02_users_and_access.sql` in a new worksheet.
2. **Edit before running:**
   - Replace the 3 passwords with your own strong passwords (14+ chars, upper, lower, number, symbol). Write them down safely.
   - Replace `your.personal.email@gmail.com` with your personal (non-Hult) email.
3. Run sections 1–4.
4. 📸 Screenshots: `SHOW GRANTS TO ROLE FUZZY_READER` and `SHOW USERS`.
5. Run the last query (account identifier) → note **account_identifier** and **account_locator**.
6. Also note your **login URL**: account menu (bottom-left, your name) → **Account** → copy the account URL
   (looks like `https://ORGNAME-ACCOUNTNAME.snowflakecomputing.com`). Instructors need this.

### A6. Test the external user + MFA
1. Open an **Incognito/Private** window → paste your login URL.
2. Log in as `EXT_TEST_USER` with its password.
3. Snowflake asks to **set up MFA** → choose authenticator app (Duo / Google / Microsoft Authenticator) or passkey → scan QR with your phone → enter code.
4. 📸 Screenshot each MFA screen (needed for the tutorial video + doc).
5. Open a worksheet, run:
   ```sql
   SELECT COUNT(*) FROM FUZZY_FACTORY_DB.ECOMMERCE.ORDERS;   -- expect 32313
   ```
6. Prove read-only – this must FAIL:
   ```sql
   DELETE FROM FUZZY_FACTORY_DB.ECOMMERCE.PRODUCTS;   -- expect "insufficient privileges"
   ```
7. 📸 Screenshot both results.

### A7. Run the submission query (Step 3)
1. Still as `EXT_TEST_USER`, paste the whole `03_submission_query.sql` and run.
2. Result should match the table in `README.md` (7 channels; gsearch nonbrand = 58% of revenue).
3. 📸 Screenshot the result.

### A8. Collect numbers for the TCO (log back in as your admin user)
Run as ACCOUNTADMIN (wait ~1–3 hours after loading – usage views lag):
```sql
SELECT warehouse_name, SUM(credits_used) AS credits
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
GROUP BY warehouse_name;

SELECT query_text, total_elapsed_time/1000 AS seconds, bytes_scanned
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE query_text ILIKE '%session_channels%'
ORDER BY start_time DESC LIMIT 5;

SELECT table_name, active_bytes/1024/1024 AS mb
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
WHERE table_catalog = 'FUZZY_FACTORY_DB' AND deleted = FALSE;
```
Or: **Admin → Cost Management** screenshot.

### ✅ Send Claude after Phase A
1. Screenshots (row counts, grants/users, MFA, external-user query, failed DELETE, submission query result)
2. Account identifier + login URL (NOT passwords – keep those for the Word doc only)
3. Credits used, query seconds, storage MB
4. Your setup time (hours)
5. Any error messages

---

## Phase B – Tutorial video (Step 4) · aim for **~2 minutes**
The instructions say 2–3 min; the rubric says 1–2 min → **2:00 satisfies both**.

1. Claude writes the narration script (send Phase A results first).
2. Prepare: admin worksheet with `02_users_and_access.sql` (use a NEW demo user, e.g. `DEMO_USER`, so you can show creation live) + an incognito window.
3. Record screen + voice: Windows **Snipping Tool → Record** (Win+Shift+R), Xbox Game Bar (Win+G), Zoom, or OBS.
4. Flow: what Snowflake is (10 s) → role & grants (40 s) → create user (30 s) → log in as user + MFA (25 s) → query works / delete fails (15 s).
5. Upload to **YouTube → Unlisted** (or myCourses Studio). Captions start processing automatically.

## Phase C – Analysis (Step 5) – Claude builds, you review
- 3-year TCO (Snowflake vs BigQuery, incl. migration/training/admin) – Excel
- Weighted scoring matrix (pricing 30 / scalability 25 / usability 20 / business fit 25)
- Recommendation + sensitivity check
- Slide deck + explainer script

## Phase D – Explainer video (Step 6) · **4–6 minutes**
Structure (Problem → Solution → Proof → Recommendation):
1. Hook + Build-A-Bear problem (0:00–0:40)
2. What Snowflake and BigQuery are (0:40–1:40)
3. Pros & cons + customer reviews (1:40–2:40)
4. Pricing comparison / 3-year TCO (2:40–4:00)
5. Recommendation + why (4:00–5:00)
Record with slides on screen + your voice (camera optional but adds energy). Upload Unlisted to YouTube.

## Phase E – Transcripts
1. YouTube Studio → **Subtitles** → your video → auto-generated English → ⋮ → **Download** (.txt/.srt).
2. Read through and fix obvious caption errors (assignment says: check text against narration).

## Phase F – Word document + final checks
Claude assembles the .docx. Contents:
1. Snowflake access: account identifier, login URL, database/schema, instructor usernames + passwords, MFA note
2. The SQL query
3. Tutorial video link
4. Explainer video link
5. Both transcripts
6. Slides / visuals

Final checks before submitting:
- [ ] Open both video links in an incognito window (Unlisted, not Private!)
- [ ] Copy the SQL from the Word doc into Snowflake as `EXT_TEST_USER` → runs without errors
- [ ] Instructor users exist: `SHOW USERS;`
- [ ] Trial still active through grading
- [ ] File type **.docx**, uploaded before **Sun 2-Nov 6 pm**
