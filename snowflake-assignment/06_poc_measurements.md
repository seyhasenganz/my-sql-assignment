# Proof-of-Concept Measurements (Snowflake trial, 26-Oct-2026)

Account identifier: `JDKUHSR-QK22783` · Edition: Enterprise trial · Cloud: AWS

## Data loaded
| Table | Rows | Stored size |
|---|---:|---:|
| WEBSITE_PAGEVIEWS | 1,188,124 | 9.95 MB |
| WEBSITE_SESSIONS | 472,871 | 8.11 MB |
| ORDERS | 32,313 | 0.47 MB |
| ORDER_ITEMS | 40,025 | 0.45 MB |
| ORDER_ITEM_REFUNDS | 1,731 | 0.02 MB |
| PRODUCTS | 4 | 0.00 MB |
| **Total** | **1,735,068** | **≈ 19.0 MB** (raw CSV 102.9 MB → ~5.4× compression) |

## Compute used (whole PoC: setup, load, user tests, analysis)
| Warehouse | Credits |
|---|---:|
| FUZZY_WH (X-Small, auto-suspend 60 s) | 0.0516 |
| COMPUTE_WH (default trial warehouse, X-Small) | 0.5316 |
| Cloud services | 0.0006 |
| **Total** | **0.5838 credits ≈ $1.75 at $3/credit (Enterprise) · ≈ $1.17 at $2 (Standard)** |

Observation: ~91% of credits came from the default COMPUTE_WH, used by the admin
worksheets, not from the purpose-built FUZZY_WH with 60-second auto-suspend.
Lesson for the business case: warehouse sizing and auto-suspend settings drive cost.

## Submission query performance
| User | Elapsed | Data scanned |
|---|---:|---:|
| EXT_TEST_USER (FUZZY_READER role) | **1.33 s** | **3.3 MB** |

(The other two QUERY_HISTORY rows, by SSENG, were the monitoring queries themselves –
their text also contains "session_channels".)

## Access-control tests (EXT_TEST_USER)
- `SELECT COUNT(*) FROM ...ORDERS` → 32,313 ✅
- `DELETE FROM ...PRODUCTS` → "Insufficient privileges" ✅ (read-only confirmed)
- `USE ROLE ACCOUNTADMIN` → "Requested role is not assigned" ✅ (no privilege escalation)
- Submission query → 7 channel rows, matches expected result ✅
