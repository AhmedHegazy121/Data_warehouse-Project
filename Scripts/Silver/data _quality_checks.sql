-- Check for Nulls or Duplicates in the Primary Key of Crm_Cust_info
-- Expectation: No Results (Each cst_id should be unique and non-null)
SELECT cst_id, COUNT(*)
FROM bronze.Crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for Unwanted Spaces in First Name
-- Expectation: No Results (Names should not have leading or trailing spaces)
SELECT cst_firstname
FROM bronze.Crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

-- Check for Data Standardization & Consistency in Gender
SELECT DISTINCT cst_gndr FROM bronze.Crm_cust_info;

-- Check for Data Standardization & Consistency in Marital Status
SELECT DISTINCT cst_material_status FROM bronze.Crm_cust_info;

-- Check for Nulls or Duplicates in the Primary Key of Crm_prd_info
SELECT prd_id, COUNT(*)
FROM bronze.Crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for Unwanted Spaces in Product Name
SELECT prd_nm
FROM bronze.Crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check for Nulls or Negative Product Costs
SELECT prd_cost 
FROM bronze.Crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Check for Data Standardization & Consistency in Product Line
SELECT DISTINCT prd_line FROM bronze.Crm_prd_info;

-- Check for Invalid Date Orders in Product Info
-- End date should not be earlier than the start date
SELECT * FROM bronze.Crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- Validate End Date Calculation using LEAD Function
SELECT *, LEAD(Prd_start_dt) OVER (PARTITION BY prd_key ORDER BY Prd_start_dt) -1 AS prd_end_dt_test
FROM bronze.Crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509-R', 'AC-HE-HL-U509');

-- Check for Unwanted Spaces in Sales Details
SELECT sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price
FROM ERP_CRM_DW.bronze.Crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num);

-- Validate Product Key Relationship with Crm_prd_info
SELECT *
FROM ERP_CRM_DW.bronze.Crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.Crm_prd_info);

-- Validate Customer ID Relationship with Crm_cust_info
SELECT *
FROM ERP_CRM_DW.bronze.Crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.Crm_cust_info);

-- Check for Invalid Shipping Dates (Negative or zero values, incorrect format, out-of-range dates)
SELECT NULLIF(sls_ship_dt, 0) AS sls_ship_dt
FROM bronze.Crm_sales_details
WHERE sls_ship_dt <= 0 OR LEN(sls_ship_dt) != 8 OR sls_ship_dt > 20500101 OR sls_ship_dt < 19000101;

-- Check for Invalid Order Dates
SELECT NULLIF(sls_order_dt, 0) AS sls_order_dt
FROM bronze.Crm_sales_details
WHERE sls_order_dt <= 0 OR LEN(sls_order_dt) != 8 OR sls_order_dt > 20500101 OR sls_order_dt < 19000101;

-- Check for Invalid Due Dates
SELECT NULLIF(sls_due_dt, 0) AS sls_due_dt
FROM bronze.Crm_sales_details
WHERE sls_due_dt <= 0 OR LEN(sls_due_dt) != 8 OR sls_due_dt > 20500101 OR sls_due_dt < 19000101;

-- Check for Invalid Date Orders (Order date should be before shipping and due date)
SELECT *
FROM bronze.Crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;

-- Validate Data Consistency: Sales = Quantity * Price, No Nulls or Negative Values
SELECT DISTINCT 
    sls_sales AS old_sales,
    sls_quantity,
    sls_price AS old_price,
    CASE 
        WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
        THEN sls_price * sls_quantity 
        ELSE sls_sales 
    END AS sls_sales,
    CASE 
        WHEN sls_price IS NULL OR sls_price <= 0
        THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price 
    END AS sls_price
FROM bronze.Crm_sales_details
WHERE sls_sales != sls_price * sls_quantity
    OR sls_quantity IS NULL OR sls_sales IS NULL OR sls_price IS NULL
    OR sls_quantity <= 0 OR sls_sales <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

-- Check for Customer ID Standardization in Erp_cust_az12
SELECT CID,
    CASE 
        WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID, 4, LEN(CID))
        ELSE CID
    END AS CID_CLEANED,
    BDATE,
    GEN
FROM bronze.Erp_cust_az12
WHERE CASE 
        WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID, 4, LEN(CID))
        ELSE CID
    END NOT IN (SELECT DISTINCT cst_key FROM silver.Crm_cust_info);

-- Identify Out-of-Range Birth Dates
SELECT BDATE
FROM bronze.Erp_cust_az12
WHERE BDATE < '1924-01-01' OR BDATE > GETDATE();

-- Standardize Gender Data
SELECT DISTINCT GEN,
    CASE 
        WHEN UPPER(GEN) IN ('F', 'FEMALE') THEN 'Female'
        WHEN UPPER(GEN) IN ('M', 'MALE') THEN 'Male'
        ELSE 'n/a'
    END AS STANDARD_GEN
FROM bronze.Erp_cust_az12;

-- Normalize and Handle Missing or Blank Country Codes
SELECT DISTINCT CNTRY,
    CASE 
        WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
        WHEN TRIM(CNTRY) IN ('US', 'USA') THEN 'United States'
        WHEN TRIM(CNTRY) = '' OR CNTRY IS NULL THEN 'n/a'
        ELSE CNTRY
    END AS STANDARD_CNTRY
FROM bronze.Erp_loc_a101;

-- Check for Unwanted Spaces in Categories
SELECT * FROM bronze.Erp_px_cat_g1v2 WHERE cat != TRIM(cat);
SELECT * FROM bronze.Erp_px_cat_g1v2 WHERE SUBCAT != TRIM(SUBCAT);
SELECT * FROM bronze.Erp_px_cat_g1v2 WHERE MAINTENANCE != TRIM(MAINTENANCE);

-- Check for Data Standardization in Categories
SELECT DISTINCT cat FROM bronze.Erp_px_cat_g1v2;
SELECT DISTINCT SUBCAT FROM bronze.Erp_px_cat_g1v2;
SELECT DISTINCT MAINTENANCE FROM bronze.Erp_px_cat_g1v2;
