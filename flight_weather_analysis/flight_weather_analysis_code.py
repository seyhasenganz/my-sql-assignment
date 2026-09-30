# Flight & Weather Delay Analysis - all code from Flight_Weather_Delay_Analysis.ipynb
# Upload Flight.csv and weather.csv to Colab, then run each CELL in order.

# ===== CELL 1 | 0. Setup =====
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from scipy import stats
import statsmodels.formula.api as smf

# ===== CELL 2 | 1. The data =====
# Upload Flight.csv and weather.csv to Colab first (folder icon on the left)

df_flights = pd.read_csv('Flight.csv')

# weather.csv has an extra row of column numbers (1, 2, 3 ... 16) above the real header
# header=1 tells pandas the real column names are on the second row
df_weather = pd.read_csv('weather.csv', header=1)

print('Flights:', df_flights.shape)
print('Weather:', df_weather.shape)

# ===== CELL 3 | 1. The data =====
df_flights.head()

# ===== CELL 4 | 1. The data =====
df_weather.head()

# ===== CELL 5 | 1. The data =====
# Flight.csv has 9 empty columns left over from Excel (Unnamed: 17 ... Unnamed: 25)
print(df_flights.isnull().sum())

# ===== CELL 6 | 1. The data =====
# Drop columns where every value is missing
df_flights = df_flights.dropna(axis=1, how='all')

# 'date' in the weather file repeats year, month, day and hour, so we do not need it
df_weather = df_weather.drop(columns='date')

print('Flights:', df_flights.shape)
print('Weather:', df_weather.shape)

# ===== CELL 7 | 2. Combining the sources =====
# Is each weather hour listed only once? If not, the join would duplicate flights
print('Duplicate weather keys:', df_weather['Key_Weather'].duplicated().sum())

# How many hours of weather does each airport have? A full year is 365 x 24 = 8,760
print(df_weather.groupby('origin').size())

# ===== CELL 8 | 2. Combining the sources =====
# Left join: keep every flight, add weather where the key matches
# Key_Flight and Key_Weather = origin-year-month-day-hour, e.g. SEA-2014-1-1-0 (same key as our Excel VLOOKUP)
# We only bring across the weather measurements - origin, year, month, day and hour are already in the flight file

weather_cols = ['Key_Weather', 'temp', 'dewp', 'humid', 'wind_dir', 'wind_speed',
                'wind_gust', 'precip', 'pressure', 'visib']

df = pd.merge(df_flights,
              df_weather[weather_cols],
              left_on='Key_Flight',
              right_on='Key_Weather',
              how='left')

print('Flights before join:', len(df_flights))
print('Rows after join:    ', len(df))

# ===== CELL 9 | 2. Combining the sources =====
# What did the join cost us?
matched = df['Key_Weather'].notnull().sum()
not_matched = df['Key_Weather'].isnull().sum()

print('Matched:    ', matched, f'({matched / len(df):.1%})')
print('Not matched:', not_matched, f'({not_matched / len(df):.1%})')

# Weather hours that no flight used (e.g. overnight when there are no departures)
print('Weather hours with no flight:', len(df_weather) - df['Key_Weather'].nunique())

# ===== CELL 10 | Do the unmatched flights have anything in common? =====
# Do the unmatched flights have anything in common?
unmatched = df[df['Key_Weather'].isnull()]

# 1. Cancelled flights have no departure time, so their key ends in "-NA"
cancelled = unmatched['dep_time'].isnull().sum()

# 2. Flights that left at exactly midnight are recorded as hour 24 - weather uses 0-23
hour_24 = (unmatched['hour'] == 24).sum()

# 3. The rest: flights in an hour that is missing from the weather file
missing_weather = not_matched - cancelled - hour_24

print('Cancelled flights:           ', cancelled)
print('Hour recorded as 24:         ', hour_24)
print('Hour missing in weather file:', missing_weather)

# ===== CELL 11 | Do the unmatched flights have anything in common? =====
# Which dates are missing weather?
missing = unmatched[unmatched['dep_time'].notnull() & (unmatched['hour'] != 24)]
missing_dates = missing.groupby(['month', 'day']).size().sort_values(ascending=False)
print(missing_dates.head(10))

# The weather file stops on 30 December
print('Last weather day:', df_weather[df_weather['month'] == 12]['day'].max())

# ===== CELL 12 | Do the unmatched flights have anything in common? =====
missing_dates.head(10).sort_values().plot(kind='barh')
plt.title('Flights without weather, by date (month, day)')
plt.xlabel('Number of flights')
plt.show()

# ===== CELL 13 | Do the unmatched flights have anything in common? =====
# Does the Python join agree with the Excel VLOOKUP?
# Optional: only runs if the Excel file is also uploaded to Colab
import os
if os.path.exists('Flight_and_Weather_-_working.xlsx'):
    df_excel = pd.read_excel('Flight_and_Weather_-_working.xlsx')
    # the last column of the Excel sheet is the key returned by VLOOKUP (blank = no match)
    print('Excel VLOOKUP - flights without weather:', df_excel.iloc[:, -1].isnull().sum())
    print('Python join   - flights without weather:', not_matched)

# ===== CELL 14 | 3. What the data contains and its condition =====
print('Rows and columns:', df.shape)
print('Airports:     ', list(df['origin'].unique()))
print('Carriers:     ', df['carrier'].nunique())
print('Destinations: ', df['dest'].nunique())
print('Year:         ', list(df['year'].unique()))

# ===== CELL 15 | 3. What the data contains and its condition =====
df.describe().round(1)

# ===== CELL 16 | 3. What the data contains and its condition =====
# Missing values in each column
df.isnull().sum()

# ===== CELL 17 | Things that look wrong =====
# Problem 1: dew point of 3,282 F is impossible (the maximum ever recorded on Earth is about 95 F)
print(df['dewp'].describe())
print('Rows with dew point above 100:', (df['dewp'] > 100).sum())

# ===== CELL 18 | Things that look wrong =====
# Problem 2: wind_gust is always exactly 1.15 x wind_speed, so it is not a real measurement
ratio = df_weather['wind_gust'] / df_weather['wind_speed']
print(ratio.describe())

# ===== CELL 19 | Things that look wrong =====
# Problem 3: pressure is missing for many flights
print('Share of flights missing pressure:', round(df['pressure'].isnull().mean() * 100, 1), '%')

# ===== CELL 20 | Things that look wrong =====
# Problem 4: 'hour' is the hour the flight ACTUALLY left, not the hour it was scheduled
# Example: a flight scheduled at 19:00 that is 3 hours late shows hour = 22
# Look at flights that left between 1am and 4am - they are all very late
print('Average delay of flights that left at 1-4am:',
      round(df[df['hour'].isin([1, 2, 3, 4])]['dep_delay'].mean()), 'minutes')

# ===== CELL 21 | Things that look wrong =====
# Problem 5: the delay distribution is lopsided - a few very late flights pull the average up
df['dep_delay'].plot(kind='hist', bins=100, edgecolor='white', range=(-30, 200))
plt.title('Distribution of departure delay (minutes)')
plt.xlabel('Departure delay in minutes (negative = left early)')
plt.show()

print('Mean:  ', round(df['dep_delay'].mean(), 1))
print('Median:', df['dep_delay'].median())
print('Max:   ', df['dep_delay'].max())

# ===== CELL 22 | Cleaning decisions =====
# Cleaning step 1: set the impossible dew point to missing
corr_before = df['dewp'].corr(df['dep_delay'])
df.loc[df['dewp'] > 100, 'dewp'] = np.nan
corr_after = df['dewp'].corr(df['dep_delay'])
print('Correlation of dew point with delay - before:', round(corr_before, 3), ' after:', round(corr_after, 3))

# ===== CELL 23 | Cleaning decisions =====
# Cleaning step 2: drop wind_gust (copy of wind_speed) and pressure (17% missing)
df = df.drop(columns=['wind_gust', 'pressure'])

# ===== CELL 24 | Cleaning decisions =====
# Cleaning step 3: rebuild the SCHEDULED departure hour
# dep_time is written as hhmm (e.g. 1930 = 19:30). Convert to minutes after midnight,
# subtract the delay, and convert back to an hour
dep_minutes = (df['dep_time'] // 100) * 60 + (df['dep_time'] % 100)
sched_minutes = (dep_minutes - df['dep_delay']) % (24 * 60)
df['sched_hour'] = sched_minutes // 60

# Check: flights that left at 1-4am were mostly scheduled in the evening
df[df['hour'].isin([1, 2, 3, 4])]['sched_hour'].value_counts().head()

# ===== CELL 25 | Cleaning decisions =====
# Cleaning step 4: cancelled flights have no delay to measure - keep them out of the delay analysis
print('Cancelled flights:', df['dep_time'].isnull().sum())

# Cleaning step 5: flights without weather can't be used in the weather analysis
# Analysis set = flights that departed AND have weather
df_clean = df[df['dep_time'].notnull() & df['Key_Weather'].notnull()].copy()
print('Flights in analysis set:', len(df_clean))

# ===== CELL 26 | Cleaning decisions =====
# Cleaning step 6: add a yes/no column: was the flight more than 15 minutes late?
# 15 minutes is the official airline industry definition of "delayed"
df_clean['delayed'] = (df_clean['dep_delay'] > 15).astype(int)

# ===== CELL 27 | Cleaning decisions =====
# Cleaning step 7: keep extreme delays - they are real events, not errors
# How much would removing the worst 1% change the average?
cutoff = df_clean['dep_delay'].quantile(0.99)
print('99th percentile delay:', cutoff, 'minutes')
print('Average delay with all flights:     ', round(df_clean['dep_delay'].mean(), 2))
print('Average delay without the worst 1%: ', round(df_clean[df_clean['dep_delay'] <= cutoff]['dep_delay'].mean(), 2))

# ===== CELL 28 | Cleaning decisions =====
# Cleaning log - every decision in one table
cleaning_log = [
    {'Step': 'Skipped first row of weather.csv', 'Why': 'Row of column numbers above the real header', 'Rows affected': 1},
    {'Step': 'Dropped 9 empty columns in Flight.csv', 'Why': 'Left over from Excel, no data', 'Rows affected': 'all'},
    {'Step': 'Dropped weather date column', 'Why': 'Repeats year, month, day, hour', 'Rows affected': 'all'},
    {'Step': 'Dew point > 100 set to missing', 'Why': 'Physically impossible value (3,282 F)', 'Rows affected': 6},
    {'Step': 'Dropped wind_gust', 'Why': 'Always 1.15 x wind_speed, not a real measurement', 'Rows affected': 'all'},
    {'Step': 'Dropped pressure', 'Why': '17% missing', 'Rows affected': 'all'},
    {'Step': 'Added sched_hour', 'Why': 'hour is actual departure hour, which already contains the delay', 'Rows affected': 'all'},
    {'Step': 'Removed cancelled flights', 'Why': 'No delay to measure', 'Rows affected': 857},
    {'Step': 'Removed flights without weather', 'Why': 'Needed for weather analysis', 'Rows affected': 912},
    {'Step': 'Added delayed column (> 15 min)', 'Why': 'Industry definition of a delay', 'Rows affected': 'all'},
    {'Step': 'Kept extreme delays', 'Why': 'Real events that matter to passengers', 'Rows affected': 0},
]
pd.DataFrame(cleaning_log)

# ===== CELL 29 | 4. Baseline: the simplest possible answer =====
# The simplest possible answer: "every flight is delayed by the average amount"
avg_delay = df_clean['dep_delay'].mean()
print('Average delay:', round(avg_delay, 1), 'minutes')

# How wrong is that guess on average? (mean absolute error)
baseline_error = (df_clean['dep_delay'] - avg_delay).abs().mean()
print('Baseline error (MAE):', round(baseline_error, 1), 'minutes')

# ===== CELL 30 | 4. Baseline: the simplest possible answer =====
# For the yes/no question: "is this flight going to be delayed?"
pct_delayed = df_clean['delayed'].mean()
print('Share of flights delayed more than 15 minutes:', round(pct_delayed * 100, 1), '%')
print('Guessing "on time" for every flight is right', round((1 - pct_delayed) * 100, 1), '% of the time')
print('...but it never catches a single delay')

# ===== CELL 31 | 5. What drives delay? =====
# Chart 1: share of flights delayed, by scheduled hour
hour_stats = df_clean.groupby('sched_hour')['delayed'].agg(['mean', 'sem', 'size'])
hour_stats = hour_stats[hour_stats['size'] > 200]      # drop hours with very few flights

hour_stats['mean'].plot(kind='bar', yerr=1.96 * hour_stats['sem'], capsize=3, figsize=(10, 5))
plt.axhline(pct_delayed, color='red', linestyle='--', label='Average')
plt.title('Share of flights delayed >15 min, by scheduled departure hour')
plt.xlabel('Scheduled departure hour')
plt.ylabel('Share delayed')
plt.legend()
plt.show()

# ===== CELL 32 | 5. What drives delay? =====
# Chart 2: month x hour heatmap
heat = df_clean[df_clean['sched_hour'] >= 5].groupby(['month', 'sched_hour'])['delayed'].mean().unstack()

plt.figure(figsize=(12, 5))
sns.heatmap(heat, cmap='Blues')
plt.title('Share of flights delayed, by month and scheduled hour')
plt.xlabel('Scheduled departure hour')
plt.ylabel('Month')
plt.show()

# ===== CELL 33 | 5. What drives delay? =====
# Chart 3: share delayed by month
month_stats = df_clean.groupby('month')['delayed'].agg(['mean', 'sem', 'size'])

month_stats['mean'].plot(kind='bar', yerr=1.96 * month_stats['sem'], capsize=3, figsize=(10, 5))
plt.axhline(pct_delayed, color='red', linestyle='--', label='Average')
plt.title('Share of flights delayed >15 min, by month')
plt.xlabel('Month')
plt.ylabel('Share delayed')
plt.legend()
plt.show()

# ===== CELL 34 | 5. What drives delay? =====
# Chart 4: share delayed by carrier
carrier_stats = df_clean.groupby('carrier')['delayed'].agg(['mean', 'sem', 'size']).sort_values('mean')

carrier_stats['mean'].plot(kind='barh', xerr=1.96 * carrier_stats['sem'], capsize=3, figsize=(8, 5))
plt.axvline(pct_delayed, color='red', linestyle='--', label='Average')
plt.title('Share of flights delayed >15 min, by carrier')
plt.xlabel('Share delayed')
plt.legend()
plt.show()

carrier_stats

# ===== CELL 35 | 5. What drives delay? =====
# Chart 5: Seattle vs Portland, by month
df_clean.groupby(['month', 'origin'])['delayed'].mean().unstack().plot(marker='o', figsize=(10, 5))
plt.title('Share of flights delayed, Seattle vs Portland')
plt.xlabel('Month')
plt.ylabel('Share delayed')
plt.show()

# ===== CELL 36 | 5. What drives delay? =====
# Chart 6: weather - put each measurement into bands and compare the share delayed
df_clean['visib_band'] = pd.cut(df_clean['visib'], bins=[-1, 3, 9.9, 10], labels=['under 3 miles', '3-10 miles', '10 (clear)'])
df_clean['wind_band'] = pd.cut(df_clean['wind_speed'], bins=[-1, 10, 20, 50], labels=['0-10 mph', '10-20 mph', '20+ mph'])
df_clean['temp_band'] = pd.cut(df_clean['temp'], bins=[0, 32, 50, 70, 110], labels=['below 32 F', '32-50 F', '50-70 F', '70+ F'])
df_clean['rain'] = np.where(df_clean['precip'] > 0, 'rain', 'no rain')

fig, axes = plt.subplots(1, 4, figsize=(16, 4), sharey=True)
for ax, col in zip(axes, ['visib_band', 'wind_band', 'temp_band', 'rain']):
    s = df_clean.groupby(col, observed=True)['delayed'].agg(['mean', 'sem'])
    s['mean'].plot(kind='bar', yerr=1.96 * s['sem'], capsize=3, ax=ax)
    ax.axhline(pct_delayed, color='red', linestyle='--')
    ax.set_title(col)
    ax.set_xlabel('')
axes[0].set_ylabel('Share delayed')
plt.suptitle('Share of flights delayed in different weather')
plt.tight_layout()
plt.show()

# ===== CELL 37 | 5. What drives delay? =====
# Chart 7: correlation of each number with departure delay
cols = ['dep_delay', 'sched_hour', 'month', 'distance', 'temp', 'dewp', 'humid', 'wind_speed', 'precip', 'visib']

plt.figure(figsize=(9, 7))
sns.heatmap(df_clean[cols].corr().round(2), annot=True, cmap='coolwarm', vmin=-1, vmax=1)
plt.title('Correlation between variables')
plt.show()

df_clean[cols].corr()['dep_delay'].sort_values(ascending=False).round(3)

# ===== CELL 38 | 6. How sure are we? =====
# How precise is our overall number? Take many random samples of 1,000 flights
sample_means = [df_clean['delayed'].sample(1000).mean() for i in range(200)]

plt.hist(sample_means, bins=20)
plt.axvline(pct_delayed, color='red')
plt.title('Share delayed in 200 random samples of 1,000 flights')
plt.xlabel('Share delayed')
plt.ylabel('Number of samples')
plt.show()

# ===== CELL 39 | 6. How sure are we? =====
# 95% confidence interval for the overall share delayed (all flights)
sem = df_clean['delayed'].sem()
print('Share delayed:', round(pct_delayed * 100, 2), '%')
print('95% CI:', round((pct_delayed - 1.96 * sem) * 100, 2), '% to', round((pct_delayed + 1.96 * sem) * 100, 2), '%')

# ===== CELL 40 | 6. How sure are we? =====
# Confidence intervals for the comparisons that matter to the business
df_clean['time_of_day'] = pd.cut(df_clean['sched_hour'], bins=[-1, 4, 9, 13, 16, 20, 23],
                                 labels=['night 0-4', 'morning 5-9', 'midday 10-13', 'afternoon 14-16', 'evening 17-20', 'late 21-23'])

tod = df_clean.groupby('time_of_day', observed=True)['delayed'].agg(['mean', 'sem', 'size'])
tod['LOWER'] = tod['mean'] - 1.96 * tod['sem']
tod['UPPER'] = tod['mean'] + 1.96 * tod['sem']
tod.round(3)

# ===== CELL 41 | 6. How sure are we? =====
# Same table for weather conditions
df_clean['freezing'] = np.where(df_clean['temp'] < 32, 'freezing', 'not freezing')
df_clean['low_visib'] = np.where(df_clean['visib'] < 3, 'visibility < 3 mi', 'visibility 3+ mi')

for col in ['freezing', 'low_visib', 'rain', 'origin']:
    t = df_clean.groupby(col)['delayed'].agg(['mean', 'sem', 'size'])
    t['LOWER'] = t['mean'] - 1.96 * t['sem']
    t['UPPER'] = t['mean'] + 1.96 * t['sem']
    print(t.round(3), '\n')

# ===== CELL 42 | 6. How sure are we? =====
# Is the gap between evening and morning real? t-test (two groups)
evening = df_clean[df_clean['time_of_day'] == 'evening 17-20']['delayed']
morning = df_clean[df_clean['time_of_day'] == 'morning 5-9']['delayed']

diff = evening.mean() - morning.mean()
se_diff = np.sqrt(evening.sem() ** 2 + morning.sem() ** 2)
print('Evening minus morning:', round(diff * 100, 1), 'percentage points')
print('95% CI:', round((diff - 1.96 * se_diff) * 100, 1), 'to', round((diff + 1.96 * se_diff) * 100, 1))
print(stats.ttest_ind(evening, morning, equal_var=False))

# ===== CELL 43 | 6. How sure are we? =====
tod['mean'].plot(kind='bar', yerr=1.96 * tod['sem'], capsize=4)
plt.axhline(pct_delayed, color='red', linestyle='--')
plt.title('Share delayed by time of day, with 95% confidence interval')
plt.ylabel('Share delayed')
plt.xlabel('')
plt.show()

# ===== CELL 44 | 7. Predicting delay with regression =====
# Split into training data (80%) and test data (20%) so we judge the model on flights it has not seen
train = df_clean.sample(frac=0.8, random_state=1)
test = df_clean.drop(train.index)
print('Train:', len(train), ' Test:', len(test))

# Baseline on the test set: predict the training average for every flight
baseline_mae = (test['dep_delay'] - train['dep_delay'].mean()).abs().mean()
print('Baseline error (MAE):', round(baseline_mae, 2), 'minutes')

# ===== CELL 45 | 7. Predicting delay with regression =====
# Model 1: weather only
model_1 = smf.ols('dep_delay ~ temp + humid + wind_speed + precip + visib', data=train).fit()

# Model 2: schedule and airline only (C() = treat as categories)
model_2 = smf.ols('dep_delay ~ C(sched_hour) + C(month) + C(carrier) + origin', data=train).fit()

# Model 3: both together
model_3 = smf.ols('dep_delay ~ C(sched_hour) + C(month) + C(carrier) + origin + temp + humid + wind_speed + precip + visib',
                  data=train).fit()

# Compare on the test set
results = []
for name, m in [('1. Weather only', model_1), ('2. Schedule + airline', model_2), ('3. Both', model_3)]:
    pred = m.predict(test)
    ok = pred.notnull()
    mae = (test['dep_delay'][ok] - pred[ok]).abs().mean()
    results.append({'Model': name, 'R-squared (train)': round(m.rsquared, 3), 'Test MAE (minutes)': round(mae, 2)})
results.append({'Model': 'Baseline (average)', 'R-squared (train)': 0, 'Test MAE (minutes)': round(baseline_mae, 2)})
pd.DataFrame(results)

# ===== CELL 46 | 7. Predicting delay with regression =====
# Model 2 is our chosen model: adding weather (model 3) does not improve the test error
# Full output: coefficients, 95% confidence intervals [0.025, 0.975] and p-values
print(model_2.summary())

# ===== CELL 47 | 7. Predicting delay with regression =====
# Weather effects from model 3 (extra minutes of delay per unit), with 95% confidence intervals
# They are statistically real but tiny - which is why they don't improve predictions
weather_effects = model_3.conf_int().loc[['temp', 'humid', 'wind_speed', 'precip', 'visib']]
weather_effects.columns = ['LOWER', 'UPPER']
weather_effects['coef'] = model_3.params[['temp', 'humid', 'wind_speed', 'precip', 'visib']]
weather_effects.round(2)

# ===== CELL 48 | 7. Predicting delay with regression =====
# Where does the model fail? Compare error for different sizes of delay
test = test.copy()
test['predicted'] = model_2.predict(test)
test['error'] = (test['dep_delay'] - test['predicted']).abs()
test['delay_group'] = pd.cut(test['dep_delay'], bins=[-100, 0, 15, 60, 180, 2000],
                             labels=['early/on time', '1-15 min', '16-60 min', '61-180 min', '180+ min'])

fails = test.groupby('delay_group', observed=True).agg(flights=('error', 'size'),
                                                       avg_actual=('dep_delay', 'mean'),
                                                       avg_predicted=('predicted', 'mean'),
                                                       avg_error=('error', 'mean'))
fails.round(1)

# ===== CELL 49 | 7. Predicting delay with regression =====
plt.scatter(test['predicted'], test['dep_delay'], alpha=0.1, s=5)
plt.plot([-10, 40], [-10, 40], color='red')
plt.ylim(-40, 300)
plt.title('Predicted vs actual delay (test flights)')
plt.xlabel('Predicted delay (minutes)')
plt.ylabel('Actual delay (minutes)')
plt.show()

# ===== CELL 50 | 7. Predicting delay with regression =====
# Even if minutes are hard to predict, can the model RANK flights by risk?
# Split test flights into 10 equal groups by predicted delay, and check the real share delayed
test['risk_group'] = pd.qcut(test['predicted'], 10, labels=range(1, 11))
risk = test.groupby('risk_group', observed=True)['delayed'].agg(['mean', 'sem', 'size'])

risk['mean'].plot(kind='bar', yerr=1.96 * risk['sem'], capsize=3)
plt.axhline(test['delayed'].mean(), color='red', linestyle='--', label='Average')
plt.title('Actual share delayed, by predicted risk group (1 = lowest, 10 = highest)')
plt.xlabel('Risk group')
plt.ylabel('Share delayed')
plt.legend()
plt.show()

risk.round(3)
