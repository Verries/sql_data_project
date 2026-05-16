Create or Alter Procedure bronze.load_bronze as 
Begin
	DECLARE @start_time DATETIME;
	DECLARE @end_time DATETIME;
	DECLARE @batch_start_time DATETIME;
	DECLARE @batch_end_time DATETIME;
	Begin TRY
		SET @batch_start_time = GETDATE();
		print '========================================================='
		Print'Loading Bronze Layer'
		print '========================================================='

		print '---------------------------------------------------------'
		Print 'Loading ERP Tables'
		print '---------------------------------------------------------'
	
	set @start_time = GETDATE();
	Print'>> Truncating Table: bronze.erp_cust_az12';
	Truncate Table bronze.erp_cust_az12;

	Print '>> Inserting Data Into: bronze.erp_cust_az12';
	Bulk Insert bronze.erp_cust_az12
	from 'C:\Users\Vernon_30\Desktop\Data Engineering\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
	with (
		firstrow = 2,
		fieldterminator = ',',
		tablock
	);
	set @end_time = GETDATE();
	PRINT '>> LOAD DURATION:' + CAST(DATEDIFF(second,@start_time,@end_time) as NVARCHAR) + ' seconds'
	PRINT '-------------'

	set @start_time = GETDATE();
	Print'>> Truncating Table: bronze.erp_erp_LOC_A101';
	Truncate Table bronze.erp_LOC_A101;

	Print '>> Inserting Data Into: bronze.erp_LOC_A101';
	Bulk Insert bronze.erp_LOC_A101
	from 'C:\Users\Vernon_30\Desktop\Data Engineering\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
	with (
		firstrow = 2,
		fieldterminator = ',',
		tablock
	);
	set @end_time = GETDATE();
	PRINT '>> LOAD DURATION:' + CAST(DATEDIFF(second,@start_time,@end_time) as NVARCHAR) + ' seconds'
	PRINT '-------------'


	set @start_time = GETDATE();
	Print'>> Truncating Table: bronze.erp_PX_CAT_G1V2';
	Truncate Table bronze.erp_PX_CAT_G1V2;

	Print '>> Inserting Data Into: bronze.erp_PX_CAT_G1V2';
	Bulk Insert bronze.erp_PX_CAT_G1V2
	from 'C:\Users\Vernon_30\Desktop\Data Engineering\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
	with (
		firstrow = 2,
		fieldterminator = ',',
		tablock
	);
	set @end_time = GETDATE();
	PRINT '>> LOAD DURATION:' + CAST(DATEDIFF(second,@start_time,@end_time) as NVARCHAR) + ' seconds'
	PRINT '-------------'


		print '---------------------------------------------------------'
		Print 'Loading CRM Tables'
		print '---------------------------------------------------------'

	set @start_time = GETDATE();
	Print'>> Truncating Table: bronze.crm_cust_info';
	Truncate Table bronze.crm_cust_info;

	Print '>> Inserting Data Into: bronze.crm_cust_info';
	Bulk Insert bronze.crm_cust_info
	from 'C:\Users\Vernon_30\Desktop\Data Engineering\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
	with (
		firstrow = 2,
		fieldterminator = ',',
		tablock
	);
	set @end_time = GETDATE();
	PRINT '>> LOAD DURATION:' + CAST(DATEDIFF(second,@start_time,@end_time) as NVARCHAR) + ' seconds'
	PRINT '-------------'


	set @start_time = GETDATE();
	Print'>> Truncating Table: bronze.crm_prd_info';
	Truncate Table bronze.crm_prd_info;

	Print '>> Inserting Data Into: bronze.crm_prd_info';
	Bulk Insert bronze.crm_prd_info
	from 'C:\Users\Vernon_30\Desktop\Data Engineering\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
	with (
		firstrow = 2,
		fieldterminator = ',',
		tablock
	);
	set @end_time = GETDATE();
	PRINT '>> LOAD DURATION:' + CAST(DATEDIFF(second,@start_time,@end_time) as NVARCHAR) + ' seconds'
	PRINT '-------------'


	set @start_time = GETDATE();
	Print'>> Truncating Table: bronze.crm_sales_details';	
	Truncate Table bronze.crm_sales_details;

	Print '>> Inserting Data Into: bronze.crm_sales_details';
	Bulk Insert bronze.crm_sales_details
	from 'C:\Users\Vernon_30\Desktop\Data Engineering\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
	with (
		firstrow = 2,
		fieldterminator = ',',
		tablock
	);
	set @end_time = GETDATE();
	PRINT '>> LOAD DURATION:' + CAST(DATEDIFF(second,@start_time,@end_time) as NVARCHAR) + ' seconds'
	PRINT '-------------'

	SET @batch_end_time = GETDATE();
	PRINT '-------------'
		PRINT '>> Loading Bronze Layer is Completed';
		print 'Total Duration:' +cast(DATEDIFF(second,@batch_start_time,@batch_end_time) as NVARCHAR) + 'seconds';
	PRINT '-------------'
END try
Begin Catch
	Print'==================================='
	Print'ERROR OCCURED DURING LOADING BRONZE LAYER'
	Print'ERROR MESSAGE:' + ERROR_MESSAGE();
	Print'ERROR MESSAGE:' + CAST(ERROR_MESSAGE() as NVARCHAR);
	Print'ERROR MESSAGE:' + CAST(ERROR_STATE() as NVARCHAR);
	Print'==================================='
End Catch

END
