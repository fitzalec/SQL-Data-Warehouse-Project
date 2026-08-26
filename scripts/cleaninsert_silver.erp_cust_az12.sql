INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)

SELECT
	--Remove 'NAS' prefix from historical records when present for consistency--
	CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
		 ELSE cid
	END cid,
	--Set any birthdates not applicable (in future) to NULL--
	CASE WHEN bdate > GETDATE() THEN NULL
		 ELSE bdate
	END bdate,
	--Normalize gender values to handle unknown cases--
	CASE WHEN UPPER(TRIM(gen)) IN ('F', 'Female') THEN 'Female'
		 WHEN UPPER(TRIM(gen)) IN ('M', 'Male') THEN 'Male'
		 ELSE 'N/A'
	END gen
FROM bronze.erp_cust_az12
