# Hotel Booking Demand: cancellation risk and daily rates

**Name: Seyha Seng — verify your submission name.**

AI assistance: ChatGPT helped draft code and explanations. Review the analysis and amend this disclosure to satisfy Hult’s AI policy.

This notebook supports two revenue-management decisions: identifying bookings at risk of cancellation and understanding characteristics associated with daily accommodation rates. The cancellation forecast is intended for the time a booking is made. The pricing analysis concerns completed stays, not revenue from every reservation. It uses the supplied hotels.csv containing City Hotel and Resort Hotel records. The analysis follows the course sequence of inspection, baselines, visualization, uncertainty, modeling, and recommendations. Models describe historical associations rather than causal effects. Methods beyond classroom demonstrations, including chronological evaluation and prediction-error metrics, are explained because they help determine whether predictions are useful.

## 1. Understand and prepare the data

The source contains 119,390 bookings and 32 columns, with arrivals from July 2015 through August 2017. Four children values, 488 country values, 16,340 agent values, and 112,593 company values are missing. Country and intermediary identifiers are not predictors here, so their missingness does not justify deleting bookings. Missing children are replaced with the training median only when preparing model inputs. Guest-count screening leaves unknown guest totals unclassified rather than assuming missing children equal zero.

There are 31,994 repeated rows after first occurrence. Without a booking identifier, identical attributes cannot establish duplicate transactions; these records are retained. This preserves booking frequencies but could overweight copied records and exaggerate confidence. A sensitivity check below changes test weighting by removing identical source rows; it does not establish their true identity or repair training duplication.

Zero-guest and zero-night bookings are excluded from the intended occupied-stay analysis. Their overlapping union removes 825 rows, leaving 118,565. Cancellation prevalence changes from 37.04% to 37.26%, showing a small descriptive effect. For pricing, only Check-Out records with ADR between zero and 1,000 are retained. The upper threshold is a transparent screening choice, not an externally verified pricing limit. The negative and extreme rates are inspected; this pricing screen leaves 74,388 rows and changes the completed-stay mean negligibly, from 101.0068 to 101.0082. Zero rates are retained because complimentary accommodation may be legitimate; there are 1,000 such completed stays.

Reservation status and its date are excluded from predictors. Assigned rooms, amendments, waiting time, and later requests are also excluded because booking-time availability is uncertain. Status is used only to define the pricing population. ADR is not used for cancellation prediction because the documented transaction-based measure may reflect later information.

## 2. Establish a baseline

Earlier arrivals through December 2016 train the models; January–August 2017 arrivals form the untouched evaluation period. Arrival chronology is a practical approximation, not an exact booking-time split: long-lead bookings can cross the boundary. Exploration and uncertainty estimates use training records to avoid choosing features from test results.

Cancellation training and test sets contain 78,055 and 40,510 bookings. Always predicting no cancellation achieves 61.17% test accuracy but detects none of the cancellations; the training cancellation probability is 36.44%. For pricing, predicting the training mean of 95.51 gives test mean absolute error of 40.11 monetary units. MAE measures typical absolute error, not percentage accuracy. Both models must improve these references to justify their complexity.

## 3. Visualize

The training charts reveal operationally useful differences. City Hotel cancellations average 41.53%, compared with 26.58% at Resort Hotel. Cancellation increases across lead-time groups, from 10.15% for zero–seven days to 59.95% for more than 180 days. Group bookings show 62.44% cancellation, while Direct bookings show 15.45%. These are unadjusted associations; customer mix and contracts may explain part of the differences. The Undefined segment contains just two records, making its 100% rate unsuitable for a broad recommendation.

The ADR histogram and hotel boxplots show price dispersion that a single mean conceals. Monthly means allow seasonal differences to be assessed separately by hotel. The available training period starts in July 2015, so month comparisons have uneven coverage. Chart interpretation therefore considers season, hotel mix, and sample counts rather than interpreting a visual pattern as proof of a pricing cause.

## 4. Quantify uncertainty

Among training completed stays, City Hotel mean ADR is 100.93, with an approximate 95% t interval of 100.52–101.35. Resort Hotel mean ADR is 87.13, with interval 86.36–87.89. The observed difference is 13.81 monetary units; Welch’s test gives p approximately 5.87 × 10^-208. Under the test assumptions, this is strong evidence against equal population means, but not evidence that hotel type alone causes the difference.

These intervals concern average ADR, not the prices of individual bookings or tomorrow’s rate. They use nonmissing observation counts and sample standard errors. Repeated customers, group bookings, possible copied records, and seasonal dependence weaken the independence assumption and may make intervals too narrow. The large sample produces tiny p-values; economic importance still depends on costs, occupancy, and customer willingness to pay.

## 5. Model

Logistic regression predicts cancellation from hotel, lead time, arrival month, market segment, reserved room type, nights, party composition, repeat status, and prior cancellations. These fields have a plausible booking-time role, although this historical extract does not verify immutable booking-time snapshots. Numeric missing values use training medians; categories are encoded as indicator columns and unseen labels are marked unknown. Standardization is fitted on training data for logistic optimization. This preprocessing and held-out evaluation extend the classroom examples without changing the underlying regression methods.

At a prespecified 0.5 cutoff, test accuracy is 65.05%, modestly above the 61.17% baseline. Precision is 59.51% and cancellation recall only 31.28%. The model flags 4,920 actual cancellations and 3,347 completed outcomes incorrectly, while missing 10,810 cancellations. Resort recall is 16.90%, versus City recall of 36.27%. It therefore supports limited prioritization, not reliable screening of every risky booking. No cutoff was selected using test outcomes.

Linear regression uses the same feature set to predict completed-stay ADR. Test MAE falls from 40.11 to 25.63, approximately a 36% reduction. Test R² is 0.529, meaning improvement relative to the evaluated mean reference rather than 52.9% accuracy. Resort MAE is 29.43 versus City MAE of 23.43. Conditional coefficients associate an additional adult with 12.51 higher ADR and an additional lead-time day with 0.040 lower ADR, holding encoded predictors fixed; these are not causal pricing instructions.

Actual-versus-predicted and residual charts diagnose prediction errors. Positive residuals indicate underprediction. The model produces 94 negative rates, exposing a limitation of an unconstrained straight line. Excluding zero-rate test stays gives MAE 25.45, so that subgroup alone does not explain the overall error. Individual booking errors, time drift, and completed-stay selection remain important limitations.

The residual chart shows larger spread at higher predicted rates and a separate zero-rate band, so constant-error assumptions are questionable. Underprediction of some expensive stays limits high-end pricing use. Removing identical source rows from test weighting leaves cancellation accuracy at 68.14%, barely above its 67.96% baseline, with recall 21.20%. ADR MAE remains improved, 26.29 versus 42.30. Thus cancellation usefulness is sensitive to repeated-record weighting, while the pricing improvement persists; neither check resolves whether repeated records are valid bookings.


## 6. Recommendation

Use the cancellation model as a cautious pilot for confirmation reminders or manual review, especially in higher-risk historical lead-time and segment groups. Do not use it alone to deny bookings or prescribe overbooking: it misses most cancellations and many flagged bookings are not canceled. Establish intervention costs and compare a pilot with usual practice before changing policy.

For pricing, use the regression as an approximate reference to investigate unusually priced completed stays. Its lower error than the mean baseline is useful, but resort predictions are less precise and negative predictions require review. Seasonal and room-related associations justify further pricing investigation, not automatic increases. Assess occupancy, margins, and competing offers before testing a rate change.

Confidence is stronger in the descriptive patterns and measured later-period performance than in causal claims or future stability. The data cover only two hotels and end in 2017. External changes, repeated records, missing booking-time snapshots, and selection of completed stays limit transfer to current operations. Monitor performance and use prospective evaluation before deployment.

## Submission check

Restart the Colab runtime and run all cells in order with `hotels.csv` in the working directory. Verify your name and AI disclosure, then submit this notebook and the CSV. Code comments do not count toward the narrative word limit.
