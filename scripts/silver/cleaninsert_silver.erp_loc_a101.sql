INSERT INTO silver.erp_loc_a101 (cid, cntry)
SELECT
	--Match data to cust_info table removing hyphen in ID--
	REPLACE(cid, '-', '') cid,
	--Normalize country values where inconsistent--
	CASE 
		 WHEN TRIM(cntry) = 'DE' THEN 'Germany'
		 WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
		 WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'N/A'
		 ELSE TRIM(cntry)
	END cntry
FROM bronze.erp_loc_a101
