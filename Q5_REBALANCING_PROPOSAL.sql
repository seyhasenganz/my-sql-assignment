-- ===================================
-- QUESTION 5: REBALANCING PROPOSAL
-- ===================================
-- Based on REAL Q1-Q4 analysis
-- Recommend portfolio allocation changes

USE invest_portfolio;

-- ===================================
-- Current vs Proposed Allocation
-- ===================================
-- REAL Sharpe Ratios from Q4 analysis:
-- IXN:  1.14 (Strong Buy - keep)
-- QQQ:  0.94 (Buy - keep)
-- GLD: -0.08 (SELL - too much volatility, negative Sharpe)
-- VNQ:  0.57 (Buy - increase)
-- IEF: -0.37 (SELL - bonds underperforming)

SELECT
    ticker,
    portfolio_weight as current_allocation_pct,

    -- Proposed allocation based on Sharpe ratios
    CASE
        WHEN ticker = 'IXN' THEN 20.0    -- Increase from 17.5% (Strong Buy)
        WHEN ticker = 'QQQ' THEN 25.0    -- Increase from 22.1% (Buy)
        WHEN ticker = 'GLD' THEN 15.0    -- REDUCE from 23.0% (Sell - negative Sharpe)
        WHEN ticker = 'VNQ' THEN 25.0    -- INCREASE from 8.9% (Buy)
        WHEN ticker = 'IEF' THEN 15.0    -- REDUCE from 28.5% (Sell - negative Sharpe)
    END as proposed_allocation_pct,

    -- Calculate dollar amount of trades needed
    CASE
        WHEN ticker = 'IXN' THEN ROUND((20.0 - portfolio_weight) * 95 / 100, 1)
        WHEN ticker = 'QQQ' THEN ROUND((25.0 - portfolio_weight) * 95 / 100, 1)
        WHEN ticker = 'GLD' THEN ROUND((15.0 - portfolio_weight) * 95 / 100, 1)
        WHEN ticker = 'VNQ' THEN ROUND((25.0 - portfolio_weight) * 95 / 100, 1)
        WHEN ticker = 'IEF' THEN ROUND((15.0 - portfolio_weight) * 95 / 100, 1)
    END as trade_amount_millions,

    -- Action to take
    CASE
        WHEN ticker = 'IXN' AND portfolio_weight < 20.0 THEN 'BUY $2.4M'
        WHEN ticker = 'QQQ' AND portfolio_weight < 25.0 THEN 'BUY $2.9M'
        WHEN ticker = 'GLD' AND portfolio_weight > 15.0 THEN 'SELL $7.6M'
        WHEN ticker = 'VNQ' AND portfolio_weight < 25.0 THEN 'BUY $15.3M'
        WHEN ticker = 'IEF' AND portfolio_weight > 15.0 THEN 'SELL $12.8M'
        ELSE 'HOLD'
    END as action,

    -- Reasoning based on Q4 Sharpe Ratio
    CASE
        WHEN ticker = 'IXN' THEN 'Sharpe 1.14 - Strong Buy, excellent risk-adjusted return'
        WHEN ticker = 'QQQ' THEN 'Sharpe 0.94 - Buy, good risk-adjusted return'
        WHEN ticker = 'GLD' THEN 'Sharpe -0.08 - SELL, negative risk-adjusted return, too volatile'
        WHEN ticker = 'VNQ' THEN 'Sharpe 0.57 - Buy, increase diversification and income'
        WHEN ticker = 'IEF' THEN 'Sharpe -0.37 - SELL, bonds underperforming, lowest risk-adjusted return'
    END as reason

FROM holdings_dim
WHERE account_id = 1001
ORDER BY
    CASE
        WHEN ticker = 'IXN' THEN 1
        WHEN ticker = 'QQQ' THEN 2
        WHEN ticker = 'GLD' THEN 3
        WHEN ticker = 'VNQ' THEN 4
        WHEN ticker = 'IEF' THEN 5
    END;

-- ===================================
-- EXPLANATION OF REBALANCING
-- ===================================
/*
REBALANCING RATIONALE (Based on REAL Sharpe Ratios):

Current Allocation:
  IXN: 17.5% (Sharpe 1.14) - Best performer, but underweighted
  QQQ: 22.1% (Sharpe 0.94) - Good performer, but underweighted
  GLD: 23.0% (Sharpe -0.08) - WORST performer, overweighted
  VNQ:  8.9% (Sharpe 0.57) - Good performer, SEVERELY underweighted
  IEF: 28.5% (Sharpe -0.37) - Second worst, OVERWEIGHTED

Key Changes:

1. REDUCE GLD from 23.0% to 15.0% (SELL $7.6M)
   Reason: Sharpe -0.08 (negative return for risk)
           Very volatile (33.78%) with only 8.08% return
           Risk not justified by return

2. REDUCE IEF from 28.5% to 15.0% (SELL $12.8M)
   Reason: Sharpe -0.37 (worst performer)
           0.21% return in 12M (essentially flat)
           4.84% volatility not justified
           Bonds overweighted despite poor Sharpe

3. INCREASE IXN from 17.5% to 20.0% (BUY $2.4M)
   Reason: Sharpe 1.14 (best risk-adjusted return)
           34.51% return with reasonable 28.60% volatility
           Should be larger position

4. INCREASE QQQ from 22.1% to 25.0% (BUY $2.9M)
   Reason: Sharpe 0.94 (second best)
           19.89% return with 19.36% volatility
           Broader diversification than IXN
           Deserves larger allocation

5. INCREASE VNQ from 8.9% to 25.0% (BUY $15.3M)
   Reason: Sharpe 0.57 (fourth best)
           Severely underweighted for diversification
           Provides income (3-4% dividend)
           Low correlation to stocks (13.85% volatility)
           5x increase in position

New Allocation:
  IXN: 20.0% (Best risk-adjusted returns)
  QQQ: 25.0% (Strong risk-adjusted returns)
  GLD: 15.0% (Reduced commodity exposure)
  VNQ: 25.0% (Increased diversification)
  IEF: 15.0% (Reduced bond exposure)

Impact:
  - More concentrated in best-performing assets (IXN, QQQ)
  - Increased diversification (VNQ doubled)
  - Reduced drag from negative-Sharpe assets (GLD, IEF)
  - Better risk-adjusted portfolio
  - More aggressive positioning (80% equities + real estate)

Expected Result:
  - Higher expected return (from concentrating in high-Sharpe holdings)
  - Better risk-adjusted performance
  - Less drag from underperforming bonds and gold
*/
