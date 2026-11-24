
USE ecommerce_db;

DROP PROCEDURE IF EXISTS AddNewCustomer;

DELIMITER //

CREATE PROCEDURE AddNewCustomer(
    IN p_first_name VARCHAR(50),
    IN p_last_name VARCHAR(50),
    IN p_email VARCHAR(100),
    IN p_phone VARCHAR(15),
    IN p_address VARCHAR(255),
    IN p_city VARCHAR(50),
    IN p_state VARCHAR(50),
    IN p_postal_code VARCHAR(10)
)
BEGIN
    INSERT INTO customers
    (
        first_name,
        last_name,
        email,
        phone,
        address,
        city,
        state,
        postal_code
    )
    VALUES
    (
        p_first_name,
        p_last_name,
        p_email,
        p_phone,
        p_address,
        p_city,
        p_state,
        p_postal_code
    );
END //

DELIMITER ;

USE ecommerce_db;

DROP PROCEDURE IF EXISTS UpdateOrderTotal;

DELIMITER //

CREATE PROCEDURE UpdateOrderTotal(
    IN p_order_id INT
)
BEGIN
    UPDATE orders
    SET total_amount = (
        SELECT COALESCE(SUM(subtotal), 0)
        FROM order_items
        WHERE order_id = p_order_id
    )
    WHERE order_id = p_order_id;
END //

DELIMITER ;

USE ecommerce_db;

DROP PROCEDURE IF EXISTS UpdateOrderStatus;

DELIMITER //

CREATE PROCEDURE UpdateOrderStatus(
    IN p_order_id INT,
    IN p_new_status VARCHAR(20)
)
BEGIN
    UPDATE orders
    SET order_status = p_new_status
    WHERE order_id = p_order_id;
END //

DELIMITER ;