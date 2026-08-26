INSERT INTO silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
SELECT
	--ID is already matching from work done in silver prd_info table--
	id,
	cat,
	subcat,
	maintenance
FROM bronze.erp_px_cat_g1v2
