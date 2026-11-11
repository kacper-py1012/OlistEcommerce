USE OlistECommerce;
GO

-- Analysis of the core layer. Run after 05, 07 and 08. Every query only reads data.
-- Revenue is counted from order_items.price (not payments, which would multiply the sums).
-- Only delivered orders are counted, unless a query says otherwise.

-- 1. Monthly sales: orders, revenue and freight per month.
SELECT
	YEAR(o.order_purchase_timestamp) AS [Year],
	MONTH(o.order_purchase_timestamp) AS [Month],
	COUNT(DISTINCT o.order_id) AS [Number of orders], 
	SUM(oi.price) AS [Revenue],
	SUM(oi.freight_value) AS [Sum of freight value]
FROM core.orders AS o
JOIN core.order_items AS oi 
	ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY YEAR(o.order_purchase_timestamp), MONTH(o.order_purchase_timestamp)
ORDER BY [Year], [Month];

-- Findings: sales grew through 2017 (peak in November 2017) and stayed stable in 2018.
-- The first months of 2016 and the last month of the data are incomplete.

-- 2. Top 10 product categories by revenue and overall category share.
SELECT TOP 10
	COALESCE(ct.product_category_name_english, 'Unknown Category') AS product_category_name_english,
	COUNT(DISTINCT o.order_id) AS [Number of orders],
	SUM(oi.price) AS [Revenue]
FROM core.order_items AS oi
JOIN core.orders AS o
	ON oi.order_id = o.order_id
JOIN core.products AS p
	ON oi.product_id = p.product_id
LEFT JOIN core.category_translation AS ct
	ON p.product_category_name = ct.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY COALESCE(ct.product_category_name_english, 'Unknown Category')
ORDER BY [Revenue] DESC;
-- Findings: health_beauty, watches_gifts, and bed_bath_table lead in revenue (each over 1M).
-- bed_bath_table has the highest order volume, but watches_gifts generates similar revenue with nearly half the orders.

-- 3. Payment methods distribution by order volume and total processed value.
SELECT
	p.payment_type as [Type of payment],
	COUNT(DISTINCT o.order_id) AS [Number of orders],
	SUM(p.payment_value) AS [Total Payment Value],
	CAST(COUNT(DISTINCT o.order_id) * 100.0 / (SELECT COUNT(*) FROM core.orders WHERE order_status = 'delivered') AS DECIMAL(5,2)) AS [Share of Orders (%)]
FROM core.payments AS p
JOIN core.orders AS o
	ON p.order_id = o.order_id
WHERE order_status = 'delivered'
GROUP BY p.payment_type
ORDER BY COUNT(DISTINCT o.order_id) DESC;
-- Findings: Credit card is the primary choice (~77% of orders, 12.1M payment value), followed by boleto (~20%).
-- Boleto = 
-- Shares sum over 100% because customers can combine multiple payment types in a single order.

-- 4. Delivery performance: actual vs estimated delivery time and late deliveries.
SELECT
	COUNT(*) AS [Number of total orders],
	SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) AS [Number of delayed deliveries],
	AVG(DATEDIFF(day, order_purchase_timestamp, order_delivered_customer_date)) AS [Avg actual delivery days],
	AVG(DATEDIFF(day, order_purchase_timestamp, order_estimated_delivery_date)) AS [Avg estimated delivery days],
	CAST(SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS [Delayed orders share (%)]
FROM core.orders
WHERE order_status = 'delivered' 
	AND order_delivered_customer_date IS NOT NULL;
-- Findings: Average delivery takes 12 days, well below the estimated 24 days.
-- Only 8.11% of orders are late because Olist gives customers very safe delivery estimates.

-- 5. Geographic distribution of orders by customer state.
SELECT
	c.customer_state AS [State],
	COUNT(DISTINCT o.order_id) AS [Number of orders],
	CAST(COUNT(DISTINCT o.order_id) * 100.0 / (SELECT COUNT(*) FROM core.orders WHERE order_status = 'delivered') AS DECIMAL(5,2)) AS [Order share by State (%)]
FROM core.orders AS o
JOIN core.customers AS c
	ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY COUNT(DISTINCT o.order_id) DESC
-- Findings: São Paulo (SP) dominates with over 40% of all delivered orders.
-- The top three states (SP, RJ, MG) make up roughly two-thirds of the total market volume.