# FreshMart Supply Chain & Inventory Analysis

**SQL portfolio project | MySQL 8.0+ | Retail / Grocery Supply Chain**

## Project overview

FreshMart is a fictional supermarket group used to explore practical supply-chain and inventory questions with SQL. The project analyzes sales, demand, inventory, replenishment, supplier lead times, waste, and store transfers, then translates findings into operational recommendations.

> **Data note:** All company names and records are simulated for learning and portfolio purposes. Results describe this synthetic dataset and should not be interpreted as real business performance.

## Business objectives

- Identify products and categories contributing the most sales and revenue.
- Compare current recorded stock with historical sales and screen for potential stockout risk.
- Understand demand and replenishment quantities.
- Compare supplier lead times and review waste by quantity and financial value.
- Analyze store-transfer activity.
- Classify products using ABC revenue contribution and XYZ demand variability.
- Demonstrate a simple moving-average forecast and evaluate its error.
- Turn the findings into practical inventory and supplier-management actions.

## Dataset

The project includes 10 CSV tables covering 2025-01-01 through 2025-12-31 where date fields apply.

| Table | Rows | Purpose |
|---|---:|---|
| products | 133 | Product attributes, category, cost, selling price, shelf life |
| sales | 20,000 | Transaction-level product sales and revenue |
| stores | 20 | Store locations and characteristics |
| suppliers | 40 | Supplier reference data |
| inventory | 10,000 | Recorded stock snapshots and stock movements |
| demand | 12,000 | Recorded demand by date, store, and product |
| replenishment | 5,000 | Reorder point, safety stock, recommended and actual order quantities |
| purchase_orders | 3,500 | Purchase orders and delivery dates |
| waste | 4,000 | Waste quantities and recorded inventory value |
| transfers | 2,000 | Store-to-store product transfers |

## Questions covered

1. Which products generate the highest sales volume and revenue?
2. Which categories generate the highest revenue and sales volume?
3. Which products have the highest latest recorded stock, and how does it compare with annual sales?
4. Which product/store combinations should be screened for possible stockout risk?
5. Which products have the highest recorded demand?
6. How do recommended replenishment quantities compare with actual quantities?
7. Which suppliers have the longest average actual lead times?
8. Which products have the highest waste quantity and waste value?
9. Which products are transferred most often, and in what quantities?
10. How do products classify under ABC analysis by revenue?
11. How variable is recorded demand under a coefficient-of-variation (XYZ) approach?
12. What is a three-month moving-average forecast for a selected product, and how does it compare with actual demand?
13. Which products should be prioritized for integrated replenishment review, considering inventory and reorder settings?

## Selected findings

- **Top revenue product:** Pasta AquaPlus 6 generated AED 102,919.86 across 2,136 units in the supplied top-10 result.
- **Total sales revenue in the dataset:** AED 2,978,394.08.
- **Inventory review candidate:** Cooking Oil AquaPlus 6 had a latest recorded closing stock of 849 units in the supplied result and approximately 179 days of inventory using the annual-sales-based proxy. This is a screening signal, not proof of excess stock.
- **Supplier lead-time signal:** Supplier 32 had an average actual lead time of 10 days across 82 purchase-order records in the supplied result. Lead-time average alone does not establish supplier quality or on-time performance.
- **Waste:** the data contain 18,493 recorded waste units and AED 310,187.01 of recorded waste value. The product with the highest waste quantity may differ from the product with the highest financial waste value.
- **ABC:** the supplied result uses revenue contribution and illustrative 80% / 95% cumulative thresholds. See `results/Q10_results.csv` for product-level classifications.
- **XYZ:** using the supplied thresholds (<10% X, 10–25% Y, >25% Z), all 133 products classify as Z in this dataset. This may reflect the synthetic data and the chosen calculation grain; it is a limitation to disclose, not something to hide.
- **Forecast test:** product P0037 had a July–September average monthly demand of 94.00 units; October actual demand was 117. Absolute error was 23 units and MAPE was 19.66% for this single test month only.

## SQL methods

- `JOIN` / `LEFT JOIN` for combining business tables
- Aggregations with `SUM`, `AVG`, `COUNT`, and `GROUP BY`
- `CASE` expressions for classifications and action flags
- CTEs (`WITH`) for staged calculations
- Window functions for latest records and cumulative ABC contribution
- `DATEDIFF`, `DATE_FORMAT`, `NULLIF`, and `ABS` for lead-time, monthly demand, and error calculations

## Recommendations

1. **Prioritize inventory by business impact and availability risk.** Review high-revenue / high-priority items with low stock, current demand, reorder points, safety stock, and open purchase orders before deciding the order quantity.
2. **Investigate waste by both units and financial value.** Review waste reasons, store, shelf life, and replenishment quantities; adjust ordering and rotation practices where supported by the data.
3. **Use demand-based replenishment.** Combine sales/demand, latest stock, reorder settings, supplier lead time, and open POs instead of automatically increasing order quantities for every top seller.
4. **Review supplier reliability beyond average lead time.** Track on-time delivery, missing delivery dates, and lead-time variability before changing supplier allocations.
5. **Treat ABC/XYZ as decision support, not an automatic rule.** Validate thresholds and demand grain before applying classifications to operational policies.

## Limitations

- The dataset is simulated; patterns and findings are not evidence of actual company performance.
- Inventory and demand records are not guaranteed to form complete daily time series for every product/store combination.
- Days-of-inventory is a rough proxy based on annual sales and should not be treated as a forecast.
- Low stock sorted by quantity is not by itself proof of stockout risk; reorder settings, demand rate, lead time, and open orders matter.
- XYZ CV in this version is calculated across recorded demand rows per product rather than a complete daily/monthly time series. The fact that all products classify as Z means the method/thresholds need business validation.
- Forecast accuracy is demonstrated on one held-out month for one product. A robust evaluation should test several months and compare with a baseline.
- ABC cutoffs (80% / 95%) are illustrative and may vary by business.

## Repository structure

```text
FreshMart_Supply_Chain_Portfolio/
├── README.md
├── data/                 # Source CSVs
├── sql/
│   ├── freshmart_supply_chain_schema.sql
│   ├── Freshmart_analysis.sql
│   └── Freshmart_analysis_original.sql
├── results/              # Exported result tables used in the write-up
└── documentation/
    ├── data_inventory.csv
    ├── business_recommendations.md
    └── project_notes.md
```

## How to run

1. Open MySQL Workbench and execute `sql/freshmart_supply_chain_schema.sql` to create the database and tables.
2. Import the CSV files from `data/` into the matching tables. Respect the foreign-key relationships; import reference tables (`stores`, `products`, `suppliers`) before dependent tables.
3. Open and run `sql/Freshmart_analysis.sql` in MySQL 8.0 or later.
4. Review exported examples in `results/`. Some result CSVs are supplied snapshots from the analysis session; they may not match if the database or SQL is changed.

## Skills demonstrated

SQL querying, data aggregation, relational joins, CTEs, window functions, inventory analysis, replenishment logic, supplier lead-time analysis, waste analysis, ABC/XYZ methods, and basic forecast evaluation.
