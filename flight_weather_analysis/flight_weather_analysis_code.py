# =====================================================================
# Flight & Weather Delay Analysis - full Python code (Google Colab)
# HOW TO USE:
#   1. Easiest: open Flight_Weather_Delay_Analysis.ipynb in Colab (same code + narrative).
#   2. Or: new Colab notebook, upload Flight.csv and weather.csv (folder icon, left),
#      paste each CELL below into its own code cell, in order, and run.
#   Optional: also upload Flight_and_Weather_-_working.xlsx and CELL 4 confirms
#   the Python join matches your Excel VLOOKUP (1,769 unmatched).
# =====================================================================

# ===== CELL 1: SETUP - imports and chart style =====
# ---- Imports ----
import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as mtick
import seaborn as sns
from scipy import stats
import statsmodels.formula.api as smf
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score, roc_auc_score, roc_curve

import warnings
warnings.filterwarnings("ignore")

# ---- Chart style: one consistent, colorblind-checked palette across the notebook ----
BLUE, ORANGE, AQUA, GREY = "#2a78d6", "#eb6834", "#1baf7a", "#8a8984"
INK, INK2 = "#0b0b0b", "#52514e"
plt.rcParams.update({
    "figure.dpi": 110, "figure.facecolor": "white", "axes.facecolor": "white",
    "axes.edgecolor": "#c9c8c3", "axes.labelcolor": INK2, "axes.titleweight": "bold",
    "axes.titlesize": 12, "axes.titlecolor": INK, "axes.spines.top": False, "axes.spines.right": False,
    "axes.grid": True, "grid.color": "#ecebe8", "grid.linewidth": 0.8, "axes.axisbelow": True,
    "xtick.color": INK2, "ytick.color": INK2, "legend.frameon": False, "font.size": 10,
})
pd.set_option("display.float_format", lambda v: f"{v:,.2f}")
RNG = np.random.default_rng(42)

# ===== CELL 2: LOAD both raw CSV files (Flight.csv, weather.csv) =====
# ---- Load both raw CSV files exactly as exported from Excel ----
# In Colab: upload Flight.csv and weather.csv via the file panel, or run this cell and pick both files.
FILES = ["Flight.csv", "weather.csv"]
if not all(os.path.exists(f) for f in FILES):
    try:
        from google.colab import files
        print("Please upload Flight.csv and weather.csv")
        files.upload()
    except ImportError:
        raise FileNotFoundError("Put Flight.csv and weather.csv in the same folder as this notebook.")

# encoding="utf-8-sig" strips the invisible Excel byte-order mark from the first column name
flights_raw = pd.read_csv("Flight.csv", encoding="utf-8-sig")
# weather.csv has a junk first row (column numbers 1..16); the real header is on row 2
weather_raw = pd.read_csv("weather.csv", encoding="utf-8-sig", header=1)

print(f"Flight.csv : {flights_raw.shape[0]:,} rows x {flights_raw.shape[1]} columns")
print(f"weather.csv: {weather_raw.shape[0]:,} rows x {weather_raw.shape[1]} columns")
display(flights_raw.head(3))
display(weather_raw.head(3))

# ===== CELL 3: LOAD - fix export problems + check keys =====
# ---- Load-time fixes (logged in the cleaning table later) ----
empty_cols = [c for c in flights_raw.columns if flights_raw[c].isna().all()]
print(f"Flight.csv has {len(empty_cols)} completely empty columns left over from Excel -> dropped: {empty_cols}")
flights = flights_raw.drop(columns=empty_cols)

# 'date' repeats year/month/day/hour as text, so it is redundant
weather = weather_raw.drop(columns=["date"])

# Sanity checks on the keys we built in Excel
KEYS = ["origin", "year", "month", "day", "hour"]
rebuilt = weather["origin"] + "-" + weather[KEYS[1:]].astype(str).agg("-".join, axis=1)
print("Key_Weather matches origin-year-month-day-hour on every row:", (rebuilt == weather["Key_Weather"]).all())
print("Duplicate weather keys:", weather["Key_Weather"].duplicated().sum())
cover = weather.groupby("origin").size()
print(f"Weather hours per airport: {cover.to_dict()} (a full year is 8,760) -> "
      f"{(8760 - cover).to_dict()} hours missing")
dates = pd.to_datetime(weather[["year", "month", "day"]])
print(f"Weather runs {dates.min():%d %b} to {dates.max():%d %b %Y}; flights run to 31 Dec -> 31 Dec has no weather at all")

# ===== CELL 4: REQ 1 - JOIN flights to weather (left join on Excel key, like VLOOKUP) =====
# ---- Join: LEFT join flights -> weather on the key built in Excel (same logic as our VLOOKUP) ----
# Key_Flight / Key_Weather = origin-year-month-day-hour, e.g. "SEA-2014-1-1-0"; cancelled flights have hour "NA"
df = flights.merge(weather.drop(columns=KEYS), left_on="Key_Flight", right_on="Key_Weather",
                   how="left", indicator=True, validate="many_to_one")   # many flights -> one weather hour
