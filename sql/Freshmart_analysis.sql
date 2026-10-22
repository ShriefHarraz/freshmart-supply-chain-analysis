-- FreshMart Supply Chain & Inventory Analysis
-- MySQL 8.0+
-- All data are simulated for portfolio/learning purposes.
USE freshmart_supply_chain;

-- Q1. Which products generate the highest sales volume and revenue?
SELECT p.Product_ID, p.Product_Name,
       SUM(s.Quantity_Sold) AS Total_Quantity,
       ROUND(SUM(s.Revenue), 2) AS Total_Revenue
FROM products p
JOIN sales s ON s.Product_ID = p.Product_ID
GROUP BY p.Product_ID, p.Product_Name
ORDER BY Total_Revenue DESC
LIMIT 10;

-- Q2. Which categories generate the highest revenue and sales volume?
SELECT p.Category,
       SUM(s.Quantity_Sold) AS Total_Sold_Quantity,
       ROUND(SUM(s.Revenue), 2) AS Total_Revenue
FROM products p
JOIN sales s ON s.Product_ID = p.Product_ID
GROUP BY p.Category
ORDER BY Total_Revenue DESC;

-- Q3. Latest recorded inventory by product and store, compared with annual sales.
-- Days of inventory is a rough annual-sales-based proxy, not a forward-looking forecast.
WITH LatestInventory AS (
    SELECT i.*,
           ROW_NUMBER() OVER (
               PARTITION BY i.Product_ID, i.Store_ID
               ORDER BY i.Date DESC, i.Inventory_ID DESC
           ) AS rn
    FROM inventory i
), SalesByProduct AS (
    SELECT Product_ID, SUM(Quantity_Sold) AS Total_Sold
    FROM sales
    GROUP BY Product_ID
)
SELECT p.Product_Name, i.Product_ID, i.Store_ID, i.Date,
       i.Closing_Stock,
       COALESCE(s.Total_Sold, 0) AS Total_Sold_2025,
       ROUND(i.Closing_Stock / NULLIF(s.Total_Sold, 0) * 100, 2) AS Stock_to_Annual_Sales_Pct,
       ROUND(i.Closing_Stock / NULLIF(s.Total_Sold / 365.0, 0), 0) AS Approx_Days_of_Inventory
FROM LatestInventory i
JOIN products p ON p.Product_ID = i.Product_ID
LEFT JOIN SalesByProduct s ON s.Product_ID = i.Product_ID
WHERE i.rn = 1
ORDER BY i.Closing_Stock DESC
LIMIT 10;

-- Q4. Screen for potential stockout risk using latest inventory and latest replenishment settings.
-- This is a risk screen, not proof of a stockout; demand rate and supplier lead time should also be reviewed.
WITH LatestInventory AS (
    SELECT i.*, ROW_NUMBER() OVER (
        PARTITION BY Product_ID, Store_ID ORDER BY Date DESC, Inventory_ID DESC
    ) AS rn
    FROM inventory i
), LatestReplenishment AS (
    SELECT r.*, ROW_NUMBER() OVER (
        PARTITION BY Product_ID, Store_ID ORDER BY Date DESC, Replenishment_ID DESC
    ) AS rn
    FROM replenishment r
)
SELECT p.Product_Name, i.Product_ID, i.Store_ID, i.Date,
       i.Closing_Stock, r.Reorder_Point, r.Safety_Stock,
       CASE WHEN r.Reorder_Point IS NOT NULL AND i.Closing_Stock <= r.Reorder_Point
            THEN 'Review for replenishment' ELSE 'Monitor' END AS Risk_Flag
FROM LatestInventory i
JOIN products p ON p.Product_ID = i.Product_ID
LEFT JOIN LatestReplenishment r
  ON r.Product_ID = i.Product_ID AND r.Store_ID = i.Store_ID AND r.rn = 1
WHERE i.rn = 1
ORDER BY (i.Closing_Stock <= COALESCE(r.Reorder_Point, -1)) DESC,
         i.Closing_Stock ASC;

