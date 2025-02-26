 
 
 /*
 --=============================================================================================================================================================
                                                                  Exploratory Data Analysis  (EDA)
 Our analysis shows that sales are strong in key countries and certain product categories, with a few top customers driving a large portion of revenue. 
 However, some products are underperforming, and certain regions have lower sales. 
 This highlights opportunities to optimize our product mix, engage less active customers, and expand into underperforming markets. 
 1. Customer Insights
 2. Sales & Revenue Trends
 3. Product Performance
 4. Customer Spending Behavior
 5. Geographic Trends
 --=============================================================================================================================================================
*/



 ---------------------------------------------------------------------------------------------------------------------------------------------------------------
  --                                                       Database Exploration 
----------------------------------------------------------------------------------------------------------------------------------------------------------------




  -- Explore All Objects in the Database
  Select * From INFORMATION_SCHEMA.TABLES


    -- Explore All Columns in the Database
Select * From  INFORMATION_SCHEMA.COLUMNS






---------------------------------------------------------------------------------------------------------------------------------------------------------------
              --                                                       Dimensions Exploration
---------------------------------------------------------------------------------------------------------------------------------------------------------------




-- Explore All Countries our customers come  from
Select DISTINCT country FROM gold.dim_customers
	
-- Explore all Categories ' the major Divisions'
Select DISTINCT category,subcategory,product_name FROM gold.dim_products


---------------------------------------------------------------------------------------------------------------------------------------------------------------
---                                                         Date Exploration
---------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Find the Date Of the First and Last order
-- How many Years of Sales are avaiable 
Select 
		MIN(order_date) as First_order_date,
		MAX(order_date) as last_order_date,
		DATEDIFF(MONTH,MIN(order_date),	MAX(order_date)) as order_range_months
From gold.fact_sales



-- find the younest and the oldest customer
Select  
		MIN(birthdate) as oldest_birthdate,
		DATEDIFF(YEAR,MIN(birthdate),getdate()) as Oldest_age ,
		Max(birthdate) as Youngest_birthdate,
		DATEDIFF(YEAR,Max(birthdate),getdate()) as Youngest_age 
from gold.dim_customers



---------------------------------------------------------------------------------------------------------------------------------------------------------------
--                                                       Measures Exploration
---------------------------------------------------------------------------------------------------------------------------------------------------------------



--  Find the total Sales
  Select SUM(sales_amount) as Tota_sales From gold.fact_sales

-- Find how many items are sold
  Select SUM(quanity) as Total_quantity  From gold.fact_sales

-- Find the average sellin price 
  Select AVG(price) From gold.fact_sales

  -- Find the total number of orders
  Select COUNT(order_number) as total_orders From gold.fact_sales

  Selec t COUNT(distinct order_number) as total_orders From gold.fact_sales


  -- Find  the  total number of products
  Select COUNT(product_key) as total_orders From gold.fact_sales
  Select COUNT(Distinct product_key) as total_orders From gold.fact_sales
  

-- Find the total number customers
    Select COUNT(Customer_key) as Total_number From gold.dim_customers


-- Find the Total number Customres that has pleced an order
    Select COUNT(Distinct Customer_key)  as Total_number From gold.fact_sales



-- Generate a Report that shows all key metrics of the business

SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity', SUM(quanity) FROM gold.fact_sales
UNION ALL
SELECT 'Average Price', AVG(price) FROM gold.fact_sales
UNION ALL
SELECT 'Total Nr. Orders', COUNT(DISTINCT order_number) FROM gold.fact_sales
UNION ALL
SELECT 'Total Nr. Products', COUNT(product_name) FROM gold.dim_products
UNION ALL
SELECT 'Total Nr. Customers', COUNT(customer_key) FROM gold.dim_customers


---------------------------------------------------------------------------------------------------------------------------------------------------------------
--                                                            Magnitude Explantion
---------------------------------------------------------------------------------------------------------------------------------------------------------------



 -- Find Total Customers by countries
SElECT 
		 ISNULL (country, 'n/a') as country , 
		 COUNT(Customer_key) as total_customers
From gold.dim_customers
group by country
order by COUNT(Customer_key)desc




-- Find total customers by gender
SElECT 
		 gender , 
		 COUNT(Customer_key) as total_customers
From gold.dim_customers
group by gender
order by COUNT(Customer_key)desc




 -- Find total product by category
SElECT 
		 category,
		 COUNT(product_key) as total_customers
From gold.dim_products
group by category
order by COUNT(product_key) desc
	
	


-- what is the average costs in each category ?
SElECT 
		 p.category,
		 AVG(s.price) avg_price
From gold.dim_products p
Right join gold.fact_sales s  on p.product_key = s.product_key 
group by category
order by AVG(s.price) desc




-- Find total reveune is genrated by each category 
SElECT 
		p.category,
		SUM(s.sales_amount)  Total_reveune
From gold.dim_products p
Right join gold.fact_sales s  on p.product_key = s.product_key 
group by category
order by 	SUM(s.sales_amount) desc





 -- what i sthe total revenue generated by each customer?
Select 
		c.Customer_key,
		c.first_name,
		c.last_name,
		SUM(s.sales_amount) Total_revenue
from gold.fact_sales s 
left join gold.dim_customers c on s.Customer_key = c.Customer_key
group by first_name 
order by SUM(s.sales_amount) Desc








 -- what is the distribution of sold items across Counstries?   
Select 
		c. country,
		SUM(s.quanity) total_sold_items
from gold.fact_sales s 
left join gold.dim_customers c on s.Customer_key = c.Customer_key
group by c. country
order by SUM(s.quanity) Desc




---------------------------------------------------------------------------------------------------------------------------------------------------------------
	  --                                                           Rankking Explantion
---------------------------------------------------------------------------------------------------------------------------------------------------------------



 -- WHICH 5 products generate the highest revenue
SElECT  top 5
		    p.product_name,
			SUM(s.sales_amount)  Total_reveune
From gold.dim_products p
Right join gold.fact_sales s  on p.product_key = s.product_key 
group by p.product_name
order by SUM(s.sales_amount) desc



 -- what are the 5 worest-performing products in terms of sales
 SElECT  top 5
		   p.product_name,
			SUM(s.sales_amount)  Total_reveune
			From gold.dim_products p
Right join gold.fact_sales s  on p.product_key = s.product_key 
group by p.product_name
order by 	SUM(s.sales_amount) 
 


 
 -- WHICH 5 subcategory generate the highest revenue
select
		* 
from
	  (
	  	   SElECT  
		 p.subcategory,
			SUM(s.sales_amount)  Total_reveune
			,ROW_NUMBER() over(order by SUM(s.sales_amount) desc ) rank_sales
	  From gold.dim_products p
	  Right join gold.fact_sales s  on p.product_key = s.product_key 
	  group by p.subcategory)t
	where rank_sales <= 5




-- WHICH 5 category generate the highest revenue
select 
		* 
from
	  (
	   SElECT  
		    p.category,
			SUM(s.sales_amount)  Total_reveune
			,ROW_NUMBER() over(order by SUM(s.sales_amount )  desc ) rank_sales
	  From gold.dim_products p
	  Right join gold.fact_sales s  on p.product_key = s.product_key 
	  group by p.category)t



	
---Find the Top-10 customers who have generated the highest revenue And 3 customers with the fewest orders placed
Select  top 10
		c.Customer_key,
		c.first_name,
		c.last_name,
		SUM(s.sales_amount) Total_revenue
 from gold.fact_sales s 
 left join gold.dim_customers c on s.Customer_key = c.Customer_key
 group by c.Customer_key , c.first_name ,c.last_name 
 order by SUM(s.sales_amount) Desc




 -- 3 customers with the fewest orders placed
Select  top 3
		c.Customer_key,
		c.first_name,
		c.last_name,
		COUNT(s.order_number) total_order
from gold.fact_sales s 
left join gold.dim_customers c on s.Customer_key = c.Customer_key
group by c.Customer_key , c.first_name ,c.last_name 
order by 	COUNT(s.order_number) 
