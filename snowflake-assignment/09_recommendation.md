# Step 5–6 – Cost-Benefit Result & Recommendation

Source of every number: `08_TCO_Snowflake_vs_BigQuery.xlsx` (formulas; change any blue input and it recalculates).

## 3-year TCO – same workload (Build-A-Bear Phase 1 marketing analytics)

| Cost item (3 years) | Snowflake | BigQuery |
|---|---:|---:|
| Compute | $3,706 | $1,897 |
| Storage | $111 | $50 |
| Google Ads connector | $684 | $0 |
| **Platform subtotal** | **$4,501** | **$1,947** |
| Migration + setup (hidden) | $5,280 | $5,520 |
| Training (hidden) | $1,440 | $1,800 |
| Admin (hidden) | $8,640 | $8,640 |
| **3-year TCO** | **$19,861** | **$17,907** |

- BigQuery is **$1,954 (11%) cheaper** over 3 years – mainly its free query tier and free Google Ads connector.
- **Labor is 77–89% of TCO** – the platform bill is the small part (the "hidden cost" lesson).
- Both are far inside the **$150K** Phase 1 budget.

## Risk check (sensitivity, year 1)
| | Snowflake | BigQuery |
|---|---:|---:|
| Disciplined | $1,223 | $381 |
| Careless (10-min auto-suspend / SELECT * scans) | $3,167 | $1,985 |
| Multiplier | **2.6×** | **5.2×** |

BigQuery is cheaper when used carefully, but its bill is **twice as sensitive** to careless queries.
My PoC showed Snowflake's own risk: 91% of credits came from the default warehouse.

## Weighted scoring
| Criterion | Weight | Snowflake | BigQuery |
|---|---:|---:|---:|
| Pricing / TCO | 30% | 4 | 5 |
| Scalability | 25% | 5 | 5 |
| Usability | 20% | 5 | 4 |
| Business fit | 25% | 4 | 4 |
| **Weighted total** | | **4.45** | **4.55** |
| Non-cost criteria only | | **3.25** | **3.05** |

## Decision
The decision rule (set in Step 2, before scoring): *if the TCO gap is under 20%, cost does not
decide – the non-cost criteria do.* The gap is 11%, so:

> **Recommendation: Snowflake** for Build-A-Bear's analytics platform.
> The extra ~$650 per year buys easier administration for a small team (proven in my
> 2.5-hour proof of concept), more predictable costs (2.6× vs 5.2× risk), simple role-based
> access with MFA for agencies and licensing partners, and no lock-in to one cloud.
>
> **When BigQuery would win:** if the scope stays marketing-only, the team already works in
> Google Cloud, and queries are disciplined (partitioned tables, max-bytes-billed limits).
> **Re-evaluate** at the end of year 1 or if Snowflake spend exceeds forecast by 25%.

Value either way: ~$166K per year (analyst time + better channel allocation, both assumptions) →
payback in under 2 months on either platform. The project is worth doing; the question is only which platform.
