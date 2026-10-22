# Project Notes

- Company: fictional FreshMart supermarket group.
- Data: simulated records; do not represent real retailer performance.
- Main date coverage: 2025-01-01 to 2025-12-31.
- SQL engine: MySQL 8.0+ recommended because the analysis uses CTEs and window functions.
- Original user SQL is retained as `sql/Freshmart_analysis_original.sql`. The curated `sql/Freshmart_analysis.sql` is formatted and includes safer patterns such as deterministic latest-record selection, NULLIF safeguards, and data-driven forecast error calculations.
- The original result exports are preserved as snapshots under `results/`.
- Q13 is framed as an integrated action list and recommendation layer rather than a claim that a real business action was executed.
