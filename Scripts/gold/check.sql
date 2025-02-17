
Select 
cst_id , COUNT(*)
from (
SELECT 
      ci.cst_id,
      ci.cst_key,
      ci.cst_firstname,
      ci.cst_lastname,
      ci.cst_material_status,
      ci.cst_gndr,
      ci.cts_create_date,
      ci.dwh_create_date,
	  ca.BDATE,
	  ca.GEN,
	  la.CNTRY
FROM ERP_CRM_DW.silver.Crm_cust_info ci
LEFT JOIN  silver.Erp_cust_az12 ca
on ci.cst_key = ca.CID
LEFT JOIN silver.Erp_loc_a101 la
on    ci.cst_key = la.CID)q
Group by cst_id
having  COUNT(*) > 1


-- Data integration
SELECt
      ci.cst_gndr,
	  ca.GEN,
	  Case when Ci.cst_gndr != 'n/a' then ci.cst_gndr -- CRM is the master For Gentder info 
	  ELSE COALESCE (ca.GEN, 'n/a')
	  END AS new_gen 

FROM ERP_CRM_DW.silver.Crm_cust_info ci
LEFT JOIN  silver.Erp_cust_az12 ca
on ci.cst_key = ca.CID
LEFT JOIN silver.Erp_loc_a101 la
on    ci.cst_key = la.CID
order by 1, 2;




select 
prd_key , COUNT(*)
from
(SELECT pn.prd_id, 
      pn.cat_id, 
      pn.prd_key, 
      pn.prd_nm, 
      pn.prd_cost, 
      pn.prd_line, 
      pn.prd_start_dt,
	  pc.CAT,
	  pc.SUBCAT,
	  pc.MAINTENANCE
FROM ERP_CRM_DW.silver.Crm_prd_info pn
LEFT JOIN silver.Erp_px_cat_g1v2 pc
on pn.cat_id = pc.ID
where prd_end_dt IS NULL)t -- Filter out all historical data
group by prd_key
Having COUNT(*)> 1


--- foreign key integrity (Deminsions)
Select *
   FROM [ERP_CRM_DW].[gold].[fact_sales] f
 Left Join [ERP_CRM_DW].[gold].[dim_customers] c
on f.customer_key = c.customer_key
 Left Join [ERP_CRM_DW].[gold].[dim_products] p
 on p.product_key = f.product_key
where p.product_key is null  and c.Customer_key is null



