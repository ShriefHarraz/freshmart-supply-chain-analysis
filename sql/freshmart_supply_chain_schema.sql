CREATE DATABASE IF NOT EXISTS freshmart_supply_chain;
USE freshmart_supply_chain;

CREATE TABLE products (
 Product_ID VARCHAR(10) PRIMARY KEY, Product_Name VARCHAR(150), Category VARCHAR(50),
 Subcategory VARCHAR(50), Brand VARCHAR(80), Unit_Cost DECIMAL(10,2),
 Selling_Price DECIMAL(10,2), Shelf_Life_Days INT, Is_Perishable TINYINT);

CREATE TABLE suppliers (
 Supplier_ID VARCHAR(10) PRIMARY KEY, Supplier_Name VARCHAR(100),
 Supplier_Category VARCHAR(50), Payment_Terms VARCHAR(30));

CREATE TABLE stores (
 Store_ID VARCHAR(10) PRIMARY KEY, Store_Name VARCHAR(120), City VARCHAR(80),
 Country VARCHAR(40), Store_Type VARCHAR(40), Store_Size INT);

CREATE TABLE sales (
 Sale_ID VARCHAR(15) PRIMARY KEY, Sale_Date DATE, Store_ID VARCHAR(10),
 Product_ID VARCHAR(10), Quantity_Sold INT, Selling_Price DECIMAL(10,2),
 Discount DECIMAL(10,2), Revenue DECIMAL(12,2),
 FOREIGN KEY(Store_ID) REFERENCES stores(Store_ID),
 FOREIGN KEY(Product_ID) REFERENCES products(Product_ID));

CREATE TABLE inventory (
 Inventory_ID VARCHAR(15) PRIMARY KEY, Date DATE, Store_ID VARCHAR(10),
 Product_ID VARCHAR(10), Opening_Stock INT, Stock_Received INT, Transfer_In INT,
 Transfer_Out INT, Damaged_Qty INT, Expired_Qty INT, Closing_Stock INT,
 FOREIGN KEY(Store_ID) REFERENCES stores(Store_ID),
 FOREIGN KEY(Product_ID) REFERENCES products(Product_ID));

CREATE TABLE purchase_orders (
 PO_ID VARCHAR(15) PRIMARY KEY, PO_Date DATE, Supplier_ID VARCHAR(10),
 Store_ID VARCHAR(10), Product_ID VARCHAR(10), Order_Qty INT,
 Expected_Delivery_Date DATE, Actual_Delivery_Date DATE, Received_Qty INT,
 FOREIGN KEY(Supplier_ID) REFERENCES suppliers(Supplier_ID),
 FOREIGN KEY(Store_ID) REFERENCES stores(Store_ID),
 FOREIGN KEY(Product_ID) REFERENCES products(Product_ID));

CREATE TABLE demand (
 Date DATE, Store_ID VARCHAR(10), Product_ID VARCHAR(10), Demand_Qty INT,
 FOREIGN KEY(Store_ID) REFERENCES stores(Store_ID),
 FOREIGN KEY(Product_ID) REFERENCES products(Product_ID));

CREATE TABLE replenishment (
 Replenishment_ID VARCHAR(15) PRIMARY KEY, Date DATE, Store_ID VARCHAR(10),
 Product_ID VARCHAR(10), Current_Stock INT, Reorder_Point INT,
 Recommended_Order_Qty INT, Actual_Order_Qty INT, Safety_Stock INT,
 FOREIGN KEY(Store_ID) REFERENCES stores(Store_ID),
 FOREIGN KEY(Product_ID) REFERENCES products(Product_ID));

CREATE TABLE waste (
 Waste_ID VARCHAR(15) PRIMARY KEY, Date DATE, Store_ID VARCHAR(10),
 Product_ID VARCHAR(10), Quantity INT, Waste_Type VARCHAR(40),
 Inventory_Value DECIMAL(12,2),
 FOREIGN KEY(Store_ID) REFERENCES stores(Store_ID),
 FOREIGN KEY(Product_ID) REFERENCES products(Product_ID));

CREATE TABLE transfers (
 Transfer_ID VARCHAR(15) PRIMARY KEY, Transfer_Date DATE, From_Store_ID VARCHAR(10),
 To_Store_ID VARCHAR(10), Product_ID VARCHAR(10), Quantity INT,
 FOREIGN KEY(From_Store_ID) REFERENCES stores(Store_ID),
 FOREIGN KEY(To_Store_ID) REFERENCES stores(Store_ID),
 FOREIGN KEY(Product_ID) REFERENCES products(Product_ID));
