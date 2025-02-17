/*
==================================================================================================
DDL Script: Create Gold Views
==================================================================================================
Script Purpose:
This script creates views for the Gold layer in the data warehouse.
The Gold layer represents the final dSinsion and fact tables (Star Schema)

Each view performs transformations and combines data from the Silver layer
to produce a clean, enriched, and business-ready dataset.

Usage:
- These views can be queried directly for analytics and reporting.
==================================================================================================
*/
---==================================================================================================
-- Create Dimention: gold.dim_customers
---==================================================================================================

CREATE VIEW gold.dim_customers AS
SELECT 
	 ROW_NUMBER() over (ORDER BY cst_id) AS Customer_key ,
      ci.cst_id AS customer_id,
      ci.cst_key AS customer_number,
      ci.cst_firstname AS first_name,
      ci.cst_lastname AS last_name,
	  la.CNTRY AS country,
      ci.cst_material_status AS marerial_status,
      Case 
			when Ci.cst_gndr != 'n/a' then ci.cst_gndr -- CRM is the master For Gentder info 
			ELSE COALESCE (ca.GEN, 'n/a')
	  END AS gender ,
	  ca.BDATE AS birthdate,
      ci.cts_create_date AS create_date
	  
FROM ERP_CRM_DW.silver.Crm_cust_info ci
LEFT JOIN  silver.Erp_cust_az12 ca
on ci.cst_key = ca.CID
LEFT JOIN silver.Erp_loc_a101 la
on    ci.cst_key = la.CID

---==================================================================================================
-- Create Dimention: gold.dim_products
---==================================================================================================


CREATE VIEW gold.dim_products AS
SELECT 
	  ROW_NUMBER() OVER(order by pn.prd_start_dt , pn.prd_key) AS product_key,
	  pn.prd_id AS product_id, 
	  pn.prd_key AS product_number,
	  pn.prd_nm AS product_name, 
      pn.cat_id AS category_id, 
      pc.CAT AS category,
      pc.SUBCAT AS subcategory,
	  pc.MAINTENANCE AS maintenance,
      pn.prd_cost AS cost, 
      pn.prd_line AS product_line, 
      pn.prd_start_dt as start_date 
FROM ERP_CRM_DW.silver.Crm_prd_info pn
LEFT JOIN silver.Erp_px_cat_g1v2 pc
on pn.cat_id = pc.ID
where prd_end_dt IS NULL -- Filter out all historical data


---==================================================================================================
-- Create Fact: gold.dim_customers : gold.fact_sales
---==================================================================================================


CREATE VIEW gold.fact_sales AS
SELECT 
	  cs.sls_ord_num AS order_number  , 
      pr.product_key, 
      cu.Customer_key, 
      cs.sls_order_dt AS order_date, 
      cs.sls_ship_dt AS shipping_date, 
      cs.sls_due_dt AS due_date, 
      cs.sls_sales AS sales_amount, 
      cs.sls_quantity AS quanity, 
       cs.sls_price AS price
FROM ERP_CRM_DW.silver.Crm_sales_details cs
LEFT JOIN gold.dim_customers cu
on cs.sls_cust_id = cu.customer_id
LEFT JOIN gold.dim_products pr
on cs.sls_prd_key  =  pr.product_number
