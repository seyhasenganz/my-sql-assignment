# Hotel Booking Demand: decisions for revenue management

**Name: Seyha Seng — verify your submission name.**

AI assistance: ChatGPT helped draft code and explanations. Review the work and amend this disclosure to satisfy Hult’s AI policy.

### Management overview

**The pricing model is useful as a review reference; the cancellation model is not ready for automatic decisions.** The analysis addresses booking-time cancellation risk and daily rates among completed stays at two hotels. Later-period evaluation reduces average pricing error from 40.11 to 25.63 rate units. Cancellation detection is weak and sensitive to repeated records. We recommend a low-cost confirmation pilot and manager-led pricing review, not automatic overbooking or price changes. Historical associations identify where to investigate; they do not establish that an intervention increases revenue.

## 1. Understand and prepare the data

The dataset contains 119,390 bookings and 32 columns, with arrivals from July 2015 through August 2017. Missing values affect children (4), country (488), agent (16,340), and company (112,593). The latter three fields are not predictors, so their missingness does not justify deleting bookings. Missing children are imputed using training medians during modeling; guest screening does not assume missing children equal zero.

There are 31,994 repeated rows after first occurrence. They are retained because no booking identifier establishes whether identical records are duplicates or separate reservations. This preserves frequencies but can overweight copied records. A test-only sensitivity check examines the effect on evaluation, without resolving record identity or training duplication.

Zero-guest or zero-night bookings are outside the occupied-stay scope. Removing their overlapping union excludes 825 rows, leaving 118,565. Cancellation prevalence changes only slightly, from 37.04% to 37.26%. Pricing uses 74,388 completed stays with ADR between zero and 1,000. The upper limit is a screening assumption, not a verified business limit. Screening changes completed-stay mean ADR negligibly, from 101.0068 to 101.0082. The 1,000 zero-rate stays remain because complimentary accommodation may be legitimate.

Reservation status and its date are excluded from predictors. Assigned rooms, final amendments, waiting time, and later requests are also excluded because booking-time availability is uncertain. Status only defines the pricing population. Transaction-based ADR is excluded from cancellation predictors to avoid possible later information. Consequently, pricing findings concern completed stays, not every reservation or total hotel revenue.

## 2. Establish a baseline

The business should adopt a model only if it improves on a simple alternative. Training uses arrivals through December 2016; January–August 2017 evaluates performance. Arrival chronology is an imperfect proxy for booking chronology because long-lead reservations cross the boundary. Exploration uses training records only.

Cancellation training and evaluation contain 78,055 and 40,510 bookings. Always predicting no cancellation achieves 61.17% accuracy but catches no cancellations. The training cancellation probability is 36.44%. Accuracy alone therefore gives a misleading impression of operational usefulness.

For completed-stay pricing, the training mean ADR is 95.51. Using this same prediction for every later stay produces average absolute error of 40.11 rate units. This is the reference the pricing model must improve. Neither a baseline nor model error measures profitability.

## 3. Visualize

### Cancellation: where management should investigate

Training-period City Hotel cancellation averages 41.53%, versus 26.58% at Resort Hotel. Long-lead bookings show a particularly clear gradient: cancellation rises from 10.15% within seven days to 59.95% beyond 180 days. Group bookings average 62.44%, versus 15.45% for Direct bookings. These findings support reviewing confirmation practices for long-lead and group reservations, rather than treating all reservations identically.

These are unadjusted comparisons, not proof that advance booking or channel causes cancellation. Contracts and customer mix may explain differences. Counts accompany rates: the Undefined segment has only two records, making its 100% cancellation unsuitable for policy.

### Daily rates: use comparable groups

The ADR distribution, hotel boxplots, and monthly hotel averages show why one overall rate is a weak reference. Monthly charts allow seasonal patterns to be examined separately by hotel; however, training begins in July 2015, so coverage is uneven. Management should compare similar hotel, season, room, and customer contexts before judging a rate. Room and segment are model inputs, but this notebook does not isolate their individual economic contributions or identify an optimal price.

## 4. Quantify uncertainty

Training completed-stay mean ADR is 100.93 for City Hotel, with approximate 95% t interval 100.52–101.35. Resort Hotel averages 87.13, with interval 86.36–87.89. The observed difference of 13.81 rate units is large enough to warrant separate hotel pricing references; it is not a justified instruction to raise resort rates by that amount.

