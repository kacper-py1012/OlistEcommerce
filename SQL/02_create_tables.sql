USE OlistECommerce;
GO
-- Deleting tables if they already exist.
IF OBJECT_ID(N'dbo.stg_orders', N'U') IS NOT NULL DROP TABLE dbo.stg_orders;
IF OBJECT_ID(N'dbo.stg_order_items', N'U') IS NOT NULL DROP TABLE dbo.stg_order_items;
IF OBJECT_ID(N'dbo.stg_customers', N'U') IS NOT NULL DROP TABLE dbo.stg_customers;
IF OBJECT_ID(N'dbo.stg_payments', N'U') IS NOT NULL DROP TABLE dbo.stg_payments;
IF OBJECT_ID(N'dbo.stg_reviews', N'U') IS NOT NULL DROP TABLE dbo.stg_reviews;
IF OBJECT_ID(N'dbo.stg_products', N'U') IS NOT NULL DROP TABLE dbo.stg_products;
IF OBJECT_ID(N'dbo.stg_sellers', N'U') IS NOT NULL DROP TABLE dbo.stg_sellers;
IF OBJECT_ID(N'dbo.stg_category_translation', N'U') IS NOT NULL DROP TABLE dbo.stg_category_translation;
IF OBJECT_ID(N'dbo.stg_geolocation', N'U') IS NOT NULL DROP TABLE dbo.stg_geolocation;
-- Here I'm creating staging tables to insert data later into them.
-- All columns are NVARCHAR so the import never fails on dirty data.
-- Data types and cleaning are handled later, in the final tables.
CREATE TABLE dbo.stg_orders (
	order_id NVARCHAR(50),
	customer_id NVARCHAR(50),
	order_status NVARCHAR(50),
	order_purchase_timestamp NVARCHAR(50),
	order_approved_at NVARCHAR(50),
	order_delivered_carrier_date NVARCHAR(50),
	order_delivered_customer_date NVARCHAR(50),
	order_estimated_delivery_date NVARCHAR(50)
	);
GO

CREATE TABLE dbo.stg_order_items (
	order_id NVARCHAR(50),
	order_item_id NVARCHAR(50),
	product_id NVARCHAR(50),
	seller_id NVARCHAR(50),
	shipping_limit_date NVARCHAR(50),
	price NVARCHAR(50),
	freight_value NVARCHAR(50)
	);
GO

CREATE TABLE dbo.stg_customers (
	customer_id NVARCHAR(50),
	customer_unique_id NVARCHAR(50),
	customer_zip_code_prefix NVARCHAR(50),
	customer_city NVARCHAR(50),
	customer_state NVARCHAR(50)
	);
GO

CREATE TABLE dbo.stg_payments (
	order_id NVARCHAR(50),
	payment_sequential NVARCHAR(50),
	payment_type NVARCHAR(50),
	payment_installments NVARCHAR(50),
	payment_value NVARCHAR(50)
	);
GO

CREATE TABLE dbo.stg_reviews (
	review_id NVARCHAR(50),
	order_id NVARCHAR(50),
	review_score NVARCHAR(50),
	review_comment_title NVARCHAR(150),		-- Here I noticed that 50 character limit might be too little.
	review_comment_message NVARCHAR(MAX),	-- This column expects data with much more characters.
	review_creation_date NVARCHAR(50),
	review_answer_timestamp NVARCHAR(50)
	);
GO

CREATE TABLE dbo.stg_products (
	product_id NVARCHAR(50),
	product_category_name NVARCHAR(100),
	product_name_lenght NVARCHAR(50),		-- Here I noticed a typographical error in column name originally in dataset file.
	product_description_lenght NVARCHAR(50),-- Here too.
	product_photos_qty NVARCHAR(50),
	product_weight_g NVARCHAR(50),
	product_length_cm NVARCHAR(50),			-- And here :)
	product_height_cm NVARCHAR(50),
	product_width_cm NVARCHAR(50)
	);
GO

CREATE TABLE dbo.stg_sellers (
	seller_id NVARCHAR(50),
	seller_zip_code_prefix NVARCHAR(50),
	seller_city NVARCHAR(50),
	seller_state NVARCHAR(50)
	);
GO

CREATE TABLE dbo.stg_category_translation (
	product_category_name NVARCHAR(100),
	product_category_name_english NVARCHAR(100)
	);
GO

CREATE TABLE dbo.stg_geolocation (
	geolocation_zip_code_prefix NVARCHAR(50),
	geolocation_lat NVARCHAR(50),
	geolocation_lng NVARCHAR(50),
	geolocation_city NVARCHAR(50),
	geolocation_state NVARCHAR(50)
	);
GO