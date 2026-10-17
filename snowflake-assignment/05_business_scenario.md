# Step 2 – Business Scenario: Build-A-Bear Workshop

**Role:** Data analyst on Build-A-Bear's e-commerce & marketing analytics team (aspiring – a
company I want to work for). Internal pitch to the **CTO (Dara Meath)** and **CMO (Julia Fitzgerald)**.

**Data used in the proof of concept:** Maven Fuzzy Factory – a public sample dataset of an online
teddy-bear retailer (472k website sessions, 32k orders, 2012–2015). It stands in for Build-A-Bear's
own e-commerce data, which is not public.

## Business Scenario (Word document version)

**Company.** Build-A-Bear Workshop (NYSE: BBW) is a specialty retailer of customizable stuffed animals, headquartered in St. Louis, Missouri, with about 5,500 employees. FY2026 revenue was $529.8M, and 92% came from direct-to-consumer sales through its stores and two e-commerce sites in the U.S., Canada, the U.K. and Ireland (source: FY2026 10-K via PitchBook).

**Problem.** In August 2026 the company cut its revenue guidance to $500–525M because of falling store and web traffic. Marketing spend must therefore go to the channels that actually convert, yet ad, website and sales data sit in separate systems and channel reports are assembled by hand. My proof of concept on a sample teddy-bear e-commerce dataset (Maven Fuzzy Factory) shows the risk: one paid search channel produces 58% of revenue, while paid social converts at only 3.2% compared with 8.9% for brand search.

**Business question.** Which marketing channels drive direct-to-consumer revenue most efficiently, and which platform, Snowflake or Google BigQuery, supports this analysis best at the lowest three-year cost?

**Users.** Three marketing analysts, ten marketing managers who view dashboards, three executives (CMO, CTO, CFO) and two or three agency and licensing partners who need read-only access.

**Workload.** Website sessions, pageviews, orders, refunds and ad data, growing about 50% per year; dashboards refreshed hourly; about 200 ad-hoc queries per month; seasonal peaks around holidays; U.S. and European data.

**Budget.** $150,000 over three years (about $50,000 per year) for platform, connectors, migration, training and administration. This is about 0.01% of annual revenue and is repaid by improving direct-to-consumer revenue by roughly 0.01%.

**Success criteria.** Daily automated channel dashboard instead of a weekly manual report; 80% less analyst reporting time; 10% of ad spend shifted to higher-converting channels; three-year cost within budget; role-based, MFA-protected access for every user.

*Budget, users and workload are my assumptions; Build-A-Bear's actual data platform is not public.*

---

# Full version (backup / appendix)

---

## 1. Company (real, public facts)

| Item | Fact | Source |
|---|---|---|
| Company | Build-A-Bear Workshop, Inc. (NYSE: BBW), founded 1997 | PitchBook |
| HQ | Saint Louis, Missouri, USA | PitchBook |
| Employees | ~5,500 | PitchBook |
| Revenue FY2026 (year ended 31-Jan-2026) | **$529.8M** (+6.7% YoY); FY2022 $411.5M → **+29% in 4 years** | 10-K via PitchBook |
| Net income FY2026 | $52.2M (9.9% margin) | PitchBook (analyst normalized) |
| Direct-to-Consumer (stores + **2 e-commerce sites**) | $486.0M = **91.7%** of revenue | 10-K segments via PitchBook |
| Commercial (licensing, wholesale) | $38.8M, growing fast (+23% YoY) | same |
| International franchising | $5.1M | same |
| Regions | North America $451.2M · **Europe $71.7M** (U.S., Canada, U.K., Ireland stores) · Other $6.9M | same |
| Current situation | TTM revenue **$517.8M (−0.9%)**; FY2026 guidance cut to **$500–525M** "amid traffic pressure and weaker summer trends" (Aug-2026); stock −58% YoY | PitchBook news / highlights |

## 2. Problem (pain point)

- **Traffic is falling** and leadership cut revenue guidance → the business must spend marketing
  dollars where they actually convert.
- Channel performance is hard to see quickly: marketing data (Google Ads, website analytics) and
  sales data live in **separate systems** → reports are stitched together manually ("siloed data",
  Snowflake deck – Universal Complaints).
- **Evidence from the proof of concept (Fuzzy Factory data):**
  - One paid channel (nonbrand Google search) = **58% of revenue** → concentration risk.
  - Brand search converts at **8.9%**, paid social at only **3.2%** → budget is going to weak channels.
- With the stock down and investor scrutiny, the **CFO view is cost-sensitive**: any new platform must
  show fast payback.

## 3. Business question

> *Which marketing channels drive Build-A-Bear's direct-to-consumer revenue most efficiently –
> and which data platform, **Snowflake or Google BigQuery**, best supports that analysis at the
> lowest 3-year cost?*

## 4. Users

| User group | # | Need |
|---|---|---|
| Marketing / e-commerce analysts | 3 | SQL analysis, channel & campaign ROI |
| Marketing & digital managers (dashboard viewers) | 10 | Daily channel dashboard |
| Executives (CMO, CTO, CFO) | 3 | Weekly summary |
| External partners (agencies, licensing partners) | 2–3 | Secure, read-only access to shared data |

## 5. Workload (Phase 1: marketing & e-commerce analytics)

| Item | Assumption | Basis |
|---|---|---|
| Data today | Web sessions, pageviews, orders, refunds, ad spend – low GB range | PoC data ~100 MB for 3 yrs of one store; scaled for 2 sites + stores |
| Growth | +50% per year | PoC data: sessions 62k → 113k → 233k per year |
| Dashboard refresh | Hourly, 12 h/day | Persona |
| Ad-hoc queries | ~200 / month | Persona |
| Seasonality | Peaks around holidays / Halloween / Valentine's | Retail pattern – needs elastic compute |
| Regions | U.S. + U.K./Ireland data | 10-K: Europe = $71.7M revenue |

## 6. Budget

> **Phase 1 cap: $150,000 over 3 years (~$50,000 per year), all-in** – platform, connectors,
> migration, training and admin time.

Why this number is defensible:
- ≈ **0.01% of FY2026 revenue** and ≈ **0.1% of net income** per year → small enough to approve in a
  cost-cutting year.
- Pays for itself if it improves direct-to-consumer revenue by just **~0.01% per year**
  ($50K ÷ $486M) – e.g. by moving budget from a 3.2% channel to an 8.9% channel.
- Phase 1 scope only (marketing analytics); company-wide expansion is a later decision.

## 7. Success criteria (measurable)

| # | Criterion | Target |
|---|---|---|
| 1 | Channel ROI dashboard freshness | Weekly manual report → **daily automatic** |
| 2 | Analyst time on reporting | **−80%** (about 1 day/week saved per analyst) |
| 3 | Marketing efficiency | Shift **10%** of spend from lowest- to highest-converting channels |
| 4 | Cost | 3-year TCO **within the $150K budget** |
| 5 | Governance | Role-based, read-only access for partners; MFA for all users |

## 8. Decision rule (set before scoring)

1. Any platform whose 3-year TCO exceeds the $150K budget is rejected.
2. If the two TCOs differ by **less than 20%**, cost does not decide – scalability, usability and
   business fit decide.
3. Weighted score (Pricing 30% · Scalability 25% · Usability 20% · Business fit 25%) gives the
   final recommendation; a sensitivity check tests "marketing-only" vs "company-wide" scope.

---
*Assumptions are labelled as such. Build-A-Bear's actual data platform is not public; nothing here
claims insider knowledge.*