Welch’s test gives p approximately 5.87 × 10^-208, strong evidence against equal means under its assumptions. The business decision depends on the size and context of the difference, not the tiny p-value. Room mix, season, and customers may explain the gap.

Intervals describe mean ADR, not individual booking prices or tomorrow’s achievable rate. Repeated customers, group reservations, possible copied rows, and seasonal dependence weaken independence assumptions and can make intervals too narrow. Uncertainty about transferring historical results to current operations is greater than these narrow statistical intervals suggest.

## 5. Model

### Cancellation: modest improvement, substantial missed risk

Logistic regression uses hotel, lead time, month, segment, reserved room, nights, party composition, repeat status, and prior cancellations. These have plausible booking-time roles, but immutable booking-time snapshots are unavailable. Training-only imputation, indicator encoding, and scaling support the classroom model. Chronological evaluation and prediction metrics are explained additions to the taught methods.

At a fixed 0.5 cutoff, accuracy is 65.05%, against the 61.17% baseline. Among flagged bookings, 59.51% cancel; only 31.28% of all cancellations are detected. The model finds 4,920 cancellations but misses 10,810 and incorrectly flags 3,347 noncancellations. Resort cancellation detection is 16.90%, versus City’s 36.27%. This may help prioritize inexpensive reminders, but cannot support booking rejection or an overbooking quantity.

Removing identical source rows from evaluation changes accuracy to 68.14%, barely above the 67.96% baseline, and detection to 21.20%. The model’s apparent advantage is therefore not robust to record weighting. The check leaves training unchanged and cannot establish which repeated records are valid.

### Pricing: useful reference, not an automatic pricing engine

Linear regression uses the same feature set among completed stays. Average absolute test error falls from 40.11 to 25.63 units, approximately a 36% improvement. Test R² is 0.529: explained variation relative to a mean reference, not percentage accuracy. Errors are larger at Resort Hotel (29.43) than City Hotel (23.43). The improvement persists when identical evaluation records are removed: 26.29 versus 42.30 units.

Holding included predictors fixed, an additional adult is associated with 12.51 higher ADR; another lead-time day with 0.040 lower ADR. These coefficients describe historical associations, not the return from changing party size or booking timing. Categorical inputs account for context, but their inclusion alone does not demonstrate importance.

Residuals show wider errors at higher predicted rates and a zero-rate band. Some expensive stays are underpredicted, and 94 predictions are negative. Excluding zero-rate test stays gives error 25.45, so they do not explain the overall limitation. Managers should review outputs, especially resort and high-rate cases. No demand response, occupancy optimization, or revenue-maximizing price is estimated.

## 6. Recommendation

**Start with controlled operational pilots, not full deployment.**

| Action | Owner | Measure of success |
| --- | --- | --- |
| Pilot confirmation reminders for selected long-lead or group bookings | Reservations team | Cancellation and completed-stay rates versus usual practice; staff time and complaints |
| Use predicted ADR to flag bookings for contextual review | Revenue manager | Useful flags, review time, occupancy, achieved ADR, and revenue per available room |
| Validate on recent booking-time records before expansion | Analytics team | Detection, false alarms, pricing errors, and stability by hotel |

Where feasible, randomly assign eligible bookings to the reminder pilot or usual practice. Do not treat sending reminders as proven to prevent cancellations. Establish acceptable costs and outcomes before assessing results. Avoid automatic rejection and model-based overbooking because missed cancellations and false flags are substantial.

Pricing flags should prompt review of season, room, segment, and market conditions, not automatic increases. A pricing change requires its own controlled evaluation: a higher achieved rate can still reduce occupancy or revenue. The current model benchmarks historical completed stays and cannot determine customers’ willingness to pay.

Confidence is strongest in observed historical comparisons and measured evaluation results. Data cover only two hotels and end in 2017; current demand, repeated records, completed-stay selection, and uncertain booking-time availability limit applicability. Use recent data and prospective evaluation before claiming business benefits. The strongest deliverable is a transparent decision process, not a claim that either model guarantees better revenue.

## Submission check

Restart the Colab runtime and run all cells in order with `hotels.csv` in the working directory. Verify your name and AI disclosure, then submit this notebook and the CSV. Code comments do not count toward the narrative word limit.
