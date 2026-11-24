
USE ecommerce_db;

START TRANSACTION;

-- =========================================
-- 1. CATEGORIES
-- =========================================

INSERT INTO categories
(category_id, category_name, description)
VALUES
(1, 'Electronics', 'Electronic devices and accessories'),
(2, 'Books', 'Educational and general books'),
(3, 'Fashion', 'Clothing and fashion products'),
(4, 'Home & Kitchen', 'Home and kitchen essentials');

-- =========================================
-- 2. CUSTOMERS
-- =========================================

INSERT INTO customers
(customer_id, first_name, last_name, email, phone, address, city, state, postal_code)
VALUES
(1, 'Aarav', 'Sharma', 'aarav@example.com', '9876543210', 'House 12, Sector 15', 'Gurugram', 'Haryana', '122001'),
(2, 'Priya', 'Verma', 'priya@example.com', '9876543211', 'House 24, Sector 10', 'Delhi', 'Delhi', '110001'),
(3, 'Rahul', 'Singh', 'rahul@example.com', '9876543212', 'House 18, Model Town', 'Noida', 'Uttar Pradesh', '201301'),
(4, 'Ananya', 'Gupta', 'ananya@example.com', '9876543213', 'House 35, Civil Lines', 'Jaipur', 'Rajasthan', '302001');

-- =========================================
-- 3. SUPPLIERS
-- =========================================

INSERT INTO suppliers
(supplier_id, supplier_name, email, phone, address, city)
VALUES
(1, 'Tech World Suppliers', 'tech@example.com', '9811111111', 'Industrial Area', 'Delhi'),
(2, 'Book House Distributors', 'books@example.com', '9822222222', 'Market Road', 'Jaipur'),
(3, 'Daily Needs Traders', 'daily@example.com', '9833333333', 'Main Market', 'Noida');

-- =========================================
-- 4. PRODUCTS
-- =========================================

INSERT INTO products
(product_id, category_id, product_name, description, price, sku, status)
VALUES
(1, 1, 'Laptop', '15-inch laptop for daily use', 45000.00, 'ELEC001', 'ACTIVE'),
(2, 1, 'Wireless Mouse', 'Wireless optical mouse', 799.00, 'ELEC002', 'ACTIVE'),
(3, 2, 'DBMS Textbook', 'Database Management Systems textbook', 599.00, 'BOOK001', 'ACTIVE'),
(4, 3, 'Backpack', 'College and travel backpack', 1499.00, 'FASH001', 'ACTIVE'),
(5, 4, 'Water Bottle', 'Stainless steel water bottle', 399.00, 'HOME001', 'ACTIVE');

-- =========================================
-- 5. SUPPLIER PRODUCTS
-- =========================================

INSERT INTO supplier_products
(supplier_id, product_id, supply_price, lead_time_days)
VALUES
(1, 1, 40000.00, 5),
(1, 2, 500.00, 3),
(2, 3, 350.00, 4),
(3, 4, 900.00, 6),
(3, 5, 220.00, 2);

-- =========================================
-- 6. INVENTORY
-- =========================================

INSERT INTO inventory
(product_id, quantity_available, reorder_level)
VALUES
(1, 20, 5),
(2, 100, 15),
(3, 60, 10),
(4, 40, 8),
(5, 75, 10);

-- =========================================
-- 7. ORDERS
-- =========================================

INSERT INTO orders
(order_id, customer_id, order_status, total_amount, shipping_address)
VALUES
(1, 1, 'DELIVERED', 45799.00, 'House 12, Sector 15, Gurugram'),
(2, 2, 'PROCESSING', 1597.00, 'House 24, Sector 10, Delhi'),
(3, 3, 'SHIPPED', 1499.00, 'House 18, Model Town, Noida');

-- =========================================
-- 8. ORDER ITEMS
-- subtotal is generated automatically
-- =========================================

INSERT INTO order_items
(order_id, product_id, quantity, unit_price)
VALUES
(1, 1, 1, 45000.00),
(1, 2, 1, 799.00),
(2, 3, 2, 599.00),
(2, 5, 1, 399.00),
(3, 4, 1, 1499.00);

-- =========================================
-- 9. PAYMENTS
-- =========================================

INSERT INTO payments
(order_id, payment_method, payment_status, amount)
VALUES
(1, 'UPI', 'PAID', 45799.00),
(2, 'CARD', 'PAID', 1597.00),
(3, 'NET_BANKING', 'PAID', 1499.00);

-- =========================================
-- 10. SHIPMENTS
-- =========================================

INSERT INTO shipments
(order_id, tracking_number, courier_name, shipment_date, delivery_date, shipment_status)
VALUES
(1, 'TRK100001', 'BlueDart', NOW() - INTERVAL 5 DAY, NOW() - INTERVAL 2 DAY, 'DELIVERED'),
(2, 'TRK100002', 'Delhivery', NOW() - INTERVAL 1 DAY, NULL, 'PREPARING'),
(3, 'TRK100003', 'DTDC', NOW() - INTERVAL 2 DAY, NULL, 'SHIPPED');

-- =========================================
-- 11. STOCK TRANSACTIONS
-- =========================================

INSERT INTO stock_transactions
(product_id, transaction_type, quantity, remarks)
VALUES
(1, 'IN', 20, 'Initial stock received'),
(2, 'IN', 100, 'Initial stock received'),
(3, 'IN', 60, 'Initial stock received'),
(4, 'IN', 40, 'Initial stock received'),
(5, 'IN', 75, 'Initial stock received');

COMMIT;

-- =========================================
-- VERIFY SAMPLE DATA
-- =========================================

SELECT 'categories' AS table_name, COUNT(*) AS total_records FROM categories
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'suppliers', COUNT(*) FROM suppliers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'supplier_products', COUNT(*) FROM supplier_products
UNION ALL
SELECT 'inventory', COUNT(*) FROM inventory
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'payments', COUNT(*) FROM payments
UNION ALL
SELECT 'shipments', COUNT(*) FROM shipments
UNION ALL
SELECT 'stock_transactions', COUNT(*) FROM stock_transactions;
