USE OlistECommerce
GO

-- 1. Checking if schema named core already exists, if it does then query skips creating one.
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'core')
	BEGIN 
		EXEC ('CREATE SCHEMA core');
END;
GO

-- 2. Dropping tables (Children / Dependent tables first, Parents last)
DROP TABLE IF EXISTS core.order_items;
DROP TABLE IF EXISTS core.payments;
DROP TABLE IF EXISTS core.reviews;
DROP TABLE IF EXISTS core.orders;
DROP TABLE IF EXISTS core.products;
DROP TABLE IF EXISTS core.sellers;
DROP TABLE IF EXISTS core.customers;
DROP TABLE IF EXISTS core.category_translation;
DROP TABLE IF EXISTS core.geolocation;
GO

-- 3. Creating core tables with correct data types and primary keys.
CREATE TABLE core.orders (
	order_id NVARCHAR(32) PRIMARY KEY NOT NULL,
	customer_id NVARCHAR(32) NOT NULL,
	order_status NVARCHAR(20) NOT NULL,
	order_purchase_timestamp DATETIME2 NOT NULL,
	order_approved_at DATETIME2,
	order_delivered_carrier_date DATETIME2,
	order_delivered_customer_date DATETIME2,
	order_estimated_delivery_date DATETIME2 NOT NULL
);

CREATE TABLE core.order_items (
	order_id NVARCHAR(32) NOT NULL,
	order_item_id INT NOT NULL,
	product_id NVARCHAR(32) NOT NULL,
	seller_id NVARCHAR(32) NOT NULL,
	shipping_limit_date DATETIME2 NOT NULL,
	price DECIMAL(10,2) NOT NULL,
	freight_value DECIMAL(10,2) NOT NULL,
	CONSTRAINT PK_order_items PRIMARY KEY (order_id, order_item_id)
);

CREATE TABLE core.customers (
	customer_id NVARCHAR(32) PRIMARY KEY NOT NULL,
	customer_unique_id NVARCHAR(32) NOT NULL,
	customer_zip_code_prefix CHAR(5) NOT NULL,
	customer_city NVARCHAR(50) NOT NULL,
	customer_state CHAR(2) NOT NULL
);

CREATE TABLE core.payments (
	order_id NVARCHAR(32) NOT NULL,
	payment_sequential INT NOT NULL,
	payment_type NVARCHAR(20) NOT NULL,
	payment_installments SMALLINT NOT NULL,
	payment_value DECIMAL(10,2) NOT NULL,
	CONSTRAINT PK_payments PRIMARY KEY (order_id, payment_sequential)
);

CREATE TABLE core.reviews (
	review_id NVARCHAR(32) NOT NULL,
	order_id NVARCHAR(32) NOT NULL,
	review_score SMALLINT NOT NULL,
	review_comment_title NVARCHAR(150),
	review_comment_message NVARCHAR(MAX),
	review_creation_date DATE NOT NULL,
	review_answer_timestamp DATETIME2,
	CONSTRAINT PK_reviews PRIMARY KEY (review_id, order_id)
);

-- I fixed a typographical error in the word length.
CREATE TABLE core.products (
	product_id NVARCHAR(32) PRIMARY KEY NOT NULL,
	product_category_name NVARCHAR(100),
	product_name_length SMALLINT,
	product_description_length INT,
	product_photos_qty SMALLINT,
	product_weight_g INT,
	product_length_cm INT,
	product_height_cm INT,
	product_width_cm INT
);

CREATE TABLE core.sellers (
	seller_id NVARCHAR(32) PRIMARY KEY NOT NULL,
	seller_zip_code_prefix CHAR(5) NOT NULL,
	seller_city NVARCHAR(50) NOT NULL,
	seller_state CHAR(2) NOT NULL
);

CREATE TABLE core.category_translation (
	product_category_name NVARCHAR(100) PRIMARY KEY NOT NULL,
	product_category_name_english NVARCHAR(100)
);

CREATE TABLE core.geolocation (
	geolocation_id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	geolocation_zip_code_prefix CHAR(5) NOT NULL,
	geolocation_lat DECIMAL(23, 20) NOT NULL,
	geolocation_lng DECIMAL(23, 20) NOT NULL,
	geolocation_city NVARCHAR(50) NOT NULL,
	geolocation_state CHAR(2) NOT NULL
);