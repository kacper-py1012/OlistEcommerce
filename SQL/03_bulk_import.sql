USE OlistECommerce;
GO

-- Setting the folder path.
-- NOTE: Set the path to match your local CSV location.
DECLARE @data_path NVARCHAR(500) = 'C:\path\to\Olist\Data\';
DECLARE @sql NVARCHAR(MAX);

-- Inserting data into staging tables.

-- 1. stg_orders
-- NOTE: Standard bulk load using Linux-style line feed (0x0a / LF).
-- The dataset files use LF line endings, so ROWTERMINATOR = '0x0a' is required.
TRUNCATE TABLE dbo.stg_orders;

SET @sql = '
	BULK INSERT dbo.stg_orders
	FROM ''' + @data_path + 'olist_orders_dataset.csv''
	WITH (
		FORMAT = ''CSV'',
		FIRSTROW = 2,
		FIELDTERMINATOR = '','',
		ROWTERMINATOR = ''0x0a'',
		CODEPAGE = ''65001''
	);'
;

	EXEC sp_executesql @sql;			-- Executing bulk insert
	SELECT COUNT(*) AS count_orders FROM dbo.stg_orders;

-- 2. stg_order_items
TRUNCATE TABLE dbo.stg_order_items;

SET @sql = '
	BULK INSERT dbo.stg_order_items
	FROM ''' + @data_path + 'olist_order_items_dataset.csv''
	WITH (
		FORMAT = ''CSV'',
		FIRSTROW = 2,
		FIELDTERMINATOR = '','',
		ROWTERMINATOR = ''0x0a'',
		CODEPAGE = ''65001''
	);'
;
EXEC sp_executesql @sql				-- Executing bulk insert
SELECT COUNT(*) AS count_order_items FROM dbo.stg_order_items;

-- 3. stg_customers
TRUNCATE TABLE dbo.stg_customers;

SET @sql = '
	BULK INSERT dbo.stg_customers
	FROM ''' + @data_path + 'olist_customers_dataset.csv''
	WITH (
		FORMAT = ''CSV'',
		FIRSTROW = 2,
		FIELDTERMINATOR = '','',
		ROWTERMINATOR = ''0x0a'',
		CODEPAGE = ''65001''
	);'
;
EXEC sp_executesql @sql
SELECT COUNT(*) AS count_customers FROM dbo.stg_customers;

-- 4. stg_payments
TRUNCATE TABLE dbo.stg_payments;

SET @sql = '
	BULK INSERT dbo.stg_payments
	FROM ''' + @data_path + 'olist_order_payments_dataset.csv''
	WITH (
		FORMAT = ''CSV'',
		FIRSTROW = 2,
		FIELDTERMINATOR = '','',
		ROWTERMINATOR = ''0x0a'',
		CODEPAGE = ''65001''
	);'
;
EXEC sp_executesql @sql;
SELECT COUNT(*) AS count_payments FROM dbo.stg_payments;

-- 5. stg_reviews
-- NOTE: Requires ROWTERMINATOR = '\n' to properly handle
-- embedded line breaks and quotes within customer review comments
TRUNCATE TABLE dbo.stg_reviews;

SET @sql = '
	BULK INSERT dbo.stg_reviews
	FROM ''' + @data_path + 'olist_order_reviews_dataset.csv''
	WITH (
		FORMAT = ''CSV'',
		FIRSTROW = 2,
		FIELDTERMINATOR = '','',
		ROWTERMINATOR = ''\n'',
		CODEPAGE = ''65001''
	);'
;
EXEC sp_executesql @sql;
SELECT COUNT(*) AS count_review  FROM dbo.stg_reviews

-- 6. stg_products
TRUNCATE TABLE dbo.stg_products

SET @sql = '
	BULK INSERT dbo.stg_products
	FROM ''' + @data_path + 'olist_products_dataset.csv''
	WITH (
		FORMAT = ''CSV'',
		FIRSTROW = 2,
		FIELDTERMINATOR = '','',
		ROWTERMINATOR = ''0x0a'',
		CODEPAGE = ''65001''
	);'
;
EXEC sp_executesql @sql;
SELECT COUNT(*) AS count_products  FROM dbo.stg_products


-- 7. stg_sellers

TRUNCATE TABLE dbo.stg_sellers;

SET @sql = '
	BULK INSERT dbo.stg_sellers
	FROM ''' + @data_path + 'olist_sellers_dataset.csv''
	WITH (
		FORMAT = ''CSV'',
		FIRSTROW = 2,
		FIELDTERMINATOR = '','',
		ROWTERMINATOR = ''0x0a'',
		CODEPAGE = ''65001''
	);'
;
EXEC sp_executesql @sql;
SELECT COUNT(*) AS count_sellers  FROM dbo.stg_sellers

-- 8. stg_category_translation

TRUNCATE TABLE dbo.stg_category_translation;

SET @sql = '
	BULK INSERT dbo.stg_category_translation
	FROM ''' + @data_path + 'product_category_name_translation.csv''
	WITH (
		FORMAT = ''CSV'',
		FIRSTROW = 2,
		FIELDTERMINATOR = '','',
		ROWTERMINATOR = ''0x0a'',
		CODEPAGE = ''65001''
	);'
;
EXEC sp_executesql @sql;
SELECT COUNT(*) AS count_category_translation  FROM dbo.stg_category_translation

-- 9. stg_geolocation

TRUNCATE TABLE dbo.stg_geolocation;

SET @sql = '
	BULK INSERT dbo.stg_geolocation
	FROM ''' + @data_path + 'olist_geolocation_dataset.csv''
	WITH (
		FORMAT = ''CSV'',
		FIRSTROW = 2,
		FIELDTERMINATOR = '','',
		ROWTERMINATOR = ''0x0a'',
		CODEPAGE = ''65001''
	);'
;
EXEC sp_executesql @sql;
SELECT COUNT(*) AS count_geolocation  FROM dbo.stg_geolocation
