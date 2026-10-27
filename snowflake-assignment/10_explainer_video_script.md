# Explainer Video Script (4–6 min) – Snowflake vs BigQuery for Build-A-Bear

Slides: https://claude.ai/artifact/XHSnt1LJPXhKJ3xC71nazT (each slide’s speaker notes = this script).
Total ≈ 755 words ≈ 5.4 minutes at a relaxed pace. Say it in your own words – it does not need to be word-perfect.

## Slide 1 – Snowflake or BigQuery?  ← persona

Hi, I’m Seyha. Imagine I work on the data team at Build-A-Bear Workshop, the teddy bear company from St. Louis. Our leaders asked me one question: should we use Snowflake or Google BigQuery to store and study our marketing data? I tested Snowflake myself, I researched BigQuery, and I compared the costs. Here’s what I found.

## Slide 2 – The problem: traffic is down, every ad dollar counts  ← persona background

Quick background. If you haven’t heard of it, Build-A-Bear is the store where kids make their own teddy bear. They pick an animal, stuff it, put a little heart inside, give it a name and dress it up. The company started in 1997, has about 5,500 employees, and is listed on the New York Stock Exchange. It sells about 530 million dollars a year, mostly through its own stores and websites in the US, Canada, the UK and Ireland. This year fewer shoppers are coming in, so the company lowered its sales forecast. That means every marketing dollar has to count. But today our data is spread out, and reports are made by hand. We can’t easily see which ads bring in sales.

## Slide 3 – What the data shows: one channel carries the business

So I tried a test. I loaded a public data set from an online teddy bear shop into Snowflake. Then I asked: where do our customers come from? I found that more than half of all sales come from just one place – Google ads. That’s risky: if those ads get expensive, we’re in trouble. I also found that not all ads work the same. Customers who already know the shop are much more likely to buy than people who just see an ad on social media. So some of our ad money is wasted. Snowflake helps us see this quickly.

## Slide 4 – Two contenders, two ways to bill you  ← Step 6 part 1: purpose of each product

Part one: what are these two tools? Both are cloud data warehouses. They let a company keep all its data in one place online and analyze it quickly. Snowflake works on the Amazon, Microsoft or Google cloud. You pay for the time your computer power is switched on. BigQuery is made by Google. You pay for how much data your questions read, and small users often pay nothing, because Google gives some free use every month.

## Slide 5 – My Snowflake proof of concept in numbers

Here’s my Snowflake test in numbers. I loaded 1.7 million rows in one afternoon. My question ran in about one second. The whole test cost less than two dollars. I also set up three users who can only read the data, and they must log in with MFA – a code from their phone. One lesson: most of my cost came from a default setting I forgot to change.

## Slide 6 – Pros and cons on the four criteria  ← Step 6 part 2: pros and cons

Part two: pros and cons. Price: BigQuery is cheaper to start, but you pay for how much data each question reads – so one badly written question on a big table can cost a lot. Snowflake is easier to predict: you pay for the time you use, and you can set a monthly spending limit. Scalability: both grow easily, for example during the holidays. Ease of use: both use SQL, but I found Snowflake simpler to set up. Business fit: BigQuery fits well with Google Ads. Snowflake works on any cloud and makes sharing data with partners easy.

## Slide 7 – What customers say: nearly tied, same worry

Real users agree they’re close. Snowflake gets 4.7 stars on Gartner, BigQuery 4.5. And both groups have the same worry: surprise bills. So reviews alone can’t decide this.

## Slide 8 – 3-year cost: BigQuery is 11% cheaper  ← Step 6 part 3: pricing comparison

Part three: price. I priced the same job on both tools for three years: about 50 gigabytes of data, dashboards that update every hour, and three analysts. For computing, BigQuery is cheaper – about 1,900 dollars against 3,700. Storage is cheap on both, around 100 dollars or less. But the biggest cost is people’s time: setting up, training and managing. In total, Snowflake is about 19,900 dollars and BigQuery about 17,900. So BigQuery is around 2,000 dollars cheaper over three years.

## Slide 9 – Risk test: what if the team gets careless?

But what if someone makes a mistake? I tested that too. With Snowflake, a mistake could make the bill about two and a half times bigger. With BigQuery, about five times bigger. So BigQuery is cheaper, but riskier.

## Slide 10 – The scorecard, with the rule set first

So I scored both on the four points. BigQuery wins on price. Snowflake wins on ease of use. They tie on scalability and business fit. Because the price difference is small – about 11 percent – I let the other points decide. And there, Snowflake is ahead.

## Slide 11 – Choose Snowflake.  ← Step 6 part 4: clear recommendation

Part four: my recommendation. Choose Snowflake. One, it’s easy for a small team – I had it working in one afternoon. Two, the bill is easier to control. Three, we’re not stuck with one cloud, and we can share data safely with partners. Yes, it costs about 650 dollars more a year. But if our team only used Google tools for marketing, BigQuery would be a good choice too. So let’s review it after one year.

## Slide 12 – Next steps

Next steps: approve the budget, move our reports into Snowflake, and put more ad money into the channels that really work. Better data means better decisions. Thanks for watching!
