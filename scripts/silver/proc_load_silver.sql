Create OR ALTER Procedure  silver.load_silver AS
Begin
    DECLARE @start_time DATETIME;
	DECLARE @end_time DATETIME;
	DECLARE @batch_start_time DATETIME;
	DECLARE @batch_end_time DATETIME;
        
        Begin TRY
        SET @batch_start_time = GETDATE();
		print '========================================================='
		Print'Loading Silver Layer'
		print '========================================================='
    
    set @start_time = GETDATE();
    PRINT '>> Truncating Data Into: silver.crm_cust_info';
    Truncate table silver.crm_cust_info

    -- silver.crm_cust_info table
    PRINT '>> Inserting Data Into: silver.crm_cust_info';
    -------------------------------------------------------------------------------------
    Insert Into silver.crm_cust_info(
           [cst_id]
          ,[cst_key]
          ,[cst_firstname]
          ,[cst_lastname]
          ,[cst_marital_status]
          ,[cst_gndr]
          ,[cst_create_date])
    Select 
    cst_id,
    cst_key,
    TRIM(cst_firstname) as cst_firstname,
    TRIM(cst_lastname) as cst_lastname,

    case when UPPER(TRIM(cst_marital_status)) = 'S' then 'Single'
     when UPPER(TRIM(cst_marital_status)) = 'M' then 'Married'
     else 'n/a'
     END cst_marital_status,

    case when UPPER(TRIM(cst_gndr)) = 'F' then 'Female'
     when UPPER(TRIM(cst_gndr)) = 'M' then 'Male'
     else 'n/a'
     END cst_gndr,

     cst_create_date

    from(
    Select *,
    ROW_NUMBER() over (partition by cst_id order by cst_create_date desc) as flag_last
    from bronze.crm_cust_info
    where cst_id is not null) t
    where flag_last = 1 

    set @end_time = GETDATE();
	PRINT '>> LOAD DURATION:' + CAST(DATEDIFF(second,@start_time,@end_time) as NVARCHAR) + ' seconds'
	PRINT '-------------'
    ------------------------------------------------------------------------------------
    -- silver.crm_prd_info table

    set @start_time = GETDATE();
    PRINT '>> Truncating Data Into: silver.crm_prd_info';
    Truncate table silver.crm_prd_info
    PRINT '>> Inserting Data Into: silver.crm_prd_info';

    Insert INTO silver.crm_prd_info(
    [prd_id]
          ,[cat_id]
          ,[prd_key]
          ,[prd_nm]
          ,[prd_cost]
          ,[prd_line]
          ,[prd_start_dt]
          ,[prd_end_dt]
          )

    SELECT [prd_id]
          ,Replace(SUBSTRING(prd_key, 1, 5), '-', '_') as cat_id,
          SUBSTRING(prd_key,7, len(prd_key)) as prd_key

          ,[prd_nm]

          ,ISNULL([prd_cost],0) as prd_cost

          ,case when UPPER(TRIM([prd_line])) = 'M' then 'Mountain'
                when UPPER(TRIM([prd_line])) = 'R' then 'Road'
                when UPPER(TRIM([prd_line])) = 'S' then 'other sales'
                when UPPER(TRIM([prd_line])) = 'T' then 'Touring'
           else 'n/a'
           END as prd_line

          ,CAST([prd_start_dt] AS DATE) as prd_start_dt
          ,CAST(Lead(prd_start_dt) over (partition by prd_key order by prd_start_dt) -1 as date)as prd_end_dt
      FROM [DataWarehouse].[bronze].[crm_prd_info]

    set @end_time = GETDATE();
	PRINT '>> LOAD DURATION:' + CAST(DATEDIFF(second,@start_time,@end_time) as NVARCHAR) + ' seconds'
	PRINT '-------------'

      -----------------------------------------------------------------------------------------------------------
      --- silver.crm_sales_details table

      set @start_time = GETDATE();
      PRINT '>> Truncating Data Into: silver.crm_sales_details';
      Truncate table silver.crm_sales_details

      PRINT '>> Inserting Data Into: silver.crm_sales_details';
      INSERT INTO silver.crm_sales_details(
           [sls_ord_num]
          ,[sls_prd_key]
          ,[sls_cust_id]
          ,[sls_order_dt]
          ,[sls_ship_dt]
          ,[sls_due_dt]
          ,[sls_sales]
          ,[sls_quantity]
          ,[sls_price]
          )
    SELECT [sls_ord_num]
          ,[sls_prd_key]
          ,[sls_cust_id]
      
            ,Case when sls_order_dt = 0 or LEN(sls_order_dt) != 8 then NULL
                else CAST(CAST(sls_order_dt as VARCHAR) as DATE)
            END as sls_order_dt
      
          ,Case when sls_order_dt = 0 or LEN(sls_ship_dt) != 8 then NULL
                else CAST(CAST(sls_ship_dt as VARCHAR) as DATE)
            END as sls_ship_dt
      
          ,Case when sls_order_dt = 0 or LEN(sls_due_dt) != 8 then NULL
                else CAST(CAST(sls_due_dt as VARCHAR) as DATE)
            END as sls_ship_dt

         ,CASE 
        WHEN sls_sales IS NULL 
          OR sls_sales <= 0 
          OR sls_sales != sls_quantity * ABS(sls_price) 
        THEN sls_quantity * ABS(sls_price) 
        ELSE sls_sales 

    END AS sls_sales
          ,[sls_quantity]
          ,Case when sls_price is null or sls_price <=0
            then sls_sales / NULLIF(sls_quantity,0)
                else sls_price
            END as sls_price
      FROM [DataWarehouse].[bronze].[crm_sales_details]

    set @end_time = GETDATE();
	PRINT '>> LOAD DURATION:' + CAST(DATEDIFF(second,@start_time,@end_time) as NVARCHAR) + ' seconds'
	PRINT '-------------'
      --------------------------------------------------------------------------------------
      -- silver.erp_cust_az12 table

      set @start_time = GETDATE();
      PRINT '>> Truncating Data Into: silver.erp_cust_az12';
      Truncate table silver.erp_cust_az12

      PRINT '>> Inserting Data Into: silver.erp_cust_az12';
      Insert Into silver.erp_cust_az12(
		    [CID]
          ,[BDATE]
          ,[GEN]
	      )
    Select 
    case when cid like 'NAS%' then SUBSTRING(cid,4, LEN(cid))
	    else cid
	    END as cid,
    case when bdate > getdate() then null
    else bdate
    end as bdate,
    case when UPPER(trim(gen)) in ('F', 'FEMALE') then 'Female'
     when UPPER(trim(gen)) in ('M', 'MALE') then 'Male'
    else 'n/a'
    end as gen
    from bronze.erp_cust_az12

    set @end_time = GETDATE();
	PRINT '>> LOAD DURATION:' + CAST(DATEDIFF(second,@start_time,@end_time) as NVARCHAR) + ' seconds'
	PRINT '-------------'
    ------------------------------------------------------------------------
    -- silver.erp_loc_a101

    set @start_time = GETDATE();
      PRINT '>> Truncating Data Into: silver.erp_loc_a101';
      Truncate table silver.erp_loc_a101

    PRINT '>> Inserting Data Into: silver.erp_loc_a101';
    Insert Into silver.erp_loc_a101(
    cid,
    cntry
    )
    SELECT  
    Replace (cid, '-', '')cid,
     Case when TRIM(cntry) = 'DE' then 'Germany'
	    when TRIM(cntry) in ('US','USA') then 'United States'
	    when TRIM(cntry) = '' then 'n/a'
	    else TRIm(cntry)
	    end as cntry
      FROM [DataWarehouse].[bronze].[erp_LOC_A101]

    set @end_time = GETDATE();
	PRINT '>> LOAD DURATION:' + CAST(DATEDIFF(second,@start_time,@end_time) as NVARCHAR) + ' seconds'
	PRINT '-------------'
      ----------------------------------------------------------------------
      -- silver.erp_PX_CAT_G1V2

      set @start_time = GETDATE();
       PRINT '>> Truncating Data Into: silver.erp_PX_CAT_G1V2';
      Truncate table silver.erp_PX_CAT_G1V2

      PRINT '>> Inserting Data Into: silver.erp_PX_CAT_G1V2';
      Insert into silver.erp_PX_CAT_G1V2(
           [id]
          ,[cat]
          ,[subcat]
          ,[maintenance])

    SELECT  [id]
          ,[cat]
          ,[subcat]
          ,[maintenance]
      FROM [DataWarehouse].[bronze].[erp_PX_CAT_G1V2]

    set @end_time = GETDATE();
	PRINT '>> LOAD DURATION:' + CAST(DATEDIFF(second,@start_time,@end_time) as NVARCHAR) + ' seconds'
	PRINT '-------------'

    SET @batch_end_time = GETDATE();
	PRINT '-------------'
		PRINT '>> Loading silver Layer is Completed';
		print 'Total Duration:' +cast(DATEDIFF(second,@batch_start_time,@batch_end_time) as NVARCHAR) + ' seconds';
	PRINT '--------------------------------------------------------------------------------------------------------'
END try
Begin Catch
	Print'==================================='
	Print'ERROR OCCURED DURING LOADING SILVER LAYER'
	Print'ERROR MESSAGE:' + ERROR_MESSAGE();
	Print'ERROR MESSAGE:' + CAST(ERROR_MESSAGE() as NVARCHAR);
	Print'ERROR MESSAGE:' + CAST(ERROR_STATE() as NVARCHAR);
	Print'==================================='
End Catch
      -------------------------------------------------------------------------
END
