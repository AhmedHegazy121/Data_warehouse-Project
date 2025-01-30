/*

								Create Database and Schemas
								----------------------------
Script Purpose:
This script creates a new database named 'ERP_CRM_DW ' after checking if it already exists.
If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas
within the database: 'bronze', 'silver', and 'gold'.

WARNING:

Running this script will drop the entire 'DataWarehouse' database if it exists.
All data in the database will be permanently deleted. Proceed with caution
and ensure you have proper backups before running this script.

*/





-- Create Database 'DataWarehouse

USE master; 
GO

-- Drop and Recreate the 'DataWarehouse' database

IF Exists (Select 1 From sys.databases where name= 'ERP_CRM_DW')
	Begin
		Alter database  ERP_CRM_DW  set single_user with RollBack Immdiate;
		Drop  database ERP_CRM_DW ;
	end;
GO
-- Create the ERP_CRM_DW  database

CREATE DATABASE ERP_CRM_DW ;
GO

USE ERP_CRM_DW ;
GO
-- Create Schemas

Create Schema bronze;
GO

Create Schema silver;
GO

Create Schema gold ;
GO
