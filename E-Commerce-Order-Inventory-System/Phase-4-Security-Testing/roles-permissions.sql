
USE ecommerce_db;

-- 1. CREATE DATABASE ROLES
CREATE ROLE IF NOT EXISTS 'ecommerce_admin';
CREATE ROLE IF NOT EXISTS 'ecommerce_manager';
CREATE ROLE IF NOT EXISTS 'ecommerce_customer';

-- 2. ADMIN PERMISSIONS
GRANT ALL PRIVILEGES
ON ecommerce_db.*
TO 'ecommerce_admin';

-- 3. MANAGER PERMISSIONS
GRANT SELECT
ON ecommerce_db.*
TO 'ecommerce_manager';

GRANT INSERT, UPDATE
ON ecommerce_db.orders
TO 'ecommerce_manager';

GRANT INSERT, UPDATE
ON ecommerce_db.order_items
TO 'ecommerce_manager';

GRANT INSERT, UPDATE
ON ecommerce_db.inventory
TO 'ecommerce_manager';

GRANT INSERT, UPDATE
ON ecommerce_db.products
TO 'ecommerce_manager';

-- 4. CUSTOMER PERMISSIONS
GRANT SELECT
ON ecommerce_db.categories
TO 'ecommerce_customer';

GRANT SELECT
ON ecommerce_db.products
TO 'ecommerce_customer';

GRANT SELECT
ON ecommerce_db.inventory
TO 'ecommerce_customer';

-- 5. CREATE TEST USERS
CREATE USER IF NOT EXISTS 'ecom_admin'@'localhost'
IDENTIFIED BY 'Admin@12345';

CREATE USER IF NOT EXISTS 'ecom_manager'@'localhost'
IDENTIFIED BY 'Manager@12345';

CREATE USER IF NOT EXISTS 'ecom_customer'@'localhost'
IDENTIFIED BY 'Customer@12345';

-- 6. ASSIGN ROLES TO USERS
GRANT 'ecommerce_admin' TO 'ecom_admin'@'localhost';

GRANT 'ecommerce_manager' TO 'ecom_manager'@'localhost';

GRANT 'ecommerce_customer' TO 'ecom_customer'@'localhost';

-- 7. SET DEFAULT ROLES
SET DEFAULT ROLE ALL TO 'ecom_admin'@'localhost';

SET DEFAULT ROLE ALL TO 'ecom_manager'@'localhost';

SET DEFAULT ROLE ALL TO 'ecom_customer'@'localhost';
