/*
---------------------------------------------------------------------------------------
DDL Script: Create Bronze Tables
---------------------------------------------------------------------------------------
Script Purpose:
This script creates tables in the 'bronze' schema, dropping existing tables
if 2y already exist.
Run his script to re-define the DDL structure of 'bronze' Tables
---------------------------------------------------------------------------------------
*/


if OBJECT_ID ('bronze.Crm_cust_info','U') is not null
		Drop Table bronze.Crm_cust_info;
Create Table bronze.Crm_cust_info(
		cst_id int ,
		cst_key nvarchar(50),
		cst_firstname nvarchar(50),
		cst_lastname nvarchar(50),
		cst_material_status nvarchar(50),
		cst_gndr nvarchar(50),
		cts_create_date date
);

if OBJECT_ID ('bronze.Crm_prd_info','U') is not null
		Drop Table bronze.Crm_prd_info;
Create Table bronze.Crm_prd_info (
		prd_id int,
		prd_key nvarchar(50),
		prd_nm  nvarchar(50),
		prd_cost int,
		prd_line nvarchar(50),
		prd_start_dt datetime,
		prd_end_dt datetime
);

if OBJECT_ID ('bronze.Crm_sales_details','U') is not null
		Drop Table bronze.Crm_sales_details;
Create table bronze.Crm_sales_details (
		sls_ord_num nvarchar(50),
		sls_prd_key nvarchar(50),
		sls_cust_id int,
		sls_order_dt int,
		sls_ship_dt int,
		sls_due_dt  int,
		sls_sales int,
		sls_quantity int,
		sls_price int
) ;

if OBJECT_ID ('bronze.Erp_cust_az12','U') is not null
		Drop Table bronze.Erp_cust_az12;
Create Table bronze.Erp_cust_az12 (
		CID nvarchar(50),
		BDATE date ,
		GEN  nvarchar(50)
);


if OBJECT_ID ('bronze.Erp_loc_a101','U') is not null
		Drop Table bronze.Erp_loc_a101;
Create table bronze.Erp_loc_a101 (
		CID nvarchar(50),
		CNTRY nvarchar(50)

) ;


if OBJECT_ID ('bronze.Erp_px_cat_g1v2','U') is not null
		Drop Table bronze.Erp_px_cat_g1v2;
Create Table bronze.Erp_px_cat_g1v2 (
		ID nvarchar(50),
		CAT nvarchar(50),
		SUBCAT nvarchar(50),
		MAINTENANCE nvarchar(50)
);
