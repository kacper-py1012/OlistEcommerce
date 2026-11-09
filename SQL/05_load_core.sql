USE OlistECommerce
GO

-- Here I will load the data from the staging tables to core tables.
-- First I need to delete (TRUNCATE) possibly existing data to execute following code correctly.
TRUNCATE TABLE core.orders;
TRUNCATE TABLE core.order_items;
TRUNCATE TABLE core.customers;
TRUNCATE TABLE core.payments;
TRUNCATE TABLE core.reviews;
TRUNCATE TABLE core.products;
TRUNCATE TABLE core.sellers;
TRUNCATE TABLE core.category_translation;
TRUNCATE TABLE core.geolocation;

-- Now the core tables are 100% ready to insert data.

INSERT INTO core.orders (
	order_id,
	customer_id,
	order_status,
	order_purchase_timestamp,
	order_approved_at,
	order_delivered_carrier_date,
	order_delivered_customer_date,
	order_estimated_delivery_date
)
SELECT
	order_id,
	customer_id,
	order_status,
	TRY_CAST(order_purchase_timestamp AS DATETIME2),
	TRY_CAST(order_approved_at AS DATETIME2),
	TRY_CAST(order_delivered_carrier_date AS DATETIME2),
	TRY_CAST(order_delivered_customer_date AS DATETIME2),
	TRY_CAST(order_estimated_delivery_date AS DATETIME2)
FROM dbo.stg_orders;

INSERT INTO core.order_items (
	order_id,
	order_item_id,
	product_id,
	seller_id,
	shipping_limit_date,
	price,
	freight_value
)
SELECT
	order_id,
	TRY_CAST(order_item_id AS INT),
	product_id,
	seller_id,
	TRY_CAST(shipping_limit_date AS DATETIME2),
	TRY_CAST(price AS DECIMAL(10,2)),
	TRY_CAST(freight_value AS DECIMAL(10,2))
FROM dbo.stg_order_items;

INSERT INTO core.customers (
	customer_id,
	customer_unique_id,
	customer_zip_code_prefix,
	customer_city,
	customer_state
)
SELECT
	customer_id,
	customer_unique_id,
	customer_zip_code_prefix,
	customer_city,
	customer_state
FROM dbo.stg_customers;

INSERT INTO core.payments (
	order_id,
	payment_sequential,
	payment_type,
	payment_installments,
	payment_value
)
SELECT
	order_id,
	TRY_CAST(payment_sequential AS INT),
	payment_type,
	TRY_CAST(payment_installments AS SMALLINT),
	TRY_CAST(payment_value AS DECIMAL(10,2))
FROM dbo.stg_payments;

INSERT INTO core.reviews (
	review_id,
	order_id,
	review_score,
	review_comment_title,
	review_comment_message,
	review_creation_date,
	review_answer_timestamp
)
SELECT
	review_id,
	order_id,
	TRY_CAST(review_score AS SMALLINT),
	review_comment_title,
	review_comment_message,
	TRY_CAST(review_creation_date AS DATE),
	TRY_CAST(review_answer_timestamp AS DATETIME2)
FROM dbo.stg_reviews;

INSERT INTO core.products (
	product_id,
	product_category_name,
	product_name_length,
	product_description_length,
	product_photos_qty,
	product_weight_g,
	product_length_cm,
	product_height_cm,
	product_width_cm
)
SELECT
	product_id,
	product_category_name,
	TRY_CAST(product_name_lenght AS SMALLINT),
	TRY_CAST(product_description_lenght AS INT),
	TRY_CAST(product_photos_qty AS SMALLINT),
	TRY_CAST(product_weight_g AS INT),
	TRY_CAST(product_length_cm AS INT),
	TRY_CAST(product_height_cm AS INT),
	TRY_CAST(product_width_cm AS INT)
FROM dbo.stg_products;

INSERT INTO core.sellers (
	seller_id,
	seller_zip_code_prefix,
	seller_city,
	seller_state
)
SELECT
	seller_id,
	seller_zip_code_prefix,
	seller_city,
	seller_state
FROM dbo.stg_sellers;

INSERT INTO core.category_translation (
	product_category_name,
	product_category_name_english
)
SELECT
	product_category_name,
	product_category_name_english
FROM dbo.stg_category_translation;

INSERT INTO core.geolocation (
	geolocation_zip_code_prefix,
	geolocation_lat,
	geolocation_lng,
	geolocation_city,
	geolocation_state
)
SELECT
	geolocation_zip_code_prefix,
	TRY_CAST(geolocation_lat AS DECIMAL(23,20)),
	TRY_CAST(geolocation_lng AS DECIMAL(23,20)),
	geolocation_city,
	geolocation_state
FROM dbo.stg_geolocation;