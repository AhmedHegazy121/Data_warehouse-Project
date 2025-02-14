/*
======================================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
======================================================================================]
Script Purpose:
	This stored procedure performs the ETL (Extract, Transform, Load) process to
	populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
	- Truncates Silver tables.
	- Inserts transformed and cleansed data from Bronze into Silver tables.

Parameters:

	None.
	This stored procedure does not accept any parameters or return any values.

Usage Example:
EXEC Silver.load_silver;
======================================================================================
*/







CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time datetime , @end_time datetime ,  @batch_start_time Datetime , @batch_end_time Datetime ;

		-- Clean bronze.Crm_cust_infoTable and insert it into Silver layer
	begin try 
	set @batch_start_time = GETDATE();
		Print'======================================================================================';
		Print 'Loading Silver Layer';
		Print'======================================================================================';

		Print '-------------------------------------------------------------------------------------';
		Print 'Loading CRM Tables';
		Print '-------------------------------------------------------------------------------------';

		Set @start_time = GetDate();
			PRINT '>> Truncating Table: silver.Crm_cust_info';
			TRUNCATE TABLE silver.Crm_cust_info;

			PRINT '>> Inserting Data Into: silver.Crm_cust_info';
			INSERT INTO silver.Crm_cust_info (
				cst_id,
				cst_key,
				cst_firstname,
				cst_lastname,
				cst_material_status,
				cst_gndr,
				cts_create_date
			)
			SELECT 
				cst_id,
				cst_key,
				TRIM(cst_firstname) AS cst_firstname,
				TRIM(cst_lastname) AS cst_lastname,
				CASE
					WHEN UPPER(TRIM(cst_material_status)) = 'S' THEN 'Single'
					WHEN UPPER(TRIM(cst_material_status)) = 'M' THEN 'Married'
					ELSE 'n/a'
				END AS cst_material_status, -- Normalize marital status values

				CASE
					WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
					WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
					ELSE 'n/a'
				END AS cst_gndr, -- Normalize gender values
				cts_create_date
			FROM (
				SELECT 
					*,
					ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cts_create_date DESC) AS Flag_last
				FROM bronze.Crm_cust_info
			) t
			WHERE Flag_last = 1; -- Select the most recent record per customer
		set @end_time = GETDATE();
		print'Load Durtion : ' + cast(DateDiff(SECOND , @start_time , @end_time)as nvarchar ) + 'Second'
		print '-------------------------------------------------------------------------------------------------------------------------------------------------------------------'

		






			-- Clean bronze.Crm_prd_info Table and insert it into Silver layer
		Set @start_time = GetDate();
			PRINT '>> Truncating Table: silver.crm_prd_info';
			TRUNCATE TABLE silver.crm_prd_info;

			PRINT '>> Inserting Data Into: silver.crm_prd_info';
			INSERT INTO silver.crm_prd_info (
				prd_id,
				cat_id,
				prd_key,
				prd_nm,
				prd_cost,
				prd_line,
				prd_start_dt,
				prd_end_dt
			)
			SELECT 
				prd_id,
				REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, -- Generate cat_id from prd_key
				SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key, -- Extract prd_key from original prd_key
				prd_nm,
				ISNULL(prd_cost, 0) AS prd_cost, -- Handle null values in prd_cost
				CASE UPPER(prd_line) -- Transform prd_line values
					WHEN 'M' THEN 'mountain'
					WHEN 'R' THEN 'road'
					WHEN 'S' THEN 'other sales'
					WHEN 'T' THEN 'touring'
					ELSE 'n/a'
				END AS prd_line,
				CAST(prd_start_dt AS DATE) AS prd_start_dt, -- Cast to date
				CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS DATE) AS prd_end_dt -- Calculate prd_end_dt
			FROM erp_crm_dw.bronze.crm_prd_info;
		set @end_time = GETDATE();
		print'Load Durtion : ' + cast(DateDiff(SECOND , @start_time , @end_time)as nvarchar ) + 'Second'
		print '-------------------------------------------------------------------------------------------------------------------------------------------------------------------'




		Set @start_time = GetDate();
			-- Clean bronze.Crm_sales_details Table and insert it into Silver layer
			PRINT '>> Truncating Table: silver.Crm_sales_details';
			TRUNCATE TABLE silver.Crm_sales_details;

			PRINT '>> Inserting Data Into: silver.Crm_sales_details';
			INSERT INTO silver.Crm_sales_details (
				sls_ord_num,
				sls_prd_key,
				sls_cust_id,
				sls_order_dt,
				sls_ship_dt,
				sls_due_dt,
				sls_sales,
				sls_quantity,
				sls_price
			)
			SELECT 
				sls_ord_num,
				sls_prd_key,
				sls_cust_id,
				-- Handle invalid or zero dates for sls_order_dt
				CASE
					WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
					ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
				END AS sls_order_dt,
				-- Handle invalid or zero dates for sls_ship_dt
				CASE
					WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
					ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
				END AS sls_ship_dt,
				-- Handle invalid or zero dates for sls_due_dt
				CASE
					WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
					ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
				END AS sls_due_dt,
				-- Validate or recalculate sls_sales
				CASE 
					WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
					THEN sls_price * sls_quantity 
					ELSE sls_sales 
				END AS sls_sales,
				sls_quantity,
				-- Validate or recalculate sls_price
				CASE 
					WHEN sls_price IS NULL OR sls_price <= 0
					THEN sls_sales / NULLIF(sls_quantity, 0)
					ELSE sls_price 
				END AS sls_price
			FROM ERP_CRM_DW.bronze.Crm_sales_details;
		set @end_time = GETDATE();
		print'Load Durtion : ' + cast(DateDiff(SECOND , @start_time , @end_time)as nvarchar ) + 'Second'
		print '-------------------------------------------------------------------------------------------------------------------------------------------------------------------'




		Print '-------------------------------------------------------------------------------------';
		Print 'Loading ERP Tables';
		Print '-------------------------------------------------------------------------------------';



		Set @start_time = GetDate();
			-- Clean bronze.Erp_cust_az12 Table and insert it into Silver layer
			PRINT '>> Truncating Table: silver.Erp_cust_az12';
			TRUNCATE TABLE silver.Erp_cust_az12;

			PRINT '>> Inserting Data Into: silver.Erp_cust_az12';
			INSERT INTO silver.Erp_cust_az12 (
				CID,
				BDATE,
				GEN
			)
			SELECT 
				-- Extracting numeric part of CID if it starts with 'NAS', otherwise keeping it as is
				CASE 
					WHEN cid LIKE 'nas%' THEN SUBSTRING(cid, 4, LEN(cid))
					ELSE cid
				END AS cid, 
				-- Setting bdate to null if it is in the future
				CASE 
					WHEN bdate > GETDATE() THEN NULL
					ELSE bdate
				END AS bdate, 
				-- Standardizing gender values
				CASE 
					WHEN UPPER(gen) IN ('F', 'FEMALE') THEN 'femal'
					WHEN UPPER(gen) IN ('M', 'MALE') THEN 'male'
					ELSE 'n/a'
				END AS gen
			FROM bronze.erp_cust_az12;
		set @end_time = GETDATE();
		print'Load Durtion : ' + cast(DateDiff(SECOND , @start_time , @end_time)as nvarchar ) + 'Second'
		print '-------------------------------------------------------------------------------------------------------------------------------------------------------------------'




		Set @start_time = GetDate();
			-- Clean bronze.Erp_loc_a101 Table and insert it into Silver layer
			PRINT '>> Truncating Table: silver.Erp_loc_a101';
			TRUNCATE TABLE silver.Erp_loc_a101;

			PRINT '>> Inserting Data Into: silver.Erp_loc_a101';
			INSERT INTO silver.Erp_loc_a101 (
				CID,
				CNTRY
			)
			SELECT 
				REPLACE(CID, '-', '') AS CID,
				CASE 
					WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
					WHEN TRIM(CNTRY) IN ('US', 'USA') THEN 'United States'
					WHEN TRIM(CNTRY) = '' OR CNTRY IS NULL THEN 'n/a'
					ELSE CNTRY
				END AS CNTRY
			FROM bronze.Erp_loc_a101;
		set @end_time = GETDATE();
		print'Load Durtion : ' + cast(DateDiff(SECOND , @start_time , @end_time)as nvarchar ) + 'Second'
		print '-------------------------------------------------------------------------------------------------------------------------------------------------------------------'




		Set @start_time = GetDate();
			-- Clean bronze.Erp_px_cat_g1v2 Table and insert it into Silver layer
			PRINT '>> Truncating Table: silver.Erp_px_cat_g1v2';
			TRUNCATE TABLE silver.Erp_px_cat_g1v2;

			PRINT '>> Inserting Data Into: silver.Erp_px_cat_g1v2';
			INSERT INTO silver.Erp_px_cat_g1v2 (
				ID,
				CAT,
				SUBCAT,
				MAINTENANCE
			)
			SELECT 
				ID, 
				CAT, 
				SUBCAT, 
				MAINTENANCE
			FROM ERP_CRM_DW.bronze.Erp_px_cat_g1v2;
		set @end_time = GETDATE();
		print'Load Durtion : ' + cast(DateDiff(SECOND , @start_time , @end_time)as nvarchar ) + 'Second'
		print '-------------------------------------------------------------------------------------------------------------------------------------------------------------------'



		Set @batch_end_time = GETDATE();

		print '================================';
		Print'Loading  Silver Layer is Completed';
		print 'Total Load Duration: ' + Cast (DateDiff (Second , @batch_start_time ,@batch_end_time  )as nvarchar) + 'second'
		print '================================';

	end try
	Begin Catch
	Print'-------------------------------------------------------------------'
		print 'Error Occured During Loading Silver Layer';
		print 'Error Message'+ Error_message();
		print 'Error Message'+Cast(Error_number()as nvarchar);
		print 'Error Message'+ Cast (Error_state()as nvarchar);
	Print'-------------------------------------------------------------------'
	End Catch

END
