# Explainer Video Script (4–6 min) – Snowflake vs BigQuery for Build-A-Bear

Slides: https://claude.ai/artifact/XHSnt1LJPXhKJ3xC71nazT
Short version: about 542 words ≈ 5–5½ minutes at a natural pace (the 755-word version timed at 7:30). Say it in your own words – it does not need to be word-perfect.

## Slide 1 – Snowflake or BigQuery?  ← persona

Hi, I'm Seyha. Imagine I work on the data team at Build-A-Bear Workshop. Our leaders asked me one question: should we use Snowflake or Google BigQuery for our marketing data? I tested Snowflake, researched BigQuery, and compared the costs. Here's what I found.

## Slide 2 – The problem: traffic is down, every ad dollar counts

Build-A-Bear is the store where kids make their own teddy bear. It sells about 530 million dollars a year. This year fewer shoppers are coming in, so every marketing dollar has to count. But our data is spread out, and reports are made by hand. We can't easily see which ads bring in sales.

## Slide 3 – What the data shows: one channel carries the business

So I loaded a public data set from an online teddy bear shop into Snowflake and asked: where do sales come from? More than half come from just one place: Google ads. That's risky. And people who already know the shop buy much more often than people who see an ad on social media. So some ad money is wasted.

## Slide 4 – Two contenders, two ways to bill you  ← part 1: purpose

Part one: what are these tools? Both are cloud data warehouses: one place online to keep and analyze all your data. With Snowflake, you pay for the time your computer power is on. With BigQuery, from Google, you pay for how much data your questions read, and small users get some free use every month.

## Slide 5 – My Snowflake proof of concept in numbers

My Snowflake test: I loaded 1.7 million rows in one afternoon. My question ran in about one second, and the whole test cost less than two dollars. I also set up three read-only users who log in with MFA.

## Slide 6 – Pros and cons on the four criteria  ← part 2: pros and cons

Part two: pros and cons. Price: BigQuery is cheaper to start, but one badly written question on a big table can cost a lot. Snowflake is easier to predict, and you can set a monthly spending limit. Scalability: both grow easily. Ease of use: both use SQL, but Snowflake was simpler to set up. Business fit: BigQuery fits well with Google Ads. Snowflake works on any cloud and makes sharing data with partners easy.

## Slide 7 – What customers say: nearly tied, same worry

Online reviews rate both about four and a half stars, and users of both complain about the same thing: surprise bills. So reviews can't pick a winner.

## Slide 8 – 3-year cost: BigQuery is 11% cheaper  ← part 3: pricing

Part three: price. I priced the same job on both for three years. Computing is cheaper on BigQuery. But the biggest cost is people's time: setup, training and managing. In total, Snowflake is about 19,900 dollars and BigQuery about 17,900. So BigQuery is around 2,000 dollars cheaper.

## Slide 9 – Risk test: what if the team gets careless?

But what if someone makes a mistake? Then the Snowflake bill could be about two and a half times bigger. BigQuery's could be five times bigger. Cheaper, but riskier.

## Slide 10 – The scorecard, with the rule set first

On my scorecard, BigQuery wins on price, Snowflake wins on ease of use, and they tie on the rest. The price gap is only about 650 dollars a year, so ease of use matters more. Snowflake wins.

## Slide 11 – Choose Snowflake.  ← part 4: recommendation

Part four: my recommendation. Choose Snowflake. It's easy for a small team, the bill is easier to control, and we're not stuck with one cloud. Yes, it costs about 650 dollars more a year. If our team used only Google tools, BigQuery would be fine too, so let's review it after one year.

## Slide 12 – Next steps

Next steps: approve the budget, move our reports into Snowflake, and put more ad money into the channels that really work. Thanks for watching!
