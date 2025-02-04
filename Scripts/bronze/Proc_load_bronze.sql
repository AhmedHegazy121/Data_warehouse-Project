/*
------------------------------------------------------------------------------------------------------------------
Stored Procedure: Load Bronze Layer (Source -> Bronze)
------------------------------------------------------------------------------------------------------------------
Script Purpose:
This stored procedure loads data into the 'bronze' schema from external CSV files.
It performs the following actions:
- Truncates the bronze tables before loading data.
- Uses the `BULK INSERT' command to load data from csv Files to bronze tables.

Parameters:
None.
This stored procedure does not accept any parameters or return any values.

Usage Example:
EXEC bronze.load_bronze;
--------------------------------------------------------------------------------------------------------------
*/




Create  or  Alter Procedure bronze.load_bronze AS

Begin
  Declare @start_time Datetime , @end_time DateTime, @batch_start_Time  Datetime , @batch_end_time Datetime;

	Begin Try
	 Set @batch_start_Time = GetDate();

		Print'======================================================================================';
		Print 'Loading Bronze Layer';
		Print'======================================================================================';



		Print '-------------------------------------------------------------------------------------';
		Print 'Loading CRM Tables';
		Print '-------------------------------------------------------------------------------------';

			Set @start_time = GetDate();
			Print'>> Truncating Table :bronze.Crm_cust_info';
		Truncate Table bronze.Crm_cust_info;

		Bulk Insert bronze.Crm_cust_info
		From 'D:\Data Analyst\SQL Query\DW\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		With (
			firstrow = 2,
			FieldTerminator= ',',
			Tablock
		);
			Set @end_time = GETDATE();
			print 'Load Duration : ' + Cast (DateDiff (second ,@start_time , @end_time ) as nvarchar) + 'second'
			Print '---------------------------'


			Set @start_time = GetDate();
			Print'>> Truncating Table :bronze.Crm_prd_info';
		Truncate Table bronze.Crm_prd_info;

		Bulk Insert bronze.Crm_prd_info
		From 'D:\Data Analyst\SQL Query\DW\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		With (
			firstrow = 2,
			FieldTerminator= ',',
			Tablock
		);
			Set @end_time = GETDATE();
			print 'Load Duration : ' + Cast (DateDiff (second ,@start_time , @end_time ) as nvarchar) + 'second'
			Print '---------------------------'




			Set @start_time = GetDate();
			Print'>> Truncating Table :bronze.Crm_sales_details';
		Truncate Table bronze.Crm_sales_details

		Bulk Insert bronze.Crm_sales_details
		From 'D:\Data Analyst\SQL Query\DW\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		With(
			firstrow = 2 ,
			FieldTerminator = ',' ,
			tablock
		);

			Set @end_time = GETDATE();
			print 'Load Duration : ' + Cast (DateDiff (second ,@start_time , @end_time ) as nvarchar) + 'second'
			Print '---------------------------'



		Print '-------------------------------------------------------------------------------------';
		Print 'Loading ERP Tables';
		Print '-------------------------------------------------------------------------------------';


			Set @start_time = GetDate();
			Print'>> Truncating Table :bronze.Erp_loc_a101';
		Truncate Table bronze.Erp_loc_a101

		Bulk Insert bronze.Erp_loc_a101
		From 'D:\Data Analyst\SQL Query\DW\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		With(
			firstrow = 2 ,
			FieldTerminator = ',' ,
			tablock
		);

			Set @end_time = GETDATE();
			print 'Load Duration : ' + Cast (DateDiff (second ,@start_time , @end_time ) as nvarchar) + 'second'
			Print '---------------------------'



			Set @start_time = GetDate();
			Print'>> Truncating Table :bronze.Erp_px_cat_g1v2';
		Truncate Table bronze.Erp_px_cat_g1v2

		Bulk Insert bronze.Erp_px_cat_g1v2
		From 'D:\Data Analyst\SQL Query\DW\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		With(
			firstrow = 2 ,
			FieldTerminator = ',' ,
			tablock
		);

			Set @end_time = GETDATE();
			print 'Load Duration : ' + Cast (DateDiff (second ,@start_time , @end_time ) as nvarchar) + 'second'
			Print '---------------------------'




			Set @start_time = GetDate();
			Print'>> Truncating Table :bronze.Erp_cust_az12';
		Truncate Table bronze.Erp_cust_az12

		Bulk Insert bronze.Erp_cust_az12
		From 'D:\Data Analyst\SQL Query\DW\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
			with(
			firstrow = 2 ,
			FieldTerminator = ',' ,
			tablock
		);
			Set @end_time = GETDATE();
			print 'Load Duration : ' + Cast (DateDiff (second ,@start_time , @end_time ) as nvarchar) + 'second'
			Print '---------------------------';



			Set @batch_end_time = GETDATE();
			print '================================';
			Print 'Loading Broze Layer is Completed';
			Print '- Total Load Duration: ' + Cast(DateDiff(Second,@batch_start_time , @batch_start_time) as nvarchar) + ' second'
			print '================================';

	End try 
	Begin Catch 
		Print'-------------------------------------------------------------------'
			Print 'Error Occured During Loading Bronze Layer'
			Print 'Error Message' + Error_message();
			Print 'Error Message' + Cast (Error_number() as nvarchar);
			Print 'Error Message' + Cast (Error_State() as nvarchar);
		Print'-------------------------------------------------------------------'
	End Catch 
  Set @end_time = GETDATE();
			print 'Load Duration : ' + Cast (DateDiff (second ,@start_time , @end_time ) as nvarchar) + 'second'
			Print '---------------------------'
End;

