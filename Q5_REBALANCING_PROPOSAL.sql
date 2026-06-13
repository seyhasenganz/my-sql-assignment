-- ===================================
-- QUESTION 5: REBALANCING PROPOSAL
-- ===================================
-- Based on REAL Q4 Sharpe Ratio Analysis from Database
-- All holdings have POSITIVE Sharpe ratios

USE invest_portfolio;

-- ===================================
-- REAL Sharpe Ratios from Q4 Analysis:
-- IXN:  2.0104 (STRONG BUY - Excellent risk-adjusted return)
-- QQQ:  1.7589 (STRONG BUY - Excellent risk-adjusted return)
-- GLD:  0.8499 (STRONG BUY - Good risk-adjusted return)
-- VNQ:  0.8217 (STRONG BUY - Good risk-adjusted return)
-- IEF:  0.3105 (HOLD - Acceptable but lowest performer)
-- ===================================

SELECT
    h.ticker,
    h.portfolio_weight as current_allocation_pct,

    -- Proposed allocation based on REAL Sharpe ratios
    CASE
        WHEN h.ticker = 'IXN' THEN 20.0    -- Increase from 17.5% (Sharpe 2.01 - Best!)
        WHEN h.ticker = 'QQQ' THEN 25.0    -- Increase from 22.1% (Sharpe 1.76 - Excellent)
        WHEN h.ticker = 'GLD' THEN 22.0    -- Hold/Slight reduce from 23.0% (Sharpe 0.85)
        WHEN h.ticker = 'VNQ' THEN 18.0    -- Increase from 8.9% (Sharpe 0.82 - Good, but underweighted)
        WHEN h.ticker = 'IEF' THEN 15.0    -- Reduce from 28.5% (Sharpe 0.31 - Lowest performer)
    END as proposed_allocation_pct,

    -- Calculate dollar amount of trades needed
    CASE
        WHEN h.ticker = 'IXN' THEN ROUND((20.0 - h.portfolio_weight) * 95 / 100, 1)
        WHEN h.ticker = 'QQQ' THEN ROUND((25.0 - h.portfolio_weight) * 95 / 100, 1)
        WHEN h.ticker = 'GLD' THEN ROUND((22.0 - h.portfolio_weight) * 95 / 100, 1)
        WHEN h.ticker = 'VNQ' THEN ROUND((18.0 - h.portfolio_weight) * 95 / 100, 1)
        WHEN h.ticker = 'IEF' THEN ROUND((15.0 - h.portfolio_weight) * 95 / 100, 1)
    END as trade_amount_millions,

    -- Action to take
    CASE
        WHEN h.ticker = 'IXN' AND h.portfolio_weight < 20.0 THEN 'BUY $2.4M'
        WHEN h.ticker = 'QQQ' AND h.portfolio_weight < 25.0 THEN 'BUY $2.9M'
        WHEN h.ticker = 'GLD' AND h.portfolio_weight > 22.0 THEN 'SELL $0.95M'
        WHEN h.ticker = 'VNQ' AND h.portfolio_weight < 18.0 THEN 'BUY $8.6M'
        WHEN h.ticker = 'IEF' AND h.portfolio_weight > 15.0 THEN 'SELL $12.8M'
        ELSE 'HOLD'
    END as action,

    -- Detailed reasoning based on REAL Sharpe Ratio
    CASE
        WHEN h.ticker = 'IXN' THEN 'Sharpe 2.01 - EXCELLENT risk-adjusted return, highest quality holding, increase position'
        WHEN h.ticker = 'QQQ' THEN 'Sharpe 1.76 - EXCELLENT risk-adjusted return, strong performance, increase position'
        WHEN h.ticker = 'GLD' THEN 'Sharpe 0.85 - GOOD risk-adjusted return, stable diversifier, maintain position'
        WHEN h.ticker = 'VNQ' THEN 'Sharpe 0.82 - GOOD risk-adjusted return, income generator, severely underweighted, increase position'
        WHEN h.ticker = 'IEF' THEN 'Sharpe 0.31 - LOWEST risk-adjusted return among holdings, bonds underperforming, reduce defensive drag'
    END as reason

FROM holdings_dim h
WHERE h.account_id = 1001
ORDER BY
    CASE
        WHEN h.ticker = 'IXN' THEN 1
        WHEN h.ticker = 'QQQ' THEN 2
        WHEN h.ticker = 'GLD' THEN 3
        WHEN h.ticker = 'VNQ' THEN 4
        WHEN h.ticker = 'IEF' THEN 5
    END;

-- ===================================
-- DETAILED REBALANCING ANALYSIS
-- ===================================
/*
PORTFOLIO REBALANCING BASED ON REAL SHARPE RATIOS:

Current Allocation Summary:
  IXN: 17.5% (Sharpe 2.01)  - Underweighted highest performer
  QQQ: 22.1% (Sharpe 1.76)  - Underweighted excellent performer
  GLD: 23.0% (Sharpe 0.85)  - Well-positioned good performer
  VNQ:  8.9% (Sharpe 0.82)  - SEVERELY underweighted good performer
  IEF: 28.5% (Sharpe 0.31)  - OVERWEIGHTED lowest performer

KEY INSIGHT: ALL HOLDINGS ARE POSITIVE SHARPE RATIOS
  - No holdings to completely sell
  - All deserve to remain in portfolio
  - Rebalancing focuses on OPTIMIZING allocation, not eliminating

RECOMMENDED REBALANCING:

1. INCREASE IXN from 17.5% to 20.0% (BUY $2.4M)
   Rationale:
     - Sharpe 2.01 = Highest quality investment
     - Earning $2.01 excess return for every 1% of risk
     - Despite 50% expected return, strong Sharpe shows good value
     - Deserves larger allocation

2. INCREASE QQQ from 22.1% to 25.0% (BUY $2.9M)
   Rationale:
     - Sharpe 1.76 = Excellent risk-adjusted return
     - 32% expected return with reasonable 17.19% volatility
     - Second-best performer after IXN
     - Broader diversification than IXN (100+ stocks vs sector)

3. HOLD GLD at 22.0% (SELL $0.95M - slight reduction)
   Rationale:
     - Sharpe 0.85 = Good, but not exceptional
     - Only 0.85 excess return for each 1% risk (vs 2.01 for IXN)
     - Valuable as diversifier (commodity/gold hedge)
     - 27.35% volatility higher than equities
     - Slight reduction to reallocate to higher-Sharpe holdings

4. INCREASE VNQ from 8.9% to 18.0% (BUY $8.6M)
   Rationale:
     - Sharpe 0.82 = Good risk-adjusted return
     - CRITICALLY UNDERWEIGHTED at only 8.9%
     - Real Estate provides diversification + income (3-4% dividends)
     - 13.53% volatility = lowest among holdings = safer
     - 5x increase in position justified
     - Provides inflation protection and income generation

5. REDUCE IEF from 28.5% to 15.0% (SELL $12.8M)
   Rationale:
     - Sharpe 0.31 = Lowest performing holding
     - Bonds earning only 3.46% expected return
     - 4.7% volatility = barely justified for such low return
     - 28.5% allocation = OVERWEIGHTED
     - In low-rate environment, bonds unattractive
     - Reduce defensive drag on portfolio

ALLOCATION TRANSFORMATION:

Before Rebalancing:
  Growth (IXN + QQQ): 39.6%
  Defensive (IEF + VNQ): 37.4%
  Hedge (GLD): 23.0%
  Character: DEFENSIVE-TILTED

After Rebalancing:
  Growth (IXN + QQQ): 45.0% (+5.4%)
  Defensive (IEF + VNQ): 33.0% (-4.4%)
  Hedge (GLD): 22.0% (-1.0%)
  Character: GROWTH-ORIENTED with DEFENSIVE BALANCE

Impact on Portfolio:
  - More concentrated in high-Sharpe holdings (IXN 2.01, QQQ 1.76)
  - Better diversification (VNQ increased from 8.9% to 18%)
  - Reduced bond drag (IEF reduced from 28.5% to 15%)
  - Expected return: Increase ~2-3%
  - Portfolio volatility: Slight increase to ~17-18%
  - Sharpe ratio: Should improve due to higher-quality allocation

Risk Management:
  - All holdings remain positive Sharpe (no losers being eliminated)
  - Real Estate (VNQ) provides income and stability
  - Gold (GLD) remains for diversification
  - Still have 33% defensive allocation (IEF + VNQ)
  - More aggressive than before, but still balanced

Client Recommendation:
  APPROVE REBALANCING
  Rationale: Optimize allocation based on real risk-adjusted returns
  Timeline: Execute within 30 days
  Tax Consideration: Review long-term vs short-term gains on sales
  Rebalance Frequency: Quarterly review, rebalance if allocation drifts >5%
*/
