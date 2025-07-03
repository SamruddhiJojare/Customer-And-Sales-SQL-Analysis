-- 1.
-- Creating the table.
CREATE TABLE Sales_Data_Final (
	Row_ID NUMERIC,
    order_id TEXT,
    product TEXT,
    quantity_ordered INT,
    price_each NUMERIC,
    order_date DATE,
    purchase_address TEXT,
    month INT,
    sales NUMERIC,
    city TEXT,
    hour INT
);

-- 2.
-- Fetched the data from the csv file to creates table manually through pgadmin(psql)
-- \COPY sales_data_final FROM 'C:/users/samru/Downloads/archive (8)/Sales Data.csv' DELIMITER ',' CSV HEADER;

-- BASIC ANALYSIS

-- 3.
-- Getting total revenue
select sum(sales) as Total_Revenue from sales_data_final;

-- 4.
-- Getting total number of orders
select count(order_id) as Total_Orders from sales_data_final;

-- 5.
-- Getting the list of cities to which the customers belong.
select distinct city from sales_data_final;

-- 6.
-- Most ordered products by quantity
select product, sum(quantity_ordered) as Quantity_Sold
from sales_data_final
group by product
order by Quantity_Sold desc;

-- 7.
-- Monthly revenue
select month, sum(sales) as Total_Sales
from sales_data_final
group by month
order by Total_Sales desc;

-- 8.
-- Top cities by revenue
select city, sum(sales) as Total_Revenue
from sales_data_final
group by city
order by Total_Revenue desc;

-- Intermediate Analysis

-- 9.
-- Repeat orders analysis - Orders contaning multiple products
-- As the order contains multiple products, multiple rows may have the same order_id.
select order_id
from sales_data_final
group by order_id
having count(order_id) > 1;

-- 10.
-- Hourly purchase pattern - Revenue
select hour as peak_hours, sum(sales) as Total_sales
from sales_data_final
group by hour
order by total_sales desc
limit 5;

-- 11.
-- Busiest cities during peak hours
-- Which cities have the highest sales 
-- activity during the most active shopping hours of the day?
-- Used a CTE here.
with peak_hours as(
select hour
from sales_data_final
group by hour
order by sum(sales) desc
limit 5
)
select city as peak_performing_cities, sum(sales) as Total_Revenue
from sales_data_final
where hour in (select hour from peak_hours)
group by city
order by Total_revenue desc
limit 5;

-- 12.
-- Non-peak hour performance
-- How the peak performing cities perform in non-peak hours ?
with peak_hours as(
	select hour
	from sales_data_final
	group by hour
	order by sum(sales) desc
	limit 5
)
select city, sum(sales) as Total_Revenue
from sales_data_final
where hour not in (select hour from peak_hours)
group by city
order by Total_revenue desc
limit 5;

-- 13.
-- Average order value per city
with order_totals as (
  select order_id, city, sum(sales) as order_total
  from sales_data_final
  group by order_id, city
)
select city, ROUND(avg(order_total), 2) as average_order_value
from order_totals
group by city
order by average_order_value desc;

-- 14.
-- Product price variation (MIN, MAX, AVG)
select product, min(price_each) as min_price,
max(price_each) as max_price, 
round(avg(price_each), 2) as average_price
from sales_data_final
group by product;

-- 15.
-- Best-performing product per city
WITH product_sales_per_city AS (
  SELECT city, product, SUM(sales) AS total_sales,
  ROW_NUMBER() OVER (PARTITION BY city ORDER BY SUM(sales) DESC) AS rn
  FROM sales_data_final
  GROUP BY city, product
)
SELECT city, product, total_sales
FROM product_sales_per_city
WHERE rn = 1
ORDER BY total_sales DESC;

-- 16.
-- % contribution of each city to total sales
SELECT city,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(sales) * 100.0 / SUM(SUM(sales)) OVER (), 2) AS percent_contribution
FROM sales_data_final
GROUP BY city
ORDER BY percent_contribution DESC;

