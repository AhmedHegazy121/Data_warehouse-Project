/*
====================================================================================================
Customer Report
====================================================================================================
Purpose:
  - this report consolidates key customer metrics and behaviors

Highlights :
	1.Gathers essential fields such as names, ages , and transaction details.
	2.Segments customes into categories (Vip , Regular, new) and age groups
	3.Aggregates customer-level mertrics :
	 -total orders
	 - total sales
	 - total quantity purchased
	 - total products
	 - lifespan (in months)
	4. Calculates valuable Kpis:
	 - recncy(months since last order)
	 - average order value
	 - average monthly spend
====================================================================================================
*/

 create view gold.report_customers as


with Base_query as (
/*---------------------------------------------------------------------------------------------------
1) Base Query : Retrives core columns from tables
----------------------------------------------------------------------------------------------------*/
Select
		f.order_number,
		f.product_key,
		f.order_date,
		f.sales_amount,
		f.quanity,
		c.Customer_key,
		c. customer_number,
		CONCAT(c.first_name,' ',c.last_name) as customer_name, 	
		datediff(YEAR, c.birthdate, GETDATE()) age
from gold.fact_sales F
LEFT JOIN gold.dim_customers C on c.Customer_key = f.Customer_key
where f.order_date is not null 

	)



, Customer_aggregatoin2 as (

/*---------------------------------------------------------------------------------------------------
2) Customer Agggergatoin : Summarizes key metrics at custoemer level
----------------------------------------------------------------------------------------------------*/
Select 
         Customer_key,
         customer_number,
		 customer_name, 	
		  age,
		 Count (Distinct order_number) as total_orders ,
		 SUM(sales_amount) as total_sales ,
		 SUM(quanity) as total_quantity,
		 COUNT(distinct product_key)as total_products,
		 MAX(order_date) as last_order_date,
		 DATEDIFF( MONTH , MIN(order_date) , MAX(order_date)  ) as lifespan
from Base_query
group by 

         Customer_key,
         customer_number,
		 customer_name, 	
		  age 
		 
	)


Select 
		 Customer_key,
         customer_number,
		 customer_name, 	
		 age ,
		 Case
			when age < 20 then 'Under 20'
			when age between 20 and 29 then '20-29'
			when age between 30 and 39 then '30-39'
			when age between 40 and  49 then '30-39'
			else '50 and above'
		end as age_group ,
		 case
			when  Lifespan >= 12 and total_sales >5000 Then 'VIP'
			when  Lifespan >= 12 and total_sales <= 5000 Then 'Regular'
			else 'New'
		end as customer_segment,
		 last_order_date,
		 DATEDIFF(MONTH, last_order_date , GETDATE ()) as  recency ,
		 total_orders ,
		 total_sales ,
		 total_quantity	,
		 total_products,
		 lifespan,
		 -- Compuate average order value (AVO)
		 case 
			 when total_sales = 0 then 0
			 else total_sales / total_orders 
		 end as avg_order_value ,

	-- Computes  average monthly send
	      case 
			 when lifespan = 0 then total_sales
			 else total_sales / lifespan
		 end as avg_monthly_spend
From Customer_aggregatoin2
