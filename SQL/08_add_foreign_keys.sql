USE OlistECommerce;
GO

-- 08_add_foreign_keys.sql
-- Add foreign key constraints across the core schema.
--
-- Uses IF NOT EXISTS so the script can be rerun safely.
-- Applied after loading and cleaning data in core.

-- 1. orders --> customers
IF NOT EXISTS (
    SELECT 1 
    FROM sys.foreign_keys 
    WHERE name = 'FK_orders_customers' 
      AND parent_object_id = OBJECT_ID('core.orders')
)
BEGIN
    ALTER TABLE core.orders
    ADD CONSTRAINT FK_orders_customers
    FOREIGN KEY(customer_id) REFERENCES core.customers(customer_id);
END;

-- 2. order_items --> orders
IF NOT EXISTS (
    SELECT 1 
    FROM sys.foreign_keys
    WHERE name = 'FK_order_items_orders'
        AND parent_object_id = OBJECT_ID('core.order_items')
)
BEGIN
    ALTER TABLE core.order_items
    ADD CONSTRAINT FK_order_items_orders
    FOREIGN KEY(order_id) REFERENCES core.orders(order_id);
END;

-- 3. order_items --> products
IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = 'FK_order_items_products'
        AND parent_object_id = OBJECT_ID('core.order_items')
)
BEGIN
    ALTER TABLE core.order_items
    ADD CONSTRAINT FK_order_items_products
    FOREIGN KEY(product_id) REFERENCES core.products(product_id);
END;

-- 4. order_items --> sellers
IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = 'FK_order_items_sellers'
        AND parent_object_id = OBJECT_ID('core.order_items')
)
BEGIN
    ALTER TABLE core.order_items
    ADD CONSTRAINT FK_order_items_sellers
    FOREIGN KEY(seller_id) REFERENCES core.sellers(seller_id);
END;

-- 5. payments --> orders
IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = 'FK_payments_orders'
        AND parent_object_id = OBJECT_ID('core.payments')
)
BEGIN
    ALTER TABLE core.payments
    ADD CONSTRAINT FK_payments_orders
    FOREIGN KEY (order_id) REFERENCES core.orders(order_id);
END;

-- 6. reviews --> orders
IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = 'FK_reviews_orders'
        AND parent_object_id = OBJECT_ID('core.reviews')
)
BEGIN
    ALTER TABLE core.reviews
    ADD CONSTRAINT FK_reviews_orders
    FOREIGN KEY (order_id) REFERENCES core.orders(order_id);
END;

-- 7. products --> category_translation
IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = ('FK_products_category_translation')
        AND parent_object_id = OBJECT_ID('core.products')
)
BEGIN
    ALTER TABLE core.products
    ADD CONSTRAINT FK_products_category_translation
    FOREIGN KEY (product_category_name) REFERENCES core.category_translation(product_category_name);
END;
GO