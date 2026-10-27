# Explainer Video Script (4–6 min) – Snowflake vs BigQuery for Build-A-Bear

Slides: https://claude.ai/artifact/XHSnt1LJPXhKJ3xC71nazT (each slide’s speaker notes = this script).
Total ≈ 810 words ≈ 5.8 minutes at a relaxed pace. Speak like you are explaining it to a friend – it does not need to be word-perfect.

## Slide 1 – Snowflake or BigQuery?  (~24 sec)

Hi, I’m Seyha. Let’s say I work on the data team at Build-A-Bear Workshop. Today I want to answer one question for our leaders: should we use Snowflake or Google BigQuery for our marketing data? I tried Snowflake myself, I looked into BigQuery, and I compared the cost over three years. Let’s see which one wins.

## Slide 2 – The problem: traffic is down, every ad dollar counts  (~31 sec)

First, a bit about Build-A-Bear. Last year they made about 530 million dollars. Most of it, 92 percent, comes straight from customers, in stores and online. But in August they lowered their sales forecast, because fewer people are coming in. So every marketing dollar really matters now. The problem is, the data sits in different systems, and reports are made by hand. It’s hard to see quickly which ads actually work.

## Slide 3 – What the data shows: one channel carries the business  (~34 sec)

To test the idea, I took a public dataset from an online teddy bear store and loaded it into Snowflake. Then I asked a simple question: which marketing channels bring in money, and which ones turn visitors into buyers? Look at this. One paid Google channel brings in 58 percent of all the money. That’s a lot of eggs in one basket. Brand search turns almost 9 percent of visitors into buyers. Paid social? Only about 3 percent.

## Slide 4 – Two contenders, two ways to bill you  (~32 sec)

So, who are the two options? Snowflake is a data warehouse in the cloud. It works on Amazon, Microsoft or Google. You pay for time – basically, how long your computing power is switched on. BigQuery is Google’s data warehouse. There’s nothing to switch on or off. You pay for how much data each query reads, and the first terabyte every month is free. Same job, but a very different way of charging you.

## Slide 5 – My Snowflake proof of concept in numbers  (~36 sec)

Here’s what happened when I tried Snowflake. I loaded 1.7 million rows in one afternoon. The files shrank from 103 megabytes to just 19. My analysis ran in about one second. And the whole test cost me less than two dollars. I also made three users who can only read the data, and they must use MFA to log in. One thing I learned: most of my cost came from a default setting I didn’t change. With Snowflake, your settings decide your bill.

## Slide 6 – Pros and cons on the four criteria  (~37 sec)

Now, the pros and cons. On price, Snowflake is easy to predict if you set it up right. BigQuery is cheaper to start, but one careless query can cost a lot. On growing bigger, both are great. On ease of use, both use SQL, but I found Snowflake simpler. With BigQuery you also have to learn Google Cloud permissions. And on business fit, BigQuery works really well with Google Ads, while Snowflake works on any cloud and makes it easy to share data with partners.

## Slide 7 – What customers say: nearly tied, same worry  (~22 sec)

What do real users say? The ratings are almost the same: Snowflake gets 4.7 on Gartner, BigQuery 4.5. And both groups have the same complaint – cost. Snowflake users say it’s easy to overspend. BigQuery users get surprised by big bills. So reviews won’t decide this. Our own needs will.

## Slide 8 – 3-year cost: BigQuery is 11% cheaper  (~30 sec)

Okay, the money. I priced the same job on both, over three years. Snowflake comes to about 19,900 dollars. BigQuery is about 17,900. So BigQuery is about 11 percent cheaper. But here’s the interesting part – look at the bars. The software bill is the small piece. Most of the cost is people’s time: moving the data, training, and looking after it. That’s the hidden cost people often forget.

## Slide 9 – Risk test: what if the team gets careless?  (~20 sec)

Then I asked: what if the team makes mistakes? With Snowflake, the bill could go up about 2.6 times. With BigQuery, about 5.2 times. So BigQuery is cheaper if everyone is careful, but riskier if they’re not. For a small team that’s still learning, that really matters.

## Slide 10 – The scorecard, with the rule set first  (~27 sec)

To keep it fair, I set a rule before I scored anything: if the cost difference is under 20 percent, cost doesn’t decide. Here the difference is only 11 percent. On all four points together, BigQuery is just slightly ahead, because it’s cheaper. But on the other three – growing bigger, ease of use and business fit – Snowflake comes out on top.

## Slide 11 – Choose Snowflake.  (~33 sec)

So my recommendation is Snowflake. Why? First, it’s easy for a small team – I had everything working in one afternoon. Second, the cost is more predictable. Third, we’re not locked into one cloud, and we can share data safely with partners. It costs about 650 dollars more per year. And to be fair, if we only did marketing and already used Google Cloud, BigQuery would be the better pick. So let’s check again after one year.

## Slide 12 – Next steps  (~25 sec)

So what’s next? One: approve the budget. The three-year cost is about 20 thousand dollars, well under our 150 thousand limit. Two: move our reports out of spreadsheets and into Snowflake. Three: move ad money from the channels that convert at 3 percent to the ones that convert at 9. Better data, better decisions. Thanks for watching!
