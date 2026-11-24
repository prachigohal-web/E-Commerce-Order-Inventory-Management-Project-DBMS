USE ecommerce_db;

DROP FUNCTION IF EXISTS GetCustomerOrderCount;

DELIMITER //

CREATE FUNCTION GetCustomerOrderCount(
    p_customer_id INT
)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE total_orders INT;

    SELECT COUNT(*)
    INTO total_orders
    FROM orders
    WHERE customer_id = p_customer_id;

    RETURN total_orders;
END //

DELIMITER ;