select *
from products;

select *
from sales;

select *
from stores;

select *
from suppliers;

select *
from inventory;

select *
from demand;

select *
from replenishment;

Select *
from purchase_orders;

Select *
from waste;

Select *
from transfers;

--- Q1 -Which products are generating the highest sales volume and revenue? ---

Select pro.Product_ID,
       pro.Product_Name,
       pro.Unit_Cost,
	   sum(sal.Quantity_Sold) total_quantity, 
	   sum(sal.Revenue) total_revenue
from products pro
join sales sal
on pro.Product_ID = sal.Product_ID
group by pro.Product_ID,pro.Product_Name,pro.Unit_Cost
order by  total_revenue DESC
Limit 10;

-- Q1.1 What is the latest recorded closing stock for Cheese FreshChoice 1? -- 'P0011'

select product_id,closing_stock
from inventory
where Product_ID = 'P0011'
ORDER BY `DATE` DESC
LIMIT 1;


--- Q2 Which product categories generate the highest total revenue and sales volume? --

SELECT pro.category,
sum(sal.quantity_sold) total_sold_quantity,
sum(sal.revenue) total_revenue
FROM PRODUCTS PRO
join Sales sal
on pro.product_id = sal.product_id
group by  pro.category
order by total_revenue desc;

--- Q3 Which products have the highest current inventory levels, and how do those levels compare with their sales performance? ---

SELECT
	pro.Product_Name,
    inv.Product_ID,
    inv.Closing_Stock,
    COALESCE(sales_summary.total_sold, 0) AS total_sold,
    Round((inv.Closing_Stock/total_sold)*100,0) SSRatio,
   Round(inv.closing_stock/(total_sold/365),0) Days_of_inventory
    
FROM inventory inv
LEFT JOIN (
    SELECT
        Product_ID,
        SUM(Quantity_Sold) AS total_sold
    FROM sales
    GROUP BY Product_ID
) AS sales_summary 
    ON inv.Product_ID = sales_summary.Product_ID
join products pro
    ON inv.Product_ID = pro.Product_ID

WHERE inv.`Date` = (
    SELECT MAX(`Date`)
    FROM inventory
)

ORDER BY inv.Closing_Stock DESC
LIMIT 10;

--- Q4  Which products are at risk of stockout? ---

Select pro.Product_Name,
inv.product_id, 
inv.store_id,
`date`, 
inv.closing_stock
from inventory inv 
Join products pro 
on inv.Product_ID = pro.Product_ID
where `date` = (select max(`date`)
               from inventory
               )
order by Closing_Stock;

--- Q5 Which products have the highest demand? ---

select pro.Product_Name,dem.Product_ID,sum(dem.Demand_Qty) total_demand
from demand dem
join products pro 
on  pro.product_ID = dem.product_ID
group by  pro.Product_Name,dem.Product_ID
order by total_demand DESC;

---- Q6 Which products have the highest replenishment quantities? ---

Select pro.Product_Name, rep.Product_ID, rep.Store_ID, sum(rep.Recommended_Order_Qty) Total_rec_Qty, sum(rep.Actual_Order_Qty) Total_Actual_Qty
from replenishment rep 
join products pro 
ON rep.Product_ID = pro.Product_ID
group by  pro.Product_Name, rep.Product_ID, rep.Store_ID
order by Total_rec_Qty DESC;


--- Q7 Which suppliers have the longest lead times? ---

Select sup.Supplier_Name, pur.Supplier_ID,count(pur.Supplier_ID) Total_orders, round(avg(datediff(Actual_Delivery_Date,PO_Date)),0) AS lead_time
from purchase_orders pur 
JOIN suppliers  sup 
on pur.Supplier_ID = sup.Supplier_ID
group by sup.Supplier_Name, pur.Supplier_ID
order by lead_time DESC;

--- Q8 Which products generate the highest waste quantities? ---

select pro.product_name, was.Product_ID, sum(was.Quantity) as Total_waste, sum(was.Inventory_Value) as Total_Value
from waste was
join  products pro 
on was.Product_ID = pro.Product_ID
group by pro.product_name, was.Product_ID
order by Total_waste DESC;

--- Q9 Which products are transferred most frequently between stores, and in what quantities? ---

select pro.Product_Name, tra.Product_ID, count(tra.Product_ID) Products_count, sum(tra.Quantity) Total_QTY
from transfers tra
join products pro
on tra.Product_ID = pro.Product_ID
group by pro.Product_Name, tra.Product_ID
order by Products_count DESC;

--- Q10 Which products contribute most to total sales value? ---
with Product_revenue AS 
(
Select pro.Product_ID, pro.Product_Name, sum(sal.Revenue) Total_Revenue
from products pro
JOIN sales sal 
ON pro.Product_ID = sal.Product_ID
group by  pro.Product_ID, pro.Product_Name
),
Revenue_percentage AS (
Select Product_ID, Product_Name, total_revenue AS Product_revenue, sum(total_revenue) over () Total_All_Products_revenue, ROUND(
        (Total_Revenue / SUM(Total_Revenue) OVER ()) * 100,2) AS Revenue_Percentage
from product_revenue
),
Cumulative_Revenue AS (
SELECT Product_ID, Product_Name,Product_revenue,Total_All_Products_revenue,Revenue_Percentage,ROUND(SUM(Revenue_Percentage) 
OVER (ORDER BY Product_revenue DESC),2) AS Cumulative_Revenue_Percentage
FROM Revenue_percentage
)

Select Product_ID, Product_Name,Product_revenue,Total_All_Products_revenue,Revenue_Percentage,Cumulative_Revenue_Percentage,
case 
    when Cumulative_Revenue_Percentage <= 80 then "A"
    when Cumulative_Revenue_Percentage <= 95 then "B"
    else "C" END ABC_Category
from Cumulative_Revenue;

--- Q11 Which products have the most stable or variable demand over time? ---

with Demand_Std_Avg as 
(
select Product_ID, avg(Demand_Qty)Average_Demand,round(stddev_pop(Demand_Qty),2)Std_demand
from demand
group by Product_ID
),
CV_Percentage_demand as 
(
select product_id,Average_Demand,Std_demand,  ROUND((Std_demand / NULLIF(Average_Demand, 0)) * 100,2) AS CV_Percentage
from Demand_Std_Avg
)

select product_id,Average_Demand,Std_demand,CV_Percentage,
case 
when CV_Percentage <10 then "X" 
when CV_Percentage between 10 and 25 then "Y" 
ELSE "Z"
END XYZ_Analyze
from CV_Percentage_demand
order by XYZ_Analyze;


--- Q12 What is the expected demand for selected products in the next period? ---

select Product_ID, `date`, Demand_Qty
FROM demand
where Product_ID = "P0037"
order by `date`
limit 10;

select count(distinct`date`)
from demand
where Product_ID = "P0037"
order by `date`;

with Date_Seg as 
(
select Product_ID,date_format(`date`,"%Y%-%m") Date_formatt,sum(demand_Qty) total_Demand_QTY
from demand
where Product_ID = "P0037"
group by Product_ID,Date_formatt
),
Oct_forec as 
(
select Product_ID,AVG(total_Demand_QTY) Total_Average
from Date_Seg
where Date_formatt between "2025-07" and "2025-09"
group by Product_ID
)

select oc.Total_Average, da.total_Demand_QTY,abs(oc.Total_Average - 117)Absoulte_diff, round((abs(oc.Total_Average - 117) / da.total_Demand_QTY) * 100,2) as MAPE 
from Oct_forec oc 
join Date_Seg da
on oc.product_id = da.product_id
where  da.Date_formatt = "2025-10"