-- Q5. Which products have the highest total recorded demand?
SELECT p.Product_Name, d.Product_ID, SUM(d.Demand_Qty) AS Total_Demand
FROM demand d
JOIN products p ON p.Product_ID = d.Product_ID
GROUP BY p.Product_Name, d.Product_ID
ORDER BY Total_Demand DESC;

-- Q6. Recommended versus actual replenishment quantities by product and store.
SELECT p.Product_Name, r.Product_ID, r.Store_ID,
       SUM(r.Recommended_Order_Qty) AS Total_Recommended_Qty,
       SUM(r.Actual_Order_Qty) AS Total_Actual_Qty,
       SUM(r.Actual_Order_Qty - r.Recommended_Order_Qty) AS Actual_Minus_Recommended
FROM replenishment r
JOIN products p ON p.Product_ID = r.Product_ID
GROUP BY p.Product_Name, r.Product_ID, r.Store_ID
ORDER BY Total_Recommended_Qty DESC;

-- Q7. Which suppliers have the longest average actual lead times?
-- AVG ignores NULL delivery dates; open orders are not included in the lead-time average.
SELECT s.Supplier_Name, po.Supplier_ID,
       COUNT(*) AS Total_Orders,
       COUNT(po.Actual_Delivery_Date) AS Delivered_Orders,
       ROUND(AVG(DATEDIFF(po.Actual_Delivery_Date, po.PO_Date)), 2) AS Avg_Actual_Lead_Time_Days
FROM purchase_orders po
JOIN suppliers s ON s.Supplier_ID = po.Supplier_ID
GROUP BY s.Supplier_Name, po.Supplier_ID
ORDER BY Avg_Actual_Lead_Time_Days DESC;

-- Q8. Which products generate the highest waste quantity and waste value?
SELECT p.Product_Name, w.Product_ID,
       SUM(w.Quantity) AS Total_Waste_Qty,
       ROUND(SUM(w.Inventory_Value), 2) AS Total_Waste_Value
FROM waste w
JOIN products p ON p.Product_ID = w.Product_ID
GROUP BY p.Product_Name, w.Product_ID
ORDER BY Total_Waste_Value DESC;

-- Q9. Which products are transferred most often, and in what quantities?
SELECT p.Product_Name, t.Product_ID,
       COUNT(*) AS Transfer_Record_Count,
       SUM(t.Quantity) AS Total_Transfer_Qty
FROM transfers t
JOIN products p ON p.Product_ID = t.Product_ID
GROUP BY p.Product_Name, t.Product_ID
ORDER BY Transfer_Record_Count DESC, Total_Transfer_Qty DESC;

-- Q10. ABC classification by 2025 revenue.
-- 80% / 95% thresholds are illustrative policy choices. Cumulative sum uses a deterministic order.
WITH ProductRevenue AS (
    SELECT p.Product_ID, p.Product_Name, SUM(s.Revenue) AS Product_Revenue
    FROM products p JOIN sales s ON s.Product_ID = p.Product_ID
    GROUP BY p.Product_ID, p.Product_Name
), RevenueShare AS (
    SELECT Product_ID, Product_Name, Product_Revenue,
           SUM(Product_Revenue) OVER () AS Total_All_Products_Revenue,
           Product_Revenue / NULLIF(SUM(Product_Revenue) OVER (), 0) * 100 AS Revenue_Percentage
    FROM ProductRevenue
), CumulativeRevenue AS (
    SELECT *,
           SUM(Revenue_Percentage) OVER (
               ORDER BY Product_Revenue DESC, Product_ID
               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
           ) AS Cumulative_Revenue_Percentage
    FROM RevenueShare
)
SELECT Product_ID, Product_Name, ROUND(Product_Revenue, 2) AS Product_Revenue,
       ROUND(Total_All_Products_Revenue, 2) AS Total_All_Products_Revenue,
       ROUND(Revenue_Percentage, 2) AS Revenue_Percentage,
       ROUND(Cumulative_Revenue_Percentage, 2) AS Cumulative_Revenue_Percentage,
       CASE WHEN Cumulative_Revenue_Percentage <= 80 THEN 'A'
            WHEN Cumulative_Revenue_Percentage <= 95 THEN 'B'
            ELSE 'C' END AS ABC_Category
FROM CumulativeRevenue
ORDER BY Product_Revenue DESC, Product_ID;

-- Q11. XYZ analysis using coefficient of variation (CV) across recorded demand rows.
-- Important limitation: rows are not a complete daily time series for every product/store.
-- Since all products fall above 25% CV with these thresholds, all classify as Z.
WITH DemandStats AS (
    SELECT Product_ID,
           AVG(Demand_Qty) AS Average_Demand,
           STDDEV_POP(Demand_Qty) AS Std_Demand
    FROM demand
    GROUP BY Product_ID
), DemandCV AS (
    SELECT Product_ID, Average_Demand, Std_Demand,
           STD_Demand / NULLIF(Average_Demand, 0) * 100 AS CV_Percentage
    FROM DemandStats
)
SELECT Product_ID, ROUND(Average_Demand, 2) AS Average_Demand,
       ROUND(Std_Demand, 2) AS Std_Demand,
       ROUND(CV_Percentage, 2) AS CV_Percentage,
       CASE WHEN CV_Percentage < 10 THEN 'X'
            WHEN CV_Percentage <= 25 THEN 'Y'
            ELSE 'Z' END AS XYZ_Category
FROM DemandCV
ORDER BY CV_Percentage, Product_ID;

-- Q12. Three-month moving-average forecast test for product P0037.
-- Forecast October 2025 from July-September 2025; actual demand is retrieved from data.
WITH MonthlyDemand AS (
    SELECT Product_ID, DATE_FORMAT(Date, '%Y-%m') AS Year_Month,
           SUM(Demand_Qty) AS Monthly_Demand
    FROM demand
    WHERE Product_ID = 'P0037'
    GROUP BY Product_ID, DATE_FORMAT(Date, '%Y-%m')
), Forecast AS (
    SELECT Product_ID, AVG(Monthly_Demand) AS Forecast_Demand
    FROM MonthlyDemand
    WHERE Year_Month BETWEEN '2025-07' AND '2025-09'
    GROUP BY Product_ID
)
SELECT f.Product_ID,
       ROUND(f.Forecast_Demand, 2) AS Forecast_Demand,
       a.Monthly_Demand AS Actual_October_Demand,
       ROUND(ABS(f.Forecast_Demand - a.Monthly_Demand), 2) AS Absolute_Error,
       ROUND(ABS(f.Forecast_Demand - a.Monthly_Demand) / NULLIF(a.Monthly_Demand, 0) * 100, 2) AS MAPE_Percent
FROM Forecast f
JOIN MonthlyDemand a ON a.Product_ID = f.Product_ID AND a.Year_Month = '2025-10';

-- Q13. Integrated supply-chain action list: products at/below reorder point.
-- Use as a starting worklist; validate against demand, open POs, supplier lead time, and perishability.
WITH LatestInventory AS (
    SELECT i.*, ROW_NUMBER() OVER (
        PARTITION BY Product_ID, Store_ID ORDER BY Date DESC, Inventory_ID DESC
    ) AS rn
    FROM inventory i
), LatestReplenishment AS (
    SELECT r.*, ROW_NUMBER() OVER (
        PARTITION BY Product_ID, Store_ID ORDER BY Date DESC, Replenishment_ID DESC
    ) AS rn
    FROM replenishment r
)
SELECT p.Product_Name, i.Product_ID, i.Store_ID, i.Closing_Stock,
       r.Reorder_Point, r.Safety_Stock,
       CASE WHEN i.Closing_Stock <= COALESCE(r.Reorder_Point, -1)
            THEN 'Prioritize replenishment review' ELSE 'Continue monitoring' END AS Recommended_Action
FROM LatestInventory i
JOIN products p ON p.Product_ID = i.Product_ID
LEFT JOIN LatestReplenishment r
  ON r.Product_ID = i.Product_ID AND r.Store_ID = i.Store_ID AND r.rn = 1
WHERE i.rn = 1
ORDER BY (i.Closing_Stock <= COALESCE(r.Reorder_Point, -1)) DESC, i.Closing_Stock ASC;
