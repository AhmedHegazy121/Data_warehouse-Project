-- Analyze Metrics performance Over time
-- A high-level overview insights that helps with strategic decision-making.
-- Detailed insight to discover seasonality in your data
Select 
	YEAR (s.order_date) year,
	SUM(s.sales_amount) total_sales,
	COUNT(distinct s.Customer_key)  Total_customer,
	SUM(s.quanity) Total_Quantity
from gold.fact_sales s
where order_date is  not null
group by YEAR (s.order_date) 
order by YEAR (s.order_date)

-- Detailed insight to discover seasonality in your data`

Select 
	datename (MONTH,s.order_date) month,
	SUM(s.sales_amount) total_sales,
	COUNT(distinct s.Customer_key)  Total_customer,
	SUM(s.quanity) Total_Quantity
from gold.fact_sales s
where order_date is  not null
group by  datename (MONTH,s.order_date) 
order by datename (MONTH,s.order_date)



Select 
	Datetrunc (MONTH,s.order_date) month,
	SUM(s.sales_amount) total_sales,
	COUNT(distinct s.Customer_key)  Total_customer,
	SUM(s.quanity) Total_Quantity
from gold.fact_sales s
where order_date is  not null
group by  Datetrunc (MONTH,s.order_date) 
order by Datetrunc (MONTH,s.order_date)



---  cumulative analysis 

-- Calcaulate the total sales per month and the running total of sales over time

Select
	month,
	total_sales,
	SUM(total_sales) over(order by month) running_total_sales,
	AVG(avg_sales) over( order by month) running_avg_sales
From
(
Select 
	Datetrunc (MONTH,s.order_date) month,
	SUM(s.sales_amount) total_sales,
	AVG(S.sales_amount) avg_sales
from gold.fact_sales s
where order_date is  not null
group by  Datetrunc (MONTH,s.order_date) 
)t



Select
	YEAR,
	total_sales,
	SUM(total_sales) over( order by YEAR) running_total_sales,
	AVG(avg_sales) over( order by YEAR) running_avg_sales
From
(
Select 
	Datetrunc (YEAR,s.order_date) YEAR,
	SUM(s.sales_amount) total_sales,
	AVG(s.sales_amount) avg_sales
from gold.fact_sales s
where order_date is  not null
group by  Datetrunc (YEAR,s.order_date) 
)t


---                                      Performance Analysis 
--Analyze the yearly performance of products by comparing each products sales to both 
-- its average sales performance and the previous year's sales

with yearly_product_sales as (
Select 
	YEAR(s.order_date) as order_date ,
	p.product_name,
	SUM(s.sales_amount) as current_sales
From gold.fact_sales s
left join gold.dim_products p
on p.product_key = s.product_key
where order_date is not null
group by YEAR(s.order_date) , 	p.product_name
)

Select 
	order_date,
	product_name,
	current_sales, 
	AVG(current_sales) over (partition by order_date ) avg_sales,
	current_sales - AVG(current_sales) over (partition by order_date ) diff_avg,
	case
	when current_sales - AVG(current_sales) over (partition by order_date ) > 0 THEN 'above avg'
	when current_sales - AVG(current_sales) over (partition by order_date ) < 0 THEN 'below avg'
	Else'avg' end as avg_chage,
	-- year over year
	LAG(current_sales) over (partition by product_name order by order_date) py_sales,
	current_sales -LAG(current_sales) over (partition by product_name order by order_date) diff_py,
	case
	when current_sales - LAG(current_sales) over (partition by product_name order by order_date) > 0 THEN 'increase'
	when current_sales -LAG(current_sales) over (partition by product_name order by order_date) < 0 THEN 'decrease'
	Else'no change' end as py_change
from yearly_product_sales;







with yearly_product_sales as (
Select 
	format(s.order_date,'MMM') as order_date ,
	p.product_name,
	SUM(s.sales_amount) as current_sales
From gold.fact_sales s
left join gold.dim_products p
on p.product_key = s.product_key
where order_date is not null
group by format(s.order_date,'MMM') , 	p.product_name
)

Select 
	order_date,
	product_name,
	current_sales, 
	AVG(current_sales) over (partition by order_date ) avg_sales,
	current_sales - AVG(current_sales) over (partition by order_date ) diff_avg,
	case
	when current_sales - AVG(current_sales) over (partition by order_date ) > 0 THEN 'above avg'
	when current_sales - AVG(current_sales) over (partition by order_date ) < 0 THEN 'below avg'
	Else'avg' end as avg_chage,
	-- year over year
	LAG(current_sales) over (partition by product_name order by order_date) py_sales,
	current_sales -LAG(current_sales) over (partition by product_name order by order_date) diff_py,
	case
	when current_sales - LAG(current_sales) over (partition by product_name order by order_date) > 0 THEN 'increase'
	when current_sales -LAG(current_sales) over (partition by product_name order by order_date) < 0 THEN 'decrease'
	Else'no change' end as py_change
from yearly_product_sales;

---                    part-to-whole analysis
--Which categories contribute the most to overall sales?

with Categories_contribute as(
Select 
	p.category,
	SUM(s.sales_amount) total_sale
from gold.fact_sales s
left join gold. dim_products p  on p.product_key = s.product_key
 group by p.category )
 
 select
	  category,
	  total_sale,
	  sum(total_sale)over() as overall_sales,
	  concat (round ((cast(total_sale as float) / sum(total_sale)over()) * 100 ,2), '%' ) as percentage_of_total
 from Categories_contribute
 order by percentage_of_total 

 --Which categories contribute the most to overall Quantity?

 with Categories_contribute as(
Select 
	p.category,
	SUM(s.quanity) total_Quanity
from gold.fact_sales s
left join gold. dim_products p  on p.product_key = s.product_key
 group by p.category )
 
 select
	  category,
	  total_Quanity,
	  sum(total_Quanity)over() as overall_sales,
	  concat (round ((cast(total_Quanity as float) / sum(total_Quanity)over()) * 100 ,2), '%' ) as percentage_of_total
 from Categories_contribute
 order by percentage_of_total ;


 --Which categories contribute the most to overall price?

  with Categories_contribute as(
Select 
	p.category,
	SUM(s.price) total_price
from gold.fact_sales s
left join gold. dim_products p  on p.product_key = s.product_key
 group by p.category )
 
 select
	  category,
	  total_price,
	  sum(total_price)over() as overall_sales,
	  concat (round ((cast(total_price as float) / sum(total_price)over()) * 100 ,2), '%' ) as percentage_of_total
 from Categories_contribute
 order by percentage_of_total 




   with Categories_contribute as(
Select 
	p.category,
	SUM(s.sales_amount) total_sale,
	SUM(s.price) total_price
from gold.fact_sales s
left join gold. dim_products p  on p.product_key = s.product_key
 group by p.category )
 
 select
	  category,
	  total_sale,
	  total_price,
	 total_sale - total_price as profit ,
 from Categories_contribute;

     
 -- Datas segmentation 

 -- Segment products into cost ranges and count how many products fall into each segment


 with product_segments as (
 Select 
	product_key,
	product_name,
	cost,
	Case 
		when cost < 100 then 'Below 100'
		when cost between 100 and 500 then '100-500'
		else 'above 1000'
	end as cost_range
 from gold.dim_products )
 
 select
		cost_range ,
		COUNT(product_name)as Total_product
 from product_segments
group by cost_range
order by Total_product DESC;

/*
Group customers into three segments based on their spending behavior:

- VIP: at least 12 months of history and spending more than €5,000.
- Regular: at least 12 months of history but spending €5,000 or less.
- New: lifespan less than 12 months.

And find the total number of customers by each group.

group so now here we have a lot of

*/

With Customer_spending as (
Select 
	C.Customer_key,
	Sum(F.sales_amount) as  Total_Spending,
	MIN(F.order_date) as   First_date ,
	MAX(F.order_date) as   Last_date ,
	DateDiff(MONTH , MIN(F.order_date) ,MAX(F.order_date)  ) as Lifespan
from gold.fact_sales F
LEFT JOIN gold.dim_customers C ON C.Customer_key = F.Customer_key
Group by C.Customer_key )

Select
	customer_segment,
	COUNT(Customer_key) AS Tolal_customer
	From 
(Select 
		Customer_key, 

		case
			when  Lifespan >= 12 and Total_Spending >5000 Then 'VIP'
			when  Lifespan >= 12 and Total_Spending <= 5000 Then 'Regular'
			else 'New'
		end as customer_segment
from Customer_spending) t
group by customer_segment
