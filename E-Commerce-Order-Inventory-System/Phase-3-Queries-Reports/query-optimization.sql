USE ecommerce_db;

-- QUERY 1: Search orders by status and date
EXPLAIN
SELECT *
FROM orders
WHERE order_status = 'DELIVERED'
AND order_date >= '2026-01-01';


-- QUERY 2: Search payments by status and date
EXPLAIN
SELECT *
FROM payments
WHERE payment_status = 'PAID'
AND payment_date >= '2026-01-01';


-- QUERY 3: Search stock transactions by product and date
EXPLAIN
SELECT *
FROM stock_transactions
WHERE product_id = 1
AND transaction_date >= '2026-01-01';


-- QUERY 4: Search inventory by quantity
EXPLAIN
SELECT *
FROM inventory
WHERE quantity_available <= 20;