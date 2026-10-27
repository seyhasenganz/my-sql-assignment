# Explainer Video Script (4–6 min) – Snowflake vs BigQuery for Build-A-Bear

Slides: https://claude.ai/artifact/XHSnt1LJPXhKJ3xC71nazT (speaker notes = this script).
Total ≈ 789 words ≈ 5.6 min at a natural pace (140 words/min).

### Slide 1 – cover

Hi, I’m Seyha. Imagine I’m on Build-A-Bear Workshop’s e-commerce analytics team, and today I’m pitching to our CTO and CMO. The question is simple: should we build our marketing analytics on Snowflake or on Google BigQuery? I tested Snowflake hands-on, researched BigQuery, and priced both over three years. Let’s go.

### Slide 2 – problem

First, the business. Build-A-Bear made 529.8 million dollars last year, 92 percent of it direct from customers – stores and two e-commerce sites. In August the company cut its revenue guidance, citing traffic pressure. With fewer visitors, every marketing dollar must work harder. But ad, website and sales data live in separate systems, so channel reports are built by hand. We can’t quickly see which marketing pays off.

### Slide 3 – poc-insight

To prove the idea, I loaded a public dataset from a teddy-bear online store into Snowflake and asked: which channels bring revenue, and which convert best? One paid Google channel brings 58 percent of all revenue – that’s concentration risk. Brand search converts at almost 9 percent, paid social at only 3.2. That’s the insight marketing needs every day, not once a quarter.

### Slide 4 – contenders

Meet the contenders. Snowflake is a cloud data warehouse that runs on AWS, Azure or Google, with storage and compute separate. You pay for time – credits for every hour a warehouse runs. BigQuery is Google Cloud’s serverless warehouse – nothing to size or switch off. You pay for the data each query scans: 6.25 dollars per terabyte, first terabyte a month free. Same goal, very different bills.

### Slide 5 – poc

My Snowflake test, in numbers: 1.7 million rows loaded in an afternoon, compressed from 103 to 19 megabytes. The channel analysis ran in 1.3 seconds on the smallest warehouse, and the whole test cost about 1.75 dollars – with three read-only users and MFA. One lesson: 91 percent of my credits came from the default warehouse, not the one I set to switch off after 60 seconds. With Snowflake, settings decide the bill.

### Slide 6 – proscons

Pros and cons. Pricing: Snowflake is predictable with auto-suspend and quotas, but idle warehouses bill; BigQuery has a free tier and free Google Ads connector, but big scans can surprise you. Scalability: both excellent. Usability: both use SQL, but Snowflake’s roles were simpler; BigQuery means learning Google Cloud permissions. Business fit: BigQuery is native to Google Ads; Snowflake runs on any cloud and shares data easily with partners.

### Slide 7 – reviews

What do customers say? On Gartner and G2 the two are nearly tied – Snowflake slightly ahead. And both have the same worry: cost control. Snowflake users say it’s easy to spend a lot if warehouses run too long. BigQuery users complain about surprise bills from big scans. So reputation won’t decide this. Our workload and our team will.

### Slide 8 – tco

Now pricing, for the same workload: 50 gigabytes growing 50 percent a year, hourly dashboards, three analysts. Over three years Snowflake costs about 19,900 dollars, BigQuery about 17,900 – 11 percent cheaper, thanks to its free tier and free Ads connector. But look at the bars: the platform bill is the small part. Staff time – migration, training, admin – is 77 to 89 percent. That’s the hidden cost most comparisons forget.

### Slide 9 – risk

But cheapest isn’t the whole story. I stress-tested both. If our team gets careless – Snowflake warehouses idling ten minutes before they switch off, or BigQuery queries scanning entire tables – Snowflake’s bill goes up 2.6 times. BigQuery’s goes up 5.2 times. So BigQuery wins when everyone is disciplined, but it’s twice as sensitive to mistakes. For a small team that’s still learning, predictability matters.

### Slide 10 – scoring

To decide fairly, I set a rule before scoring anything: if the three-year cost gap is under 20 percent, cost doesn’t decide – scalability, usability and business fit do. On all four criteria, BigQuery edges ahead, 4.55 to 4.45, because it’s cheaper. But the cost gap is only 11 percent. So by our rule we look at the other three criteria – and there Snowflake wins, 3.25 to 3.05, thanks to usability.

### Slide 11 – recommendation

My recommendation: choose Snowflake. One: it’s easier for a small team – I had data, users and MFA running in one afternoon. Two: cost is more predictable – mistakes cost 2.6 times, not 5.2. Three: no lock-in, and secure sharing with our partners. The price is about 650 dollars a year more. To be fair, if we stay marketing-only and already live in Google Cloud, BigQuery would win – so we review after year one.

### Slide 12 – close

Next steps: approve a phase-one budget – the three-year cost is about 20 thousand dollars, well inside 150 thousand. Move our channel reports from spreadsheets into Snowflake. And start shifting ad budget from channels that convert at 3 percent to channels that convert at 9. Better data, better decisions, more bears going home. Thanks for watching!
