/*
==================================================================
DDL Script: Create Silver Tables
==================================================================
Script Purpose:
This script creates tables in the 'silver' schema, dropping existing tables
if they already exist.
Run this script to re-define the DDL structure of 'bronze' Tables
==================================================================
*/


if OBJECT_ID ('silver.Crm_cust_info','U') is not null
		Drop Table silver.Crm_cust_info;
Create Table silver.Crm_cust_info(
		cst_id int ,
		cst_key nvarchar(50),
		cst_firstname nvarchar(50),
		cst_lastname nvarchar(50),
		cst_material_status nvarchar(50),
		cst_gndr nvarchar(50),
		cts_create_date date,
		dwh_create_date Datetime2 Default Getdate()
);

if OBJECT_ID ('silver.Crm_prd_info','U') is not null
		Drop Table silver.Crm_prd_info;
Create Table silver.Crm_prd_info (
		prd_id int,
		cat_id nvarchar(50),
		prd_key nvarchar(50),
		prd_nm  nvarchar(50),
		prd_cost int,
		prd_line nvarchar(50),
		prd_start_dt date,
		prd_end_dt date,
		dwh_create_date Datetime2 Default Getdate()
);

if OBJECT_ID ('silver.Crm_sales_details','U') is not null
		Drop Table silver.Crm_sales_details;
Create table silver.Crm_sales_details (
		sls_ord_num nvarchar(50),
		sls_prd_key nvarchar(50),
		sls_cust_id int,
		sls_order_dt date,
		sls_ship_dt date,
		sls_due_dt  date,
		sls_sales int,
		sls_quantity int,
		sls_price int,
		dwh_create_date Datetime2 Default Getdate()
) ;

if OBJECT_ID ('silver.Erp_cust_az12','U') is not null
		Drop Table silver.Erp_cust_az12;
Create Table silver.Erp_cust_az12 (
		CID nvarchar(50),
		BDATE date ,
		GEN  nvarchar(50),
		dwh_create_date Datetime2 Default Getdate()

);


if OBJECT_ID ('silver.Erp_loc_a101','U') is not null
		Drop Table silver.Erp_loc_a101;
Create table silver.Erp_loc_a101 (
		CID nvarchar(50),
		CNTRY nvarchar(50),
		dwh_create_date Datetime2 Default Getdate()


) ;


if OBJECT_ID ('silver.Erp_px_cat_g1v2','U') is not null
		Drop Table silver.Erp_px_cat_g1v2;
Create Table silver.Erp_px_cat_g1v2 (
		ID nvarchar(50),
		CAT nvarchar(50),
		SUBCAT nvarchar(50),
		MAINTENANCE nvarchar(50),
		dwh_create_date Datetime2 Default Getdate()
);
