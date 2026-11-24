USE ecommerce_db;

-- REPORT 1: Complete Customer Order Details
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    o.order_id,
    o.order_date,
    o.order_status,
    o.total_amount
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
ORDER BY o.order_date DESC;


-- REPORT 2: Best Selling Products
SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_sold,
    SUM(oi.subtotal) AS total_revenue
FROM products p
JOIN order_items oi
ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_sold DESC;


-- REPORT 3: Current Inventory Report
SELECT
    p.product_id,
    p.product_name,
    i.quantity_available,
    i.reorder_level,
    CASE
        WHEN i.quantity_available <= i.reorder_level
        THEN 'LOW STOCK'
        ELSE 'IN STOCK'
    END AS stock_status
FROM products p
JOIN inventory i
ON p.product_id = i.product_id;


-- REPORT 4: Payment Summary
SELECT
    payment_method,
    payment_status,
    COUNT(*) AS total_payments,
    SUM(amount) AS total_amount
FROM payments
GROUP BY payment_method, payment_status;


-- REPORT 5: Customer-wise Spending
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(o.order_id) AS total_orders,
    COALESCE(SUM(o.total_amount), 0) AS total_spending
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, customer_name
ORDER BY total_spending DESC;