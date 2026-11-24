USE ecommerce_db;

-- INDEX 1: Search orders by status and date
CREATE INDEX idx_orders_status_date
ON orders(order_status, order_date);

-- INDEX 2: Search payments by status and date
CREATE INDEX idx_payments_status_date
ON payments(payment_status, payment_date);

-- INDEX 3: Search stock transactions by product and date
CREATE INDEX idx_stock_product_date
ON stock_transactions(product_id, transaction_date);

-- INDEX 4: Search inventory by available quantity
CREATE INDEX idx_inventory_quantity
ON inventory(quantity_available);

-- Verify created indexes
SHOW INDEX FROM orders;
SHOW INDEX FROM payments;
SHOW INDEX FROM stock_transactions;
SHOW INDEX FROM inventory;