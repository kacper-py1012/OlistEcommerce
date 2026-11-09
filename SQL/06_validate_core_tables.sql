USE OlistECommerce
GO

-- Validation of the core layer.
-- Run after 05 (loading staging into core). Nothing is changed here, every query only reads data.
--
-- Goal: make sure the INSERT lost no rows and TRY_CAST did not silently change values.
-- Checks, table by table:
--   * row count, core vs staging,
--   * NULLs and empty strings in columns converted with TRY_CAST,
--   * value ranges (negative values, fake dates like 1900-01-01),
--   * length of CHAR columns (zip codes, states).
--	 * table specific checks (f.e. payment types, wrong city names, coordinates)
-- Problems that come from the source data are only noted here (f.e. wrong coordinates in geolocation).
-- They are fixed later, in the cleaning step.
-- HOW TO RUN: select a single query and press F5. Running the whole file returns dozens of
-- result sets at once, including heavy queries on geolocation (over 1 million rows).

-- ////////////////////////
-- ===== core.orders =====
-- \\\\\\\\\\\\\\\\\\\\\\\\

-- 1. Count of rows in core.orders and dbo.stg_orders.
-- Both values should be equal, which confirms the INSERT did not lose any rows.
SELECT 
	(SELECT COUNT(*) FROM core.orders) AS [CORE ORDERS COUNT],
	(SELECT COUNT(*) FROM dbo.stg_orders)  AS [STG ORDERS COUNT];

-- 2. Nulls in core for columns converted with TRY_CAST.
-- Some NULLs are valid (orders not approved or not delivered yet), expected: same as in staging.
SELECT
	COUNT(*) - COUNT(order_purchase_timestamp) AS purchase_nulls,
	COUNT(*) - COUNT(order_approved_at) AS approved_nulls,
	COUNT(*) - COUNT(order_delivered_carrier_date) AS carrier_nulls,
	COUNT(*) - COUNT(order_delivered_customer_date) AS customer_nulls,
	COUNT(*) - COUNT(order_estimated_delivery_date) AS estimated_nulls
FROM core.orders;

-- 3. Nulls and empty strings in staging for the same columns.
-- Expected: the same result as in point 2. If it differs, TRY_CAST changed some values into NULL.
SELECT
	SUM(CASE WHEN order_purchase_timestamp IS NULL OR order_purchase_timestamp = '' THEN 1 ELSE 0 END) AS STG_purchase_nulls,
	SUM(CASE WHEN order_approved_at IS NULL OR order_approved_at = '' THEN 1 ELSE 0 END) AS STG_approved_nulls,
	SUM(CASE WHEN order_delivered_carrier_date IS NULL OR order_delivered_carrier_date = '' THEN 1 ELSE 0 END) AS STG_carrier_nulls,
	SUM(CASE WHEN order_delivered_customer_date IS NULL OR order_delivered_customer_date = '' THEN 1 ELSE 0 END) AS STG_customer_nulls,
	SUM(CASE WHEN order_estimated_delivery_date IS NULL OR order_estimated_delivery_date = '' THEN 1 ELSE 0 END) AS STG_estimated_nulls
FROM dbo.stg_orders;

-- 4. Dates range in core table.
-- Expected: dates with no 1900-01-01 which would mean an empty string was converted into a fake date.
SELECT
	MIN(order_purchase_timestamp) AS purchase_min, MAX(order_purchase_timestamp) AS purchase_max,
	MIN(order_approved_at) AS approved_min, MAX(order_approved_at) AS approved_max,
	MIN(order_delivered_carrier_date) AS carrier_min, MAX(order_delivered_carrier_date) AS carrier_max,
	MIN(order_delivered_customer_date) AS customer_min, MAX(order_delivered_customer_date) AS customer_max,
	MIN(order_estimated_delivery_date) AS estimated_min, MAX(order_estimated_delivery_date) AS estimated_max
FROM core.orders;

-- 5. Ranges of date columns in staging and core tables.
-- Expected: the same date and time in both (core only shows extra trailing zeros).
-- NULLIF turns empty strings into NULL in staging, so they do not count as the smallest value.
SELECT
	(SELECT MIN(NULLIF(order_purchase_timestamp, '')) FROM dbo.stg_orders) AS stg_purchase_min,
	(SELECT MIN(order_purchase_timestamp) FROM core.orders) AS core_purchase_min,
	(SELECT MAX(order_purchase_timestamp) FROM dbo.stg_orders) AS stg_purchase_max,
	(SELECT MAX(order_purchase_timestamp) FROM core.orders) AS core_purchase_max,

	(SELECT MIN(NULLIF(order_approved_at, '')) FROM dbo.stg_orders) AS stg_approved_min,
	(SELECT MIN(order_approved_at) FROM core.orders) AS core_approved_min,
	(SELECT MAX(order_approved_at) FROM dbo.stg_orders) AS stg_approved_max,
	(SELECT MAX(order_approved_at) FROM core.orders) AS core_approved_max,

	(SELECT MIN(NULLIF(order_delivered_carrier_date, '')) FROM dbo.stg_orders) AS stg_carrier_min,
	(SELECT MIN(order_delivered_carrier_date) FROM core.orders) AS core_carrier_min,
	(SELECT MAX(order_delivered_carrier_date) FROM dbo.stg_orders) AS stg_carrier_max,
	(SELECT MAX(order_delivered_carrier_date) FROM core.orders) AS core_carrier_max,

	(SELECT MIN(NULLIF(order_delivered_customer_date, '')) FROM dbo.stg_orders) AS stg_customer_min,
	(SELECT MIN(order_delivered_customer_date) FROM core.orders) AS core_customer_min,
	(SELECT MAX(order_delivered_customer_date) FROM dbo.stg_orders) AS stg_customer_max,
	(SELECT MAX(order_delivered_customer_date) FROM core.orders) AS core_customer_max,

	(SELECT MIN(NULLIF(order_estimated_delivery_date, '')) FROM dbo.stg_orders) AS stg_estimated_min,
	(SELECT MIN(order_estimated_delivery_date) FROM core.orders) AS core_estimated_min,
	(SELECT MAX(order_estimated_delivery_date) FROM dbo.stg_orders) AS stg_estimated_max,
	(SELECT MAX(order_estimated_delivery_date) FROM core.orders) AS core_estimated_max;

-- /////////////////////////////
-- ===== core.order_items =====
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\

-- 1. Row count, core vs staging (should be equal).
SELECT 
	(SELECT COUNT(*) FROM core.order_items) AS [CORE ORDER_ITEMS COUNT],
	(SELECT COUNT(*) FROM dbo.stg_order_items)  AS [STG ORDER_ITEMS COUNT];

-- 2. Nulls in core for columns converted with TRY_CAST (expected: 0 in every column).
SELECT
	COUNT(*) - COUNT(order_item_id) AS order_item_id_nulls,
	COUNT(*) - COUNT(shipping_limit_date) AS shipping_limit_date_nulls,
	COUNT(*) - COUNT(price) AS price_nulls,
	COUNT(*) - COUNT(freight_value) AS freight_value_nulls
FROM core.order_items;

-- 3. Nulls and empty strings in staging for the same columns (expected: same as point 2).
SELECT
	SUM(CASE WHEN order_item_id IS NULL OR order_item_id = '' THEN 1 ELSE 0 END) AS STG_order_item_id_nulls,
	SUM(CASE WHEN shipping_limit_date IS NULL OR shipping_limit_date = '' THEN 1 ELSE 0 END) AS STG_shipping_limit_date_nulls,
	SUM(CASE WHEN price IS NULL OR price = '' THEN 1 ELSE 0 END) AS STG_price_nulls,
	SUM(CASE WHEN freight_value IS NULL OR freight_value = '' THEN 1 ELSE 0 END) AS STG_freight_value_nulls
FROM dbo.stg_order_items;

-- 4. Value ranges in core (expected: order_item_id starts at 1, no zero prices, no 1900-01-01).
-- freight_value = 0 is valid (free shipping), shipping_limit_date goes up to 2020 in the source data.
SELECT
	MIN(order_item_id) AS order_item_id_min, MAX(order_item_id) AS order_item_id_max,
	MIN(shipping_limit_date) AS shipping_limit_date_min, MAX(shipping_limit_date) AS shipping_limit_date_max,
	MIN(price) AS price_min, MAX(price) AS price_max,
	MIN(freight_value) AS freight_value_min, MAX(freight_value) AS freight_value_max
FROM core.order_items;

-- 5. Range of shipping_limit_date, staging vs core (expected: the same date and time).
SELECT
	(SELECT MIN(shipping_limit_date) FROM dbo.stg_order_items) AS stg_shipping_limit_date_min,
	(SELECT MIN(shipping_limit_date) FROM core.order_items) AS core_shipping_limit_date_min,
	(SELECT MAX(shipping_limit_date) FROM dbo.stg_order_items) AS stg_shipping_limit_date_max,
	(SELECT MAX(shipping_limit_date) FROM core.order_items) AS core_shipping_limit_date_max;

-- ///////////////////////////
-- ===== core.customers =====
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\

-- 1. Row count, core vs staging (should be equal).
SELECT 
	(SELECT COUNT(*) FROM core.customers) AS [CORE CUSTOMERS COUNT],
	(SELECT COUNT(*) FROM dbo.stg_customers)  AS [STG CUSTOMERS COUNT];

-- 2. Zip code length, staging vs core, side by side.
-- Expected: one row, length 5, the same count in both.
SELECT
	COALESCE(s.zip_length, c.zip_length) AS zip_length,
	s.stg_count,
	c.core_count
FROM (
	SELECT LEN(customer_zip_code_prefix) AS zip_length, COUNT(*) AS stg_count
	FROM dbo.stg_customers
	GROUP BY LEN(customer_zip_code_prefix)
) AS s
FULL OUTER JOIN (
	SELECT LEN(customer_zip_code_prefix) AS zip_length, COUNT(*) AS core_count
	FROM core.customers
	GROUP BY LEN(customer_zip_code_prefix)
) AS c
	ON s.zip_length = c.zip_length;

-- 3. State length, staging vs core, same logic as in 2.
-- Expected: one row, length 2, the same count in both.
SELECT
	COALESCE(s.state_length, c.state_length) AS state_length,
	s.stg_count,
	c.core_count
FROM (
	SELECT LEN(customer_state) AS state_length, COUNT(*) AS stg_count
	FROM dbo.stg_customers
	GROUP BY LEN(customer_state)
) AS s
FULL OUTER JOIN (
	SELECT LEN(customer_state) AS state_length, COUNT(*) AS core_count
	FROM core.customers
	GROUP BY LEN(customer_state)
) AS c
	ON s.state_length = c.state_length;

-- //////////////////////////
-- ===== core.payments =====
-- \\\\\\\\\\\\\\\\\\\\\\\\\\

-- 1. Row count, core vs staging (should be equal).
SELECT
	(SELECT COUNT(*) FROM core.payments) AS [CORE PAYMENTS COUNT],
	(SELECT COUNT(*) FROM dbo.stg_payments)  AS [STG PAYMENTS COUNT];

-- 2. Nulls in core for columns converted with TRY_CAST (expected: 0 in every column).
SELECT
	COUNT(*) - COUNT(payment_sequential) AS payment_sequential_nulls,
	COUNT(*) - COUNT(payment_installments) AS payment_installments_nulls,
	COUNT(*) - COUNT(payment_value) AS payment_value_nulls
FROM core.payments;

-- 3. Nulls and empty strings in staging for the same columns (expected: same as point 2).
SELECT
	SUM(CASE WHEN payment_sequential IS NULL OR payment_sequential = '' THEN 1 ELSE 0 END) AS STG_payment_sequential_nulls,
	SUM(CASE WHEN payment_installments IS NULL OR payment_installments = '' THEN 1 ELSE 0 END) AS STG_payment_installments_nulls,
	SUM(CASE WHEN payment_value IS NULL OR payment_value = '' THEN 1 ELSE 0 END) AS STG_payment_value_nulls
FROM dbo.stg_payments;

-- 4. Value ranges in core.
-- Zeros in payment_installments and payment_value come from the source data.
SELECT
	MIN(payment_sequential) AS payment_sequential_min, MAX(payment_sequential) AS payment_sequential_max,
	MIN(payment_installments) AS payment_installments_min, MAX(payment_installments) AS payment_installments_max,
	MIN(payment_value) AS payment_value_min, MAX(payment_value) AS payment_value_max
FROM core.payments;

-- 5. Checking payment_type values and the 'not_defined' rows.
-- 'not_defined' has payment_value 0.00, it comes from the source data.
SELECT * FROM core.payments
WHERE payment_type = 'not_defined';

-- /////////////////////////
-- ===== core.reviews =====
-- \\\\\\\\\\\\\\\\\\\\\\\\\

-- 1. Row count, core vs staging (should be equal).
SELECT
	(SELECT COUNT(*) FROM core.reviews) AS [CORE REVIEWS COUNT],
	(SELECT COUNT(*) FROM dbo.stg_reviews)  AS [STG REVIEWS COUNT];

-- 2. Nulls in core for columns converted with TRY_CAST (expected: 0 in every column).
SELECT
	COUNT(*) - COUNT(review_score) AS review_score_nulls,
	COUNT(*) - COUNT(review_creation_date) AS review_creation_date_nulls,
	COUNT(*) - COUNT(review_answer_timestamp) AS review_answer_timestamp_nulls
FROM core.reviews;

-- 3. Nulls and empty strings in staging for the same columns (expected: same as point 2).
SELECT
	SUM(CASE WHEN review_score IS NULL OR review_score = '' THEN 1 ELSE 0 END) AS STG_review_score_nulls,
	SUM(CASE WHEN review_creation_date IS NULL OR review_creation_date = '' THEN 1 ELSE 0 END) AS STG_review_creation_date_nulls,
	SUM(CASE WHEN review_answer_timestamp IS NULL OR review_answer_timestamp = '' THEN 1 ELSE 0 END) AS STG_review_answer_timestamp_nulls
FROM dbo.stg_reviews;

-- 4. Value ranges in core.
-- Expected: review_score range (1-5), no timestamps in review_creation_date_min/max, no strange dates f.e. 1900-01-01.
SELECT
	MIN(review_score) AS review_score_min, MAX(review_score) AS review_score_max,
	MIN(review_creation_date) AS review_creation_date_min, MAX(review_creation_date) AS review_creation_date_max,
	MIN(review_answer_timestamp) AS review_answer_timestamp_min, MAX(review_answer_timestamp) AS review_answer_timestamp_max
FROM core.reviews;

-- 5. Checking if any review was answered before it was created. Expected: 0.
SELECT COUNT(*) AS [Invalid dates]
FROM core.reviews
WHERE review_answer_timestamp < review_creation_date;

-- //////////////////////////
-- ===== core.products =====
-- \\\\\\\\\\\\\\\\\\\\\\\\\\

-- 1. Row count, core vs staging (should be equal).
SELECT
	(SELECT COUNT(*) FROM core.products) AS [CORE PRODUCTS COUNT],
	(SELECT COUNT(*) FROM dbo.stg_products)  AS [STG PRODUCTS COUNT];

-- 2. Nulls in core for columns converted with TRY_CAST, some NULLs are valid (products with missing data in the source), expected: same as staging.
SELECT
	COUNT(*) - COUNT(product_name_length) AS product_name_length_nulls,
	COUNT(*) - COUNT(product_description_length) AS product_description_length_nulls,
	COUNT(*) - COUNT(product_photos_qty) AS product_photos_qty_nulls,
	COUNT(*) - COUNT(product_weight_g) AS product_weight_g_nulls,
	COUNT(*) - COUNT(product_length_cm) AS product_length_cm_nulls,
	COUNT(*) - COUNT(product_height_cm) AS product_height_cm_nulls,
	COUNT(*) - COUNT(product_width_cm) AS product_width_cm_nulls
FROM core.products;

-- 3. Nulls and empty strings in staging for the same columns (expected: same as point 2).
SELECT
	SUM(CASE WHEN product_name_lenght IS NULL OR product_name_lenght = '' THEN 1 ELSE 0 END) AS STG_product_name_length_nulls,
	SUM(CASE WHEN product_description_lenght IS NULL OR product_description_lenght = '' THEN 1 ELSE 0 END) AS STG_product_description_length_nulls,
	SUM(CASE WHEN product_photos_qty IS NULL OR product_photos_qty = '' THEN 1 ELSE 0 END) AS STG_product_photos_qty_nulls,
	SUM(CASE WHEN product_weight_g IS NULL OR product_weight_g = '' THEN 1 ELSE 0 END) AS STG_product_weight_g_nulls,
	SUM(CASE WHEN product_length_cm IS NULL OR product_length_cm = '' THEN 1 ELSE 0 END) AS STG_product_length_cm_nulls,
	SUM(CASE WHEN product_height_cm IS NULL OR product_height_cm = '' THEN 1 ELSE 0 END) AS STG_product_height_cm_nulls,
	SUM(CASE WHEN product_width_cm IS NULL OR product_width_cm = '' THEN 1 ELSE 0 END) AS STG_product_width_cm_nulls
FROM dbo.stg_products;

-- 4. Value ranges in core. No negative values.
-- product_weight_g = 0 appears in 4 rows, it comes from the source data.
SELECT
	MIN(product_name_length) AS product_name_length_min, MAX(product_name_length) AS product_name_length_max,
	MIN(product_description_length) AS product_description_length_min, MAX(product_description_length) AS product_description_length_max,
	MIN(product_photos_qty) AS product_photos_qty_min, MAX(product_photos_qty) AS product_photos_qty_max,
	MIN(product_weight_g) AS product_weight_g_min, MAX(product_weight_g) AS product_weight_g_max,
	MIN(product_length_cm) AS product_length_cm_min, MAX(product_length_cm) AS product_length_cm_max,
	MIN(product_height_cm) AS product_height_cm_min, MAX(product_height_cm) AS product_height_cm_max,
	MIN(product_width_cm) AS product_width_cm_min, MAX(product_width_cm) AS product_width_cm_max
FROM core.products;

-- 5. Extra check: comparing weight row by row (joined on product_id), staging vs core.
-- Staging is converted with the same TRY_CAST as in the INSERT. Expected: 0 different rows.
SELECT COUNT(*) AS different_weights
FROM dbo.stg_products AS s
	INNER JOIN core.products AS c ON c.product_id = s.product_id
WHERE c.product_weight_g != TRY_CAST(s.product_weight_g AS INT);

-- /////////////////////////
-- ===== core.sellers =====
-- \\\\\\\\\\\\\\\\\\\\\\\\\

-- 1. Row count, core vs staging (should be equal).
SELECT
	(SELECT COUNT(*) FROM core.sellers) AS [CORE SELLERS COUNT],
	(SELECT COUNT(*) FROM dbo.stg_sellers)  AS [STG SELLERS COUNT];

-- 2. Zip code length, staging vs core, side by side.
-- Two small queries count rows per length, FULL OUTER JOIN puts them in one table.
-- COALESCE picks the length from whichever side has it, so a length that exists
-- only in one table still shows up instead of an empty cell.
-- Expected: one row, length 5, the same count in both.
SELECT
	COALESCE(s.zip_length, c.zip_length) AS zip_length,
	s.stg_count,
	c.core_count
FROM (
	SELECT LEN(seller_zip_code_prefix) AS zip_length, COUNT(*) AS stg_count
	FROM dbo.stg_sellers
	GROUP BY LEN(seller_zip_code_prefix)
) AS s
FULL OUTER JOIN (
	SELECT LEN(seller_zip_code_prefix) AS zip_length, COUNT(*) AS core_count
	FROM core.sellers
	GROUP BY LEN(seller_zip_code_prefix)
) AS c
	ON s.zip_length = c.zip_length;

-- 3. State length, staging vs core, same logic as in 2.
-- Expected: one row, length 2, the same count in both.
SELECT
	COALESCE(s.state_length, c.state_length) AS state_length,
	s.stg_count,
	c.core_count
FROM (
	SELECT LEN(seller_state) AS state_length, COUNT(*) AS stg_count
	FROM dbo.stg_sellers
	GROUP BY LEN(seller_state)
) AS s
FULL OUTER JOIN (
	SELECT LEN(seller_state) AS state_length, COUNT(*) AS core_count
	FROM core.sellers
	GROUP BY LEN(seller_state)
) AS c
	ON s.state_length = c.state_length;

-- 4. Checking seller_city for values that do not look like a city name.
-- Found 2, each in one row: 04482255 (digits) and an e-mail address. They come from the source data.
-- Not fixing it here, it belongs to the data cleaning step.
SELECT
	seller_city AS wrong_city_name,
	COUNT(seller_city) AS [count]
FROM core.sellers
WHERE seller_city LIKE '%[0-9]%' OR seller_city LIKE '%@%'
GROUP BY seller_city;

-- //////////////////////////////////////
-- ===== core.category_translation =====
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

-- 1. Row count, core vs staging (should be equal).
SELECT
	(SELECT COUNT(*) FROM core.category_translation) AS [CORE CATEGORY_TRANSLATION COUNT],
	(SELECT COUNT(*) FROM dbo.stg_category_translation)  AS [STG CATEGORY_TRANSLATION COUNT];

-- 2. Empty strings and NULLs in category names (Portuguese and English), core vs staging.
-- Expected: 0 in all four columns.
SELECT 
c.product_category_name_nulls AS [PT - Core category empty or NULL],
c.product_category_name_english_nulls AS [EN - Core category empty or NULL],
s.product_category_name_nulls AS [PT - Staging category empty or NULL],
s.product_category_name_english_nulls AS [EN - Staging category empty or NULL]
FROM 
	(SELECT 
        SUM(CASE WHEN product_category_name IS NULL OR product_category_name = '' THEN 1 ELSE 0 END) AS product_category_name_nulls,
        SUM(CASE WHEN product_category_name_english IS NULL OR product_category_name_english = '' THEN 1 ELSE 0 END) AS product_category_name_english_nulls
     FROM core.category_translation) AS c
CROSS JOIN 
	(SELECT 
		SUM(CASE WHEN product_category_name IS NULL OR product_category_name = '' THEN 1 ELSE 0 END) AS product_category_name_nulls,
		SUM(CASE WHEN product_category_name_english IS NULL OR product_category_name_english = '' THEN 1 ELSE 0 END) AS product_category_name_english_nulls
	FROM dbo.stg_category_translation) AS s;

-- /////////////////////////////
-- ===== core.geolocation =====
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\

-- 1. Row count, core vs staging (should be equal).
SELECT
	(SELECT COUNT(*) FROM core.geolocation) AS [CORE GEOLOCATION COUNT],
	(SELECT COUNT(*) FROM dbo.stg_geolocation)  AS [STG GEOLOCATION COUNT];

-- 2. NULLs in latitude and longitude, core vs staging.
-- Staging counts NULLs and empty strings, core only NULLs (empty strings cannot exist after TRY_CAST).
-- Expected: 0 in all four columns, the same on both sides.
SELECT 
c.geolocation_lat_nulls AS [Core geolocation latitude NULLs count],
c.geolocation_lng_nulls AS [Core geolocation long NULLs count],
s.geolocation_lat_nulls AS [STG geolocation latitude empty or NULL],
s.geolocation_lng_nulls AS [STG geolocation long empty or NULL]
FROM 
	(SELECT 
        COUNT(*) - COUNT(geolocation_lat) AS geolocation_lat_nulls,
        COUNT(*) - COUNT(geolocation_lng) AS geolocation_lng_nulls
     FROM core.geolocation) AS c
CROSS JOIN 
	(SELECT 
		SUM(CASE WHEN geolocation_lat IS NULL OR geolocation_lat = '' THEN 1 ELSE 0 END) AS geolocation_lat_nulls,
		SUM(CASE WHEN geolocation_lng IS NULL OR geolocation_lng = '' THEN 1 ELSE 0 END) AS geolocation_lng_nulls
	FROM dbo.stg_geolocation) AS s;

-- 3. Coordinate ranges in core. Some points are outside Brazil (latitude from -36 to 45, longitude from -101 to 121).
-- It comes from the source data, not fixing it here, it belongs to the cleaning step.
SELECT
	MIN(geolocation_lat) AS [Geolocation latitude minimum], MAX(geolocation_lat) AS [Geolocation latitude maximum],
	MIN(geolocation_lng) AS [Geolocation long minimum], MAX(geolocation_lng) AS [Geolocation long maximum]
FROM core.geolocation;

-- 4. Checking how many geolocation points are outside Brazil (approximate bounding box).
-- Longitude is cut at -32 so the island Fernando de Noronha (correct points) is not counted.
-- Mostly small Brazilian towns with wrong coordinates, comes from the source data, not fixing it here.
-- Total: 31 rows in 23 towns.
SELECT 
	geolocation_city,
	COUNT(*) AS outside_brazil
FROM core.geolocation
WHERE geolocation_lat NOT BETWEEN -34 AND 6
   OR geolocation_lng NOT BETWEEN -75 AND -32
GROUP BY geolocation_city;

-- Total number of points outside the bounding box:
SELECT
	COUNT(*) AS [Count of points outside Brazil]
FROM core.geolocation
WHERE geolocation_lat NOT BETWEEN -34 AND 6
   OR geolocation_lng NOT BETWEEN -75 AND -32;

-- Note: city names are inconsistent (with and without accents).
-- To be fixed in the cleaning step.

-- 5. Zip code length, staging vs core, side by side.
-- Expected: one row, length 5, the same count in both.
SELECT
	COALESCE(s.zip_length, c.zip_length) AS zip_length,
	s.stg_count,
	c.core_count
FROM (
	SELECT LEN(geolocation_zip_code_prefix) AS zip_length, COUNT(*) AS stg_count
	FROM dbo.stg_geolocation
	GROUP BY LEN(geolocation_zip_code_prefix)
) AS s
FULL OUTER JOIN (
	SELECT LEN(geolocation_zip_code_prefix) AS zip_length, COUNT(*) AS core_count
	FROM core.geolocation
	GROUP BY LEN(geolocation_zip_code_prefix)
) AS c
	ON s.zip_length = c.zip_length;

-- 6. State length, staging vs core, same logic as in 5.
-- Expected: one row, length 2, the same count in both.
SELECT
	COALESCE(s.state_length, c.state_length) AS state_length,
	s.stg_count,
	c.core_count
FROM (
	SELECT LEN(geolocation_state) AS state_length, COUNT(*) AS stg_count
	FROM dbo.stg_geolocation
	GROUP BY LEN(geolocation_state)
) AS s
FULL OUTER JOIN (
	SELECT LEN(geolocation_state) AS state_length, COUNT(*) AS core_count
	FROM core.geolocation
	GROUP BY LEN(geolocation_state)
) AS c
	ON s.state_length = c.state_length;

-- ==============================
-- ===== Cross-table checks =====
-- ==============================

-- 1. Orders pointing to a customer that does not exist in core.customers (orphaned orders).
-- Foreign key from orders to customers would fail if any exist. Expected: 0.
SELECT COUNT(*) AS orders_without_customer
FROM core.orders AS o
	LEFT JOIN core.customers AS c
	ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- 2. Order items pointing to an order that does not exist in core.orders (orphaned items).
-- Foreign key from order_items to orders would fail if any exist. Expected: 0.
SELECT COUNT(*) AS order_items_without_order
FROM core.order_items AS oi
	LEFT JOIN core.orders AS o
	ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- 3. Order items pointing to a product that does not exist in core.products (orphaned items).
-- Foreign key from order_items to products would fail if any exist. Expected: 0.
SELECT COUNT(*) AS order_items_without_product
FROM core.order_items AS oi
	LEFT JOIN core.products AS p
	ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- 4. Order items pointing to a seller that does not exist in core.sellers (orphaned items).
-- Foreign key from order_items to sellers would fail if any exist. Expected: 0.
SELECT COUNT(*) AS order_items_without_seller
FROM core.order_items AS oi
	LEFT JOIN core.sellers AS s
	ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

-- 5. Payments pointing to an order that does not exist in core.orders (orphaned payments).
-- Foreign key from payments to orders would fail if any exist. Expected: 0.
SELECT COUNT(*) AS payments_without_order
FROM core.payments AS p
	LEFT JOIN core.orders AS o
	ON p.order_id = o.order_id
WHERE o.order_id IS NULL;

-- 6. Reviews pointing to an order that does not exist in core.orders (orphaned reviews).
-- Foreign key from reviews to orders would fail if any exist. Expected: 0.
SELECT COUNT(*) AS reviews_without_order
FROM core.reviews AS r
	LEFT JOIN core.orders AS o
	ON r.order_id = o.order_id
WHERE o.order_id IS NULL;

-- 7a. Products with a category that has no translation in core.category_translation.
-- Foreign key from products to category_translation would fail. Found 13 products in 2 categories:
-- pc_gamer, portateis_cozinha_e_preparadores_de_alimentos. Comes from the source data, to be fixed in the cleaning step.
SELECT COUNT(*) AS products_without_translation
FROM core.products AS p
	LEFT JOIN core.category_translation AS ct
	ON p.product_category_name = ct.product_category_name
WHERE ct.product_category_name IS NULL
AND p.product_category_name IS NOT NULL;

-- 7b. The same check, lists the names of the categories without translation.
SELECT DISTINCT p.product_category_name AS categories_without_translation
FROM core.products AS p
	LEFT JOIN core.category_translation AS ct
	ON p.product_category_name = ct.product_category_name
WHERE ct.product_category_name IS NULL
AND p.product_category_name IS NOT NULL;