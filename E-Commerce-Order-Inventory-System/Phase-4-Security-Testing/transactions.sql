
USE ecommerce_db;

-- =====================================
-- TEST 1: ROLLBACK TRANSACTION
-- =====================================

START TRANSACTION;

UPDATE inventory
SET quantity_available = quantity_available - 1
WHERE product_id = 1;

-- Undo the temporary change
ROLLBACK;

-- Verify that original quantity is restored
SELECT product_id, quantity_available
FROM inventory
WHERE product_id = 1;


-- =====================================
-- TEST 2: COMMIT TRANSACTION
-- =====================================

START TRANSACTION;

-- Increase laptop stock by 5
UPDATE inventory
SET quantity_available = quantity_available + 5
WHERE product_id = 1;

-- Record the incoming stock
INSERT INTO stock_transactions
(product_id, transaction_type, quantity, remarks)
VALUES
(1, 'IN', 5, 'New stock received - Phase 4 transaction test');

-- Save both operations permanently
COMMIT;

-- Verify the committed changes
SELECT product_id, quantity_available
FROM inventory
WHERE product_id = 1;

SELECT *
FROM stock_transactions
WHERE remarks = 'New stock received - Phase 4 transaction test';
