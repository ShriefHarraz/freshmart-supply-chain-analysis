# Integrated Supply Chain Recommendations (Q13)

These recommendations are based on the questions explored in this portfolio. Because the dataset is simulated, they are analytical recommendations for the case study, not verified actions for a real company.

## 1. Prioritize inventory and supplier follow-up
- Review high-revenue products with low stock against current demand, reorder point, safety stock, open purchase orders, and supplier lead time.
- Contact suppliers about expediting urgent orders where the expected stock position indicates risk.
- Evaluate expedited freight cost against margin and the business impact of a stockout.

## 2. Reduce waste
- Rank waste by both units and recorded inventory value.
- Break down waste by reason, store, date, shelf life, and product to identify where intervention is most likely to help.
- Review ordering frequency and quantity for perishable or short-shelf-life products.

## 3. Replenish using demand and inventory position
- Use demand history alongside latest stock, safety stock, reorder point, lead time, and open purchase orders.
- Avoid increasing orders based only on historical sales ranking.
- Recheck slow-moving/high-stock products before ordering more.

## 4. Improve supplier performance monitoring
- Track on-time delivery rate and lead-time variability in addition to average lead time.
- Separate delivered purchase orders from open orders when calculating lead-time metrics.

## 5. Validate classification and forecasting methods
- Review the demand time grain before applying XYZ categories.
- Validate ABC thresholds with business stakeholders.
- Evaluate moving-average forecasts over multiple holdout months and compare against a simple baseline before operational use.
