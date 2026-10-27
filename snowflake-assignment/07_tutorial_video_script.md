# Tutorial Video Script – "Give someone safe access to your Snowflake data"

Target length: **about 2 minutes** (rubric says 1–2 min, instructions say 2–3 min → ~2:00 fits both).
Style: friendly, simple, like showing a friend. ≈ 300 words.

**The big idea (one picture to remember):** Snowflake works like an office building.
- A **role** is a **key card** – it says which doors open.
- A **user** is a **person**.
- You give the person the key card.
- **MFA** is the extra code from their phone, so a stolen password is not enough.

---

## Before you hit record
1. **Window 1 (normal):** logged in as **SSENG**, new SQL file with the DEMO SQL below pasted in.
2. **Window 2 (incognito):** open at `https://jdkuhsr-qk22783.snowflakecomputing.com`.
3. Phone with **Google or Microsoft Authenticator** ready (for the MFA step).
4. Zoom the browser to **125%** so the code is easy to read. Close other tabs and notifications.
5. Record with **Win + Shift + R** (Snipping Tool) with your microphone on. Camera in a corner = more engaging.

We create a **new demo user (DEMO_VIEWER)** on camera, so the MFA setup screen appears live.

### DEMO SQL (paste in Window 1 before recording)
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
| **0:00–0:15** Hook | Snowflake home as SSENG | “Want to let someone look at your data – without letting them change or delete anything? In about two minutes, I’ll show you how to do that in Snowflake, even if you’ve never opened it before.” |
| **0:15–0:30** The idea | Point to the 6 tables in the left panel | “Here’s my data: an online toy store with 1.7 million rows. To share it safely, think of Snowflake like an office building. A **role** is a key card. A **user** is a person. We make the key card, create the person, and hand it over. Three steps.” |
| **0:30–0:50** Step 1 | Highlight STEP 1 lines → Run | “Step one: make the key card. I create a role called FUZZY_READER and decide which doors it opens: the computer that runs queries, my database, and my tables. Notice it only says **SELECT** – that means *read only*. No changes allowed.” |
| **0:50–1:05** Step 2 | Highlight STEP 2 → Run | “Step two: create the person. I give them a name, a password and an email. TYPE equals PERSON tells Snowflake this is a real human. And I set where they land when they log in, so they go straight to the right data.” |
| **1:05–1:15** Step 3 | Highlight STEP 3 → Run | “Step three: hand over the key card. One more line turns on MFA – so a password alone is not enough to get in.” |
| **1:15–1:35** Test: log in + MFA | Incognito window → log in as DEMO_VIEWER → **Set up MFA** → Authenticator → scan QR with phone → enter code | “Now let’s test it as the new user. Snowflake asks me to set up MFA. I scan this code with an authenticator app on my phone, type the six numbers… and I’m in.” |
| **1:35–1:45** Test: it works | Run `SELECT COUNT(*) FROM FUZZY_FACTORY_DB.ECOMMERCE.ORDERS;` → **32,313** | “Can this user read the data? Yes – 32,313 orders.” |
| **1:45–1:55** Test: it’s safe | Run `DELETE FROM FUZZY_FACTORY_DB.ECOMMERCE.PRODUCTS;` → **Insufficient privileges** | “Can they delete something? Let’s try… Access denied. Read-only, exactly as planned.” |
| **1:55–2:10** Wrap-up | Back to Window 1 → `SHOW USERS;` (EXT_TEST_USER, LESCAMILLA, ECALICIBETE) | “I used the same three steps for my external test user and for both instructors. Key card, person, hand it over – plus MFA. That’s safe data sharing in Snowflake. Thanks for watching!” |

---

## Tips to make it engaging
- **Smile and speak a little faster than normal** – energy matters more than perfection.
- Say the key-card idea slowly; it is the part beginners remember.
- Pause for one second after each **Run**, so viewers see the green “success” result.
- If you make a small mistake, keep going – it looks natural. Re-record only big mistakes.

## After recording
1. Watch it once – check the voice is clear and the code is readable.
2. Upload to **YouTube → Unlisted** (not Private). Title: *“Snowflake for Beginners: Share Your Data Safely (Users, Roles & MFA)”*.
3. Captions start processing automatically – check later in YouTube Studio → Subtitles.
4. Optional cleanup after upload: `DROP USER DEMO_VIEWER;` (keep EXT_TEST_USER and the instructor users!).
