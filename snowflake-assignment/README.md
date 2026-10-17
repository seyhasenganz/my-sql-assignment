# Snowflake Assignment – Maven Fuzzy Factory

Dataset: **Maven Fuzzy Factory** (Maven Analytics "Toy Store E-Commerce Database") –
an online teddy-bear retailer, Mar-2012 to Mar-2015.
Download: https://maven-datasets.s3.us-east-1.amazonaws.com/Maven+Fuzzy+Factory/Maven+Fuzzy+Factory.zip

## The data (6 tables, ~1.7M rows, ~100 MB)

| Table | Rows | What it is |
|---|---|---|
| WEBSITE_SESSIONS | 472,871 | One visit to the website + marketing source (UTM), device |
| WEBSITE_PAGEVIEWS | 1,188,124 | Each page viewed inside a session |
| ORDERS | 32,313 | One purchase: price and cost (COGS) |
| ORDER_ITEMS | 40,025 | Each product inside an order |
| ORDER_ITEM_REFUNDS | 1,731 | Returned items |
| PRODUCTS | 4 | The 4 teddy bears |

```
PRODUCTS ─< ORDER_ITEMS >─ ORDERS >─ WEBSITE_SESSIONS ─< WEBSITE_PAGEVIEWS
                 └─< ORDER_ITEM_REFUNDS
```

Every file is under Snowflake's 250 MB upload limit – no splitting needed.
**Do not open and re-save the CSVs in Excel** – upload the originals.

## Files in this folder

| File | Purpose | Assignment step |
|---|---|---|
| `01_setup_and_load.sql` | Warehouse, database, schema, file format, stage, tables, load, row-count check | Step 1 |
| `02_users_and_access.sql` | Read-only role, external user, 2 instructor users, verification | Step 2 |
| `03_submission_query.sql` | **The one query** for the Word document (commented, fully qualified) | Step 3 |

## Step by step

1. **Trial account** – sign up at signup.snowflake.com with your `@student.hult.edu` email
   (Enterprise edition, AWS, a nearby region). Note the trial end date: it must
   still be active when the instructors grade.
2. **Extract** `Maven+Fuzzy+Factory.zip` on your PC.
3. In Snowsight open **Projects → Worksheets → + SQL Worksheet**.
4. Paste `01_setup_and_load.sql`, run sections 1–5 (up to `CREATE TABLE`s).
5. **Upload files** to the stage: *Data/Catalog → Databases → FUZZY_FACTORY_DB → ECOMMERCE →
   Stages → RAW_STAGE → + Files* → select the 6 CSVs (not the data dictionary).
6. Run sections 6–8 (`LIST`, `COPY INTO`, row-count check). Compare with the
   expected counts in the script.
7. Open `02_users_and_access.sql`, **replace the passwords and your personal email**, run it.
8. **Test the external user**: incognito window → log in as `EXT_TEST_USER` →
   enrol MFA → run `SELECT COUNT(*) FROM FUZZY_FACTORY_DB.ECOMMERCE.ORDERS;` (32,313).
   Take screenshots. Record this for the tutorial video.
9. Run `03_submission_query.sql` as the test user – it must run without errors.
10. Get your **account identifier** with the last query in `02_users_and_access.sql`.

## MFA plan (write this in the Word document)

Snowflake no longer allows password-only sign-in for human users. Each user is
created with `TYPE = PERSON` and a password; at **first login Snowflake asks the
user to enrol MFA** (authenticator app such as Duo/Google/Microsoft Authenticator,
or a passkey). MFA is tied to the user's own device, so the account owner cannot
enrol it on their behalf. Instructors: log in with the username/password below,
follow the enrolment prompt once, then query the data.

## Expected result of the submission query

| Channel | Sessions | Orders | Conv. % | Revenue $ | Rev/session $ | Net margin $ | Rev share % |
|---|---:|---:|---:|---:|---:|---:|---:|
| Paid nonbrand search (gsearch) | 282,706 | 18,822 | 6.66 | 1,124,414 | 3.98 | 654,354 | 58.0 |
| Paid nonbrand search (bsearch) | 54,909 | 3,818 | 6.95 | 225,563 | 4.11 | 131,632 | 11.6 |
| Organic search | 43,411 | 3,262 | 7.51 | 196,809 | 4.53 | 115,135 | 10.2 |
| Direct type-in | 39,917 | 2,856 | 7.15 | 174,624 | 4.37 | 102,616 | 9.0 |
| Paid brand search (gsearch) | 33,329 | 2,511 | 7.53 | 151,731 | 4.55 | 88,750 | 7.8 |
| Paid brand search (bsearch) | 7,914 | 701 | 8.86 | 43,109 | 5.45 | 25,242 | 2.2 |
| Paid social (socialbook) | 10,685 | 343 | 3.21 | 22,259 | 2.08 | 13,071 | 1.1 |

**Key insights**
- **Concentration risk:** one paid channel (nonbrand gsearch) = 58% of revenue, yet it
  converts *below* average and earns the least per session among search channels.
- **Free/cheap traffic performs best:** organic, direct and brand search convert at
  7.2–8.9% and earn $4.37–$5.45 per session with little or no ad cost.
- **Paid social underperforms:** 3.2% conversion, $2.08/session – review or cut.

## Business growth (talking points for the videos)

| Year | Sessions | Orders | Conv. % | Revenue/session $ | Avg order value $ |
|---|---:|---:|---:|---:|---:|
| 2012 (from Mar) | 62,470 | 2,586 | 4.14 | 2.07 | 49.99 |
| 2013 | 112,781 | 7,447 | 6.60 | 3.49 | 52.81 |
| 2014 | 233,422 | 16,860 | 7.22 | 4.61 | 63.80 |
| 2015 (to Mar) | 64,198 | 5,420 | 8.44 | 5.30 | 62.80 |

Conversion doubled (4.1% → 8.4%) and revenue per session rose 2.5×, helped by
new product launches (products 2–4 launched 2013–2014) that lifted average order value.
