INSERT INTO silver.crm_cust_info (
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gndr,
	cst_create_date)

SELECT
	cst_id,
	cst_key,
	--Removing unwanted spaces from names--
	TRIM(cst_firstname) AS cst_firstname,
	TRIM(cst_lastname) AS cst_lastname,
	--Setting new full values for marital status and gender--
	CASE WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
		 WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
		 ELSE 'N/A'
	END cst_marital_status,
	CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
		 WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
		 ELSE 'N/A'
	END cst_gndr,
	cst_create_date
FROM (
		--Removing customers that have NULL keys or duplicates--
		select 
		*, 
		ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
		FROM bronze.crm_cust_info
		WHERE cst_id IS NOT NULL
		)a 
WHERE flag_last = 1 