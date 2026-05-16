/*
============================================================================
DDL Script: Create Bronze Tables
===========================================================================
Script Purpose:
  This script creates the tables in the bronze schema, dropping existing tables if they already exist
======================================================================================================
*/
IF OBJECT_ID ('bronze.crm_cust_info', 'U') is not null
	Drop table  bronze.crm_cust_info;
Create table bronze.crm_cust_info (
cst_id INT,
cst_key NVARCHAR(50),
cst_firstname NVARCHAR(50),
cst_lastname NVARCHAR(50),
cst_marital_status NVARCHAR(50),
cst_gndr NVARCHAR(50),
cst_create_date DATE
);

IF OBJECT_ID ('bronze.crm_prd_info', 'U') is not null
	Drop table  bronze.crm_prd_info;
Create table bronze.crm_prd_info (
prd_id INT,
prd_key NVARCHAR(50),
prd_nm NVARCHAR(50),
prd_cost Decimal(18,2),
prd_line NVARCHAR(50),
prd_start_dt DATE,
prd_end_dt DATE
);

IF OBJECT_ID ('bronze.crm_sales_details', 'U') is not null
	Drop table  bronze.crm_sales_details;
Create table bronze.crm_sales_details(
sls_ord_num NVARCHAR(50),
sls_prd_key	NVARCHAR(50),
sls_cust_id	INT,
sls_order_dt INT,
sls_ship_dt	INT,
sls_due_dt	INT,
sls_sales	INT,
sls_quantity INT,
sls_price INT,
);


IF OBJECT_ID ('bronze.erp_cust_az12', 'U') is not null
	Drop table  bronze.erp_cust_az12;
	Create table bronze.erp_cust_az12(
CID NVARCHAR (50),
BDATE DATE,
GEN NVARCHAR(50)
);

IF OBJECT_ID ('bronze.LOC_A101', 'U') is not null
	Drop table  bronze.LOC_A101;
Create table bronze.LOC_A101(
CID NVARCHAR (50),
CNTRY NVARCHAR (50)
);

IF OBJECT_ID ('bronze.PX_CAT_G1V2', 'U') is not null
	Drop table  bronze.PX_CAT_G1V2;
Create table bronze.PX_CAT_G1V2(
id NVARCHAR (50),
cat NVARCHAR (50),
subcat NVARCHAR(50),
maintenance NVARCHAR(50)
);