assert len(df) == len(flights), "join changed the number of flights"

matched = (df["_merge"] == "both")
print(f"Flights in:            {len(flights):,}")
print(f"Matched to weather:    {matched.sum():,} ({matched.mean():.1%})")
print(f"No weather match:      {(~matched).sum():,} ({(~matched).mean():.1%})")
print(f"Weather hours never used (no departures that hour, mostly overnight): {len(weather) - df['Key_Weather'].nunique():,}")

# Cross-check 1: joining on the five separate columns gives the same answer as the text key
check = flights.merge(weather.assign(hour=weather["hour"].astype(float))[KEYS].assign(found=1), on=KEYS, how="left")
print("Multi-column join gives identical matches:", check["found"].notna().sum() == matched.sum())

# Cross-check 2 (optional): our Excel VLOOKUP result, if the workbook is uploaded too
EXCEL = "Flight_and_Weather_-_working.xlsx"
if os.path.exists(EXCEL):
    xl_miss = pd.read_excel(EXCEL).iloc[:, -1].isna().sum()   # last column = key returned by VLOOKUP (blank = no match)
    print(f"Excel VLOOKUP left {xl_miss:,} flights without weather -> Python agrees: {xl_miss == (~matched).sum()}")
df = df.drop(columns=["Key_Flight", "Key_Weather"])

# ===== CELL 5: REQ 1 - what the join cost: unmatched rows and what they have in common =====
# ---- Do the unmatched rows have anything in common? ----
um = df[~matched].copy()
um["reason"] = np.select(
    [um["dep_time"].isna(), um["hour"].eq(24)],
    ["Cancelled (no departure hour)", "Departed at 24:00 (hour=24)"],
    default="Weather hour missing",
)
reason_tbl = um["reason"].value_counts().rename("flights").to_frame()
reason_tbl["share_of_unmatched"] = reason_tbl["flights"] / len(um)
display(reason_tbl)

gaps = um[um["reason"] == "Weather hour missing"]
gap_dates = (gaps.assign(date=pd.to_datetime(gaps[["year", "month", "day"]]))
                 .groupby("date").size().sort_values(ascending=False))
print(f"Weather-gap flights fall on {gap_dates.size} dates; top 5 dates hold {gap_dates.head(5).sum() / gap_dates.sum():.0%} of them")
print("Unmatched share by airport:", (~matched).groupby(df["origin"]).mean().round(4).to_dict())

fig, axes = plt.subplots(1, 2, figsize=(12, 3.8))
reason_tbl["flights"].sort_values().plot.barh(ax=axes[0], color=[GREY, BLUE, ORANGE][:len(reason_tbl)], width=0.6)
axes[0].set_title("Why 1.1% of flights got no weather")
axes[0].set_xlabel("Flights"); axes[0].set_ylabel("")
for i, v in enumerate(reason_tbl["flights"].sort_values()):
    axes[0].text(v + 10, i, f"{v:,}", va="center", color=INK2)
top = gap_dates.head(10).sort_values()
axes[1].barh(top.index.strftime("%d %b"), top.values, color=ORANGE, height=0.6)
axes[1].set_title("Weather gaps cluster on a few dates")
axes[1].set_xlabel("Flights without weather")
plt.tight_layout(); plt.show()

# ===== CELL 6: REQ 2 - what the data contains + missing values =====
# ---- What does the combined table contain? ----
print(f"{df.shape[0]:,} rows, {df.shape[1]-1} columns | {df['origin'].nunique()} origins, "
      f"{df['dest'].nunique()} destinations, {df['carrier'].nunique()} carriers, year {df['year'].unique()}")
display(df.drop(columns="_merge").describe().T[["count", "mean", "50%", "min", "max"]])

# ---- Missing values ----
miss = df.drop(columns="_merge").isna().mean().sort_values(ascending=False)
miss = miss[miss > 0]
fig, ax = plt.subplots(figsize=(9, 3.8))
ax.barh(miss.index[::-1], miss.values[::-1], color=BLUE, height=0.6)
ax.xaxis.set_major_formatter(mtick.PercentFormatter(1))
ax.set_title("Share of missing values by column")
for i, v in enumerate(miss.values[::-1]):
    ax.text(v + 0.002, i, f"{v:.1%}", va="center", fontsize=8, color=INK2)
plt.tight_layout(); plt.show()

# ===== CELL 7: REQ 2 - things that look wrong =====
# ---- Things that look wrong ----
print("Dew point > 100F (impossible for this climate):", (df["dewp"] > 100).sum(), "rows, value(s):", df.loc[df["dewp"] > 100, "dewp"].unique())
ratio = (weather["wind_gust"] / weather["wind_speed"]).replace([np.inf], np.nan).dropna()
print(f"wind_gust / wind_speed ratio: min {ratio.min():.4f}, max {ratio.max():.4f}  -> gust is a copy of speed x 1.15")
print("Flights with hour = 24:", df["hour"].eq(24).sum())
print("pressure missing:", f"{df['pressure'].isna().mean():.1%}")
print(f"dep_delay: median {df['dep_delay'].median():.0f} min, mean {df['dep_delay'].mean():.1f} min, "
      f"99th pct {df['dep_delay'].quantile(.99):.0f} min, max {df['dep_delay'].max():.0f} min")

# ===== CELL 8: REQ 2 - cleaning (every decision logged) =====
# ---- Cleaning (every step logged) ----
log = [["Dropped 9 empty columns in Flight.csv", "Blank columns left over from Excel", len(empty_cols)],
       ["Skipped junk first row in weather.csv", "Row of column numbers above the real header", 1],
       ["Dropped weather 'date' text column", "Repeats year/month/day/hour", len(weather)]]
clean = df.drop(columns="_merge").copy()

before = clean["dewp"].corr(clean["dep_delay"])
n = (clean["dewp"] > 100).sum(); clean.loc[clean["dewp"] > 100, "dewp"] = np.nan
log.append(["Dew point > 100F set to missing", "Physically impossible (sensor/entry error)", n])

n = clean["hour"].eq(24).sum(); clean.loc[clean["hour"].eq(24), "hour"] = 0
log.append(["hour 24 recoded to 0", "24:00 is midnight; keeps hour in 0-23", n])

clean["cancelled"] = clean["dep_time"].isna()
n = clean["cancelled"].sum()
log.append(["Cancelled flights excluded from delay analysis", "No delay exists to measure; reported separately", n])

clean = clean.drop(columns=["wind_gust", "pressure"])
log.append(["Dropped wind_gust", "Exact copy of wind_speed x 1.15, adds no information", len(clean)])
log.append(["Dropped pressure", f"{df['pressure'].isna().mean():.0%} missing; imputing would invent data", len(clean)])

n = clean["tailnum"].isna().sum()
log.append(["Kept rows with missing tailnum", "Aircraft ID is not used in the analysis", n])

clean["delayed15"] = (clean["dep_delay"] > 15).astype(int)   # industry (FAA) definition of a delay
clean["season"] = clean["month"].map({12: "Winter", 1: "Winter", 2: "Winter", 3: "Spring", 4: "Spring", 5: "Spring",
                                      6: "Summer", 7: "Summer", 8: "Summer", 9: "Autumn", 10: "Autumn", 11: "Autumn"})
log.append(["Added delayed15 flag and season", "FAA defines 'delayed' as >15 min; season aids grouping", len(clean)])

# 'hour' is the ACTUAL departure hour (dep_time // 100), so a late flight moves into a later hour.
# Using it to explain delay is circular (leakage). Rebuild the SCHEDULED hour = actual time - delay.
dep_min = (clean["dep_time"] // 100) * 60 + clean["dep_time"] % 100
clean["sched_hour"] = (((dep_min - clean["dep_delay"]) % 1440) // 60)
n = (clean["sched_hour"] != clean["hour"]).sum()
log.append(["Added sched_hour (scheduled departure hour)", "'hour' is actual departure hour; it leaks the delay", n])
print("Mean delay of flights that ACTUALLY left 1-4am:", round(clean.loc[clean.hour.between(1, 4), "dep_delay"].mean()),
      "min; flights SCHEDULED 1-4am:", (clean["sched_hour"].between(1, 4)).sum())

# Analysis set: flights that departed AND have weather
flown = clean[~clean["cancelled"] & clean["temp"].notna()].copy()
log.append(["Analysis set = departed flights with weather", "Needed for weather comparisons and the model", len(flown)])

cleaning_log = pd.DataFrame(log, columns=["Decision", "Why", "Rows affected"])
display(cleaning_log)

print(f"Dew point vs delay correlation: before fix {before:.4f}, after fix {clean['dewp'].corr(clean['dep_delay']):.4f}")
cap = flown["dep_delay"].clip(upper=flown["dep_delay"].quantile(.99))
print(f"Mean delay with all flights {flown['dep_delay'].mean():.2f} min vs. capped at 99th pct {cap.mean():.2f} min "
      "-> extreme delays are real events, kept in the data")

# ===== CELL 9: REQ 2 - shape of the target (delay distribution) =====
# ---- Shape of the target: most flights leave early, a few are very late ----
fig, axes = plt.subplots(1, 2, figsize=(12, 3.8))
axes[0].hist(flown["dep_delay"].clip(-30, 180), bins=70, color=BLUE, edgecolor="white", linewidth=0.5)
for v, lab, c in [(flown["dep_delay"].median(), "median", INK), (flown["dep_delay"].mean(), "mean", ORANGE)]:
    axes[0].axvline(v, color=c, lw=1.5, ls="--")
axes[0].text(12, axes[0].get_ylim()[1] * .9, f"median {flown['dep_delay'].median():.0f} min", color=INK)
axes[0].text(12, axes[0].get_ylim()[1] * .8, f"mean {flown['dep_delay'].mean():.1f} min", color=ORANGE)
axes[0].set_title("Departure delay (clipped at -30 / 180 min)")
axes[0].set_xlabel("Minutes (negative = early)"); axes[0].set_ylabel("Flights")

# Pareto: what share of all delay minutes comes from the worst flights?
late = np.sort(flown["dep_delay"].clip(lower=0).values)[::-1]
cum = np.cumsum(late) / late.sum()
x = np.arange(1, len(late) + 1) / len(late)
axes[1].plot(x, cum, color=BLUE, lw=2)
share5 = cum[int(len(late) * .05) - 1]
axes[1].scatter([.05], [share5], color=ORANGE, s=50, zorder=3)
axes[1].annotate(f"worst 5% of flights = {share5:.0%} of delay minutes", (.05, share5), xytext=(.2, share5 - .15),
                 color=INK, arrowprops=dict(arrowstyle="-", color=INK2))
axes[1].xaxis.set_major_formatter(mtick.PercentFormatter(1)); axes[1].yaxis.set_major_formatter(mtick.PercentFormatter(1))
axes[1].set_title("Delay minutes are concentrated in few flights")
axes[1].set_xlabel("Share of flights (worst first)"); axes[1].set_ylabel("Share of all delay minutes")
plt.tight_layout(); plt.show()

# ===== CELL 10: REQ 3 - BASELINE (simplest possible answer) =====
# ---- Baseline: predict the same number for every flight ----
FEATURES = ["dep_delay", "delayed15", "sched_hour", "month", "carrier", "origin", "season",
            "visib", "wind_speed", "precip", "humid", "temp", "distance"]
model_df = flown[FEATURES].dropna().copy()
model_df["hour"] = model_df.pop("sched_hour").astype(int)   # models use the SCHEDULED hour
train, test = train_test_split(model_df, test_size=0.2, random_state=42)
print(f"Train {len(train):,} flights | Test {len(test):,} flights")

def scores(y, pred):
    return {"MAE (min)": mean_absolute_error(y, pred),
            "RMSE (min)": mean_squared_error(y, pred) ** 0.5,
            "R2": r2_score(y, pred)}

baseline = pd.DataFrame({
    "Predict the mean": scores(test["dep_delay"], np.full(len(test), train["dep_delay"].mean())),
    "Predict the median": scores(test["dep_delay"], np.full(len(test), train["dep_delay"].median())),
}).T
display(baseline)

base_rate = train["delayed15"].mean()
print(f"Share of flights delayed >15 min (train): {base_rate:.1%}")
print(f"'Every flight is on time' is right {1 - test['delayed15'].mean():.1%} of the time - but catches 0% of delays.")

# ===== CELL 11: REQ 4 - VISUAL: delay by hour of day =====
# ---- Helper: proportion with 95% Wilson confidence interval ----
def prop_ci(s):
    k, n = s.sum(), s.count()
    lo, hi = stats.binomtest(int(k), int(n)).proportion_ci(confidence_level=0.95, method="wilson")
    return pd.Series({"rate": k / n, "lo": lo, "hi": hi, "n": n})

# ---- V1: time of day ----
by_hour = flown.groupby("sched_hour")["delayed15"].apply(prop_ci).unstack()
by_hour = by_hour[by_hour["n"] >= 200]                       # hide hours with too few flights to trust
vol = flown["sched_hour"].value_counts().sort_index().loc[by_hour.index]

fig, axes = plt.subplots(1, 2, figsize=(12, 3.8))
axes[0].bar(vol.index, vol.values, color=GREY, width=0.8)
axes[0].set_title("Scheduled departures by hour"); axes[0].set_xlabel("Scheduled hour"); axes[0].set_ylabel("Flights")
axes[1].fill_between(by_hour.index, by_hour["lo"], by_hour["hi"], color=BLUE, alpha=.2, label="95% CI")
axes[1].plot(by_hour.index, by_hour["rate"], color=BLUE, lw=2, marker="o", ms=4, label="% delayed >15 min")
axes[1].axhline(base_rate, color=INK2, ls="--", lw=1); axes[1].text(5, base_rate + .01, f"average {base_rate:.0%}", color=INK2)
axes[1].yaxis.set_major_formatter(mtick.PercentFormatter(1))
axes[1].set_title("Delay risk builds through the day"); axes[1].set_xlabel("Scheduled hour"); axes[1].legend(loc="upper left")
plt.tight_layout(); plt.show()

# ===== CELL 12: REQ 4 - VISUAL: month x hour heatmap =====
# ---- V2: month x hour heatmap ----
heat = flown[flown["sched_hour"].between(5, 23)].astype({"sched_hour": int}).pivot_table(index="month", columns="sched_hour", values="delayed15", aggfunc="mean")
fig, ax = plt.subplots(figsize=(12, 4.2))
sns.heatmap(heat, cmap="Blues", ax=ax, cbar_kws={"format": mtick.PercentFormatter(1), "label": "% delayed >15 min"},
            linewidths=1, linecolor="white")
ax.set_yticklabels(["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"], rotation=0)
ax.set_title("Where the risk sits: afternoons and evenings, worst in Dec, Feb and Jun-Jul"); ax.set_xlabel("Scheduled departure hour"); ax.set_ylabel("")
plt.tight_layout(); plt.show()

# ===== CELL 13: REQ 4 - VISUAL: carriers and SEA vs PDX =====
# ---- V3: carriers (with 95% CI) and V4: airport by month ----
by_car = flown.groupby("carrier")["delayed15"].apply(prop_ci).unstack().sort_values("rate")
fig, axes = plt.subplots(1, 2, figsize=(12, 4.2))
ax = axes[0]
ax.hlines(range(len(by_car)), by_car["lo"], by_car["hi"], color=BLUE, lw=2)
ax.scatter(by_car["rate"], range(len(by_car)), color=BLUE, s=40, zorder=3)
ax.axvline(base_rate, color=INK2, ls="--", lw=1)
ax.set_yticks(range(len(by_car))); ax.set_yticklabels([f"{c}  (n={int(n):,})" for c, n in zip(by_car.index, by_car["n"])])
ax.xaxis.set_major_formatter(mtick.PercentFormatter(1))
ax.set_title("Carrier delay rate, 95% CI"); ax.set_xlabel("% delayed >15 min")

by_m = flown.groupby(["month", "origin"])["delayed15"].mean().unstack()
for col, c in [("SEA", BLUE), ("PDX", ORANGE)]:
    axes[1].plot(by_m.index, by_m[col], color=c, lw=2, marker="o", ms=4)
    axes[1].text(12.2, by_m[col].iloc[-1], col, color=c, va="center", fontweight="bold")
axes[1].set_xticks(range(1, 13)); axes[1].set_xticklabels(list("JFMAMJJASOND"))
axes[1].yaxis.set_major_formatter(mtick.PercentFormatter(1))
axes[1].set_title("Seasonality: Seattle vs Portland"); axes[1].set_xlabel("Month")
plt.tight_layout(); plt.show()

# ===== CELL 14: REQ 4 - VISUAL: weather bands =====
# ---- V5: does weather matter? Delay rate across weather bands ----
bands = {
    "visib": ([-0.1, 1, 3, 6, 9.9, 10], ["<1", "1-3", "3-6", "6-10", "10 (clear)"], "Visibility (miles)"),
    "wind_speed": ([-0.1, 5, 10, 15, 20, 40], ["0-5", "5-10", "10-15", "15-20", "20+"], "Wind speed (mph)"),
    "precip": ([-0.01, 0, 0.02, 0.05, 1], ["none", "trace", "light", "heavier"], "Precipitation (in/hr)"),
    "temp": ([0, 32, 45, 60, 75, 100], ["<32 (freezing)", "32-45", "45-60", "60-75", "75+"], "Temperature (F)"),
}
fig, axes = plt.subplots(1, 4, figsize=(15, 3.8), sharey=True)
for ax, (col, (bins, labels, title)) in zip(axes, bands.items()):
    g = flown.assign(b=pd.cut(flown[col], bins, labels=labels)).groupby("b", observed=True)["delayed15"].apply(prop_ci).unstack()
    ax.bar(range(len(g)), g["rate"], color=BLUE, width=0.6)
    ax.errorbar(range(len(g)), g["rate"], yerr=[g["rate"] - g["lo"], g["hi"] - g["rate"]], fmt="none", ecolor=INK, capsize=3, lw=1)
    ax.set_xticks(range(len(g))); ax.set_xticklabels(g.index, rotation=30, ha="right", fontsize=8)
    for i, n in enumerate(g["n"]):
        ax.text(i, 0.005, f"n={int(n):,}", ha="center", fontsize=7, color="white", rotation=90, va="bottom")
    ax.axhline(base_rate, color=INK2, ls="--", lw=1); ax.set_title(title)
axes[0].yaxis.set_major_formatter(mtick.PercentFormatter(1)); axes[0].set_ylabel("% delayed >15 min")
plt.suptitle("Bad weather raises delay risk only modestly, and only at the extremes", fontweight="bold", y=1.03)
plt.tight_layout(); plt.show()

# ===== CELL 15: REQ 4 - VISUAL: correlation heatmap =====
# ---- V6: correlation of numeric drivers with delay ----
num = ["dep_delay", "sched_hour", "month", "distance", "temp", "dewp", "humid", "wind_speed", "precip", "visib"]
corr = flown[num].corr()
fig, ax = plt.subplots(figsize=(8, 6))
sns.heatmap(corr, cmap="RdBu_r", vmin=-1, vmax=1, center=0, annot=True, fmt=".2f", annot_kws={"size": 8},
            mask=np.triu(np.ones_like(corr, dtype=bool), 1), linewidths=1, linecolor="white", ax=ax)
ax.set_title("No single variable explains delay (all |r| with dep_delay < 0.1)")
plt.tight_layout(); plt.show()
print(corr["dep_delay"].drop("dep_delay").sort_values(key=abs, ascending=False).round(3))

# ===== CELL 16: REQ 5 - UNCERTAINTY: bootstrap overall estimates =====
# ---- Bootstrap: overall estimates ----
B = 2000
d = flown["dep_delay"].values; f15 = flown["delayed15"].values
boot_mean, boot_rate = [], []
for _ in range(B):
    i = RNG.integers(0, len(d), len(d))
    boot_mean.append(d[i].mean()); boot_rate.append(f15[i].mean())
print(f"Mean delay: {d.mean():.2f} min, 95% CI [{np.percentile(boot_mean, 2.5):.2f}, {np.percentile(boot_mean, 97.5):.2f}]")
print(f"% delayed >15: {f15.mean():.2%}, 95% CI [{np.percentile(boot_rate, 2.5):.2%}, {np.percentile(boot_rate, 97.5):.2%}]")

# ===== CELL 17: REQ 5 - UNCERTAINTY: key comparisons with 95% CI =====
# ---- Comparisons that drive the recommendation: difference in delay rate with 95% CI ----
def diff_ci(a, b):
    """Difference in proportions a - b with a normal-approximation 95% CI and two-proportion z-test p-value."""
    p1, p2, n1, n2 = a.mean(), b.mean(), len(a), len(b)
    se = np.sqrt(p1 * (1 - p1) / n1 + p2 * (1 - p2) / n2)
    pooled = (a.sum() + b.sum()) / (n1 + n2)
    z = (p1 - p2) / np.sqrt(pooled * (1 - pooled) * (1 / n1 + 1 / n2))
    return {"diff": p1 - p2, "lo": p1 - p2 - 1.96 * se, "hi": p1 - p2 + 1.96 * se, "p": 2 * stats.norm.sf(abs(z)), "n_a": n1, "n_b": n2}

F = flown
comparisons = pd.DataFrame({
    "Evening (17-23h) vs morning (5-9h)": diff_ci(F.loc[F.sched_hour.between(17, 23), "delayed15"], F.loc[F.sched_hour.between(5, 9), "delayed15"]),
    "Low visibility (<3 mi) vs clear": diff_ci(F.loc[F.visib < 3, "delayed15"], F.loc[F.visib >= 10, "delayed15"]),
    "Freezing (<32F) vs not": diff_ci(F.loc[F.temp < 32, "delayed15"], F.loc[F.temp >= 32, "delayed15"]),
    "Wind 20+ mph vs <20": diff_ci(F.loc[F.wind_speed >= 20, "delayed15"], F.loc[F.wind_speed < 20, "delayed15"]),
    "Any precipitation vs none": diff_ci(F.loc[F.precip > 0, "delayed15"], F.loc[F.precip == 0, "delayed15"]),
    "December vs rest of year": diff_ci(F.loc[F.month == 12, "delayed15"], F.loc[F.month != 12, "delayed15"]),
    "SEA vs PDX": diff_ci(F.loc[F.origin == "SEA", "delayed15"], F.loc[F.origin == "PDX", "delayed15"]),
}).T.sort_values("diff")
display(comparisons.style.format({"diff": "{:+.1%}", "lo": "{:+.1%}", "hi": "{:+.1%}", "p": "{:.1e}", "n_a": "{:,.0f}", "n_b": "{:,.0f}"}))

fig, ax = plt.subplots(figsize=(10, 4))
y = range(len(comparisons))
sig = comparisons["lo"].gt(0) | comparisons["hi"].lt(0)
ax.hlines(y, comparisons["lo"], comparisons["hi"], color=[BLUE if s else GREY for s in sig], lw=3)
ax.scatter(comparisons["diff"], y, color=[BLUE if s else GREY for s in sig], s=50, zorder=3)
ax.axvline(0, color=INK, lw=1)
ax.set_yticks(list(y)); ax.set_yticklabels(comparisons.index)
ax.xaxis.set_major_formatter(mtick.PercentFormatter(1, decimals=0))
ax.set_title("Change in delay rate (percentage points), 95% CI - grey = not distinguishable from zero")
plt.tight_layout(); plt.show()

# ===== CELL 18: REQ 5 - UNCERTAINTY: bootstrap check of biggest effect =====
# ---- Bootstrap check of the biggest effect (evening vs morning), no normality assumption ----
eve = F.loc[F.sched_hour.between(17, 23), "delayed15"].values; mor = F.loc[F.sched_hour.between(5, 9), "delayed15"].values
boot = np.array([RNG.choice(eve, len(eve)).mean() - RNG.choice(mor, len(mor)).mean() for _ in range(2000)])
lo, hi = np.percentile(boot, [2.5, 97.5])
fig, ax = plt.subplots(figsize=(8, 3.2))
ax.hist(boot, bins=50, color=BLUE, edgecolor="white")
for v in (lo, hi): ax.axvline(v, color=ORANGE, ls="--")
ax.xaxis.set_major_formatter(mtick.PercentFormatter(1, decimals=1))
ax.set_title(f"2,000 bootstrap resamples: evening - morning = {boot.mean():+.1%} (95% CI {lo:+.1%} to {hi:+.1%})")
ax.set_xlabel("Difference in % delayed"); plt.tight_layout(); plt.show()

# ===== CELL 19: REQ 6 - MODEL: compare models step by step =====
# ---- Build models step by step and keep only what helps on unseen data ----
specs = {
    "1. Weather only":            "dep_delay ~ visib + wind_speed + precip + humid + temp",
    "2. Time only":               "dep_delay ~ C(hour) + C(month)",
    "3. Time + carrier + airport": "dep_delay ~ C(hour) + C(month) + C(carrier) + origin",
    "4. Full (3 + weather)":      "dep_delay ~ C(hour) + C(month) + C(carrier) + origin + visib + wind_speed + precip + humid + temp + distance",
}
rows, fitted = {}, {}
for name, f in specs.items():
    m = smf.ols(f, data=train).fit()
    fitted[name] = m
    rows[name] = {**scores(test["dep_delay"], m.predict(test)), "Train R2": m.rsquared, "Parameters": len(m.params)}
results = pd.concat([baseline.assign(**{"Train R2": 0.0, "Parameters": 1}), pd.DataFrame(rows).T])
display(results)

fig, axes = plt.subplots(1, 2, figsize=(12, 3.8))
colors = [GREY, GREY] + [BLUE] * len(specs)
axes[0].barh(results.index[::-1], results["MAE (min)"][::-1], color=colors[::-1], height=0.6)
axes[0].set_xlim(results["MAE (min)"].min() * .95, results["MAE (min)"].max() * 1.01)
axes[0].set_title("Test error (MAE, lower is better)"); axes[0].set_xlabel("Minutes")
axes[1].barh(results.index[::-1], results["R2"][::-1], color=colors[::-1], height=0.6)
axes[1].set_title("Test R² (share of variation explained)"); axes[1].set_yticklabels([])
plt.tight_layout(); plt.show()

# ===== CELL 20: REQ 6 - MODEL: which effects are real =====
# ---- The final linear model: which effects are real? ----
ols = fitted["4. Full (3 + weather)"]
ci = ols.conf_int()
coef = pd.DataFrame({"coef": ols.params, "lo": ci[0], "hi": ci[1], "p": ols.pvalues}).drop("Intercept")
label = lambda i: i.replace("C(", "").replace(")[T.", " = ").replace("[T.", " = ").replace("]", "")

fig, axes = plt.subplots(1, 2, figsize=(13, 5))
# Left: hour-of-day effect curve (reference = earliest scheduled hour)
hr = coef[coef.index.str.startswith("C(hour)")].copy()
hr.index = hr.index.str.extract(r"T\.(\d+)")[0].astype(int).values
hr = hr.sort_index()
axes[0].fill_between(hr.index, hr["lo"], hr["hi"], color=BLUE, alpha=.2)
axes[0].plot(hr.index, hr["coef"], color=BLUE, marker="o", ms=4, lw=2)
axes[0].axhline(0, color=INK, lw=1)
axes[0].set_title("Hour effect vs earliest hour, holding all else equal"); axes[0].set_xlabel("Scheduled hour"); axes[0].set_ylabel("Extra minutes of delay")
# Right: carrier, airport and month effects
other = coef[coef.index.str.contains("carrier|origin|month")].sort_values("coef")
sig = other["p"] < 0.05
axes[1].hlines(range(len(other)), other["lo"], other["hi"], color=[BLUE if x else GREY for x in sig], lw=2.5)
axes[1].scatter(other["coef"], range(len(other)), color=[BLUE if x else GREY for x in sig], s=35, zorder=3)
axes[1].axvline(0, color=INK, lw=1)
axes[1].set_yticks(range(len(other))); axes[1].set_yticklabels([label(i) for i in other.index], fontsize=8)
axes[1].set_title("Carrier / airport / month (vs AA, PDX, Jan), 95% CI"); axes[1].set_xlabel("Extra minutes of delay")
plt.tight_layout(); plt.show()

print("Weather effects (minutes per unit, holding time/carrier/airport fixed):")
display(coef.loc[["visib", "wind_speed", "precip", "humid", "temp", "distance"]])

# ===== CELL 21: REQ 6 - MODEL: where the model fails =====
# ---- Where the model fails ----
pred = ols.predict(test); resid = test["dep_delay"] - pred
fig, axes = plt.subplots(1, 3, figsize=(15, 4))
hb = axes[0].hexbin(pred, test["dep_delay"].clip(-30, 300), gridsize=40, bins="log", cmap="Blues", mincnt=1)
axes[0].plot([-10, 30], [-10, 30], color=ORANGE, lw=1.5)
axes[0].set_title("Predicted vs actual"); axes[0].set_xlabel("Predicted delay (min)"); axes[0].set_ylabel("Actual (clipped at 300)")

buckets = pd.cut(test["dep_delay"], [-100, 0, 15, 60, 180, 2000], labels=["early/on time", "1-15", "16-60", "61-180", "180+"])
err = pd.DataFrame({"b": buckets, "abs_err": resid.abs(), "bias": resid}).groupby("b", observed=True).agg(
    MAE=("abs_err", "mean"), bias=("bias", "mean"), share=("abs_err", "size"))
err["share"] /= err["share"].sum()
axes[1].bar(err.index.astype(str), err["MAE"], color=BLUE, width=0.6)
for i, (m_, s_) in enumerate(zip(err["MAE"], err["share"])):
    axes[1].text(i, m_ + 3, f"{s_:.1%} of flights", ha="center", fontsize=8, color=INK2)
axes[1].set_title("Error explodes for long delays"); axes[1].set_xlabel("Actual delay (min)"); axes[1].set_ylabel("MAE (min)")

stats.probplot(resid.sample(5000, random_state=1), dist="norm", plot=axes[2])
axes[2].get_lines()[0].set(color=BLUE, markersize=2); axes[2].get_lines()[1].set(color=ORANGE)
axes[2].set_title("Residuals are far from normal (heavy right tail)")
plt.tight_layout(); plt.show()
display(err)

# ===== CELL 22: REQ 6 - MODEL: probability of delay (logistic) =====
# ---- A more useful framing: probability a flight is delayed >15 min (logistic regression) ----
logit = smf.logit("delayed15 ~ C(hour) + C(month) + C(carrier) + origin + visib + wind_speed + precip + humid + temp + distance",
                  data=train).fit(disp=0)
p_test = logit.predict(test)
auc = roc_auc_score(test["delayed15"], p_test)
fpr, tpr, _ = roc_curve(test["delayed15"], p_test)

test_r = test.assign(p=p_test, risk_decile=pd.qcut(p_test, 10, labels=range(1, 11)))
lift = test_r.groupby("risk_decile", observed=True).agg(predicted=("p", "mean"), actual=("delayed15", "mean"))

fig, axes = plt.subplots(1, 2, figsize=(12, 4))
axes[0].plot(fpr, tpr, color=BLUE, lw=2, label=f"model, AUC = {auc:.2f}")
axes[0].plot([0, 1], [0, 1], color=GREY, ls="--", label="baseline (coin flip), AUC = 0.50")
axes[0].set_title("Ranking flights by delay risk"); axes[0].set_xlabel("False positive rate"); axes[0].set_ylabel("True positive rate")
axes[0].legend(loc="lower right")
axes[1].bar(lift.index.astype(int), lift["actual"], color=BLUE, width=0.6, label="actual")
axes[1].plot(lift.index.astype(int), lift["predicted"], color=ORANGE, marker="o", lw=2, label="predicted")
axes[1].axhline(test["delayed15"].mean(), color=INK2, ls="--", lw=1)
axes[1].yaxis.set_major_formatter(mtick.PercentFormatter(1))
axes[1].set_title("Top-risk 10% of flights vs bottom 10%"); axes[1].set_xlabel("Risk decile (1 = lowest)"); axes[1].legend()
plt.tight_layout(); plt.show()
print(f"AUC {auc:.3f} | top decile delay rate {lift['actual'].iloc[-1]:.1%} vs bottom decile {lift['actual'].iloc[0]:.1%} "
      f"(average {test['delayed15'].mean():.1%}) -> {lift['actual'].iloc[-1] / test['delayed15'].mean():.1f}x lift")
