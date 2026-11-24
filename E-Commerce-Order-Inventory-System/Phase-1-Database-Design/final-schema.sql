-- ==========================================
-- E-COMMERCE ORDER & INVENTORY MANAGEMENT
-- PHASE 1: FINAL RELATIONAL SCHEMA
-- MySQL 8.0
-- ==========================================

CREATE DATABASE IF NOT EXISTS ecommerce_db;

USE ecommerce_db;

-- 1. CUSTOMERS
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15),
    address VARCHAR(255),
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2. CATEGORIES
CREATE TABLE Categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
) ENGINE=InnoDB;

-- 3. PRODUCTS
CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    product_name VARCHAR(150) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    sku VARCHAR(50) NOT NULL UNIQUE,
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_product_price CHECK (price >= 0),

    CONSTRAINT fk_product_category
    FOREIGN KEY (category_id)
    REFERENCES Categories(category_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 4. SUPPLIERS
CREATE TABLE Suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15),
    address VARCHAR(255),
    city VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 5. SUPPLIER_PRODUCTS
CREATE TABLE Supplier_Products (
    supplier_product_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_id INT NOT NULL,
    product_id INT NOT NULL,
    supply_price DECIMAL(10,2) NOT NULL,
    lead_time_days INT DEFAULT 0,

    CONSTRAINT uq_supplier_product
    UNIQUE (supplier_id, product_id),

    CONSTRAINT chk_supply_price
    CHECK (supply_price >= 0),

    CONSTRAINT chk_lead_time
    CHECK (lead_time_days >= 0),

    CONSTRAINT fk_sp_supplier
    FOREIGN KEY (supplier_id)
    REFERENCES Suppliers(supplier_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,

    CONSTRAINT fk_sp_product
    FOREIGN KEY (product_id)
    REFERENCES Products(product_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 6. INVENTORY
CREATE TABLE Inventory (
    inventory_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL UNIQUE,
    quantity_available INT NOT NULL DEFAULT 0,
    reorder_level INT NOT NULL DEFAULT 10,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT chk_inventory_quantity
    CHECK (quantity_available >= 0),

    CONSTRAINT chk_reorder_level
    CHECK (reorder_level >= 0),

    CONSTRAINT fk_inventory_product
    FOREIGN KEY (product_id)
    REFERENCES Products(product_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 7. ORDERS
CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    order_status ENUM(
        'PENDING',
        'CONFIRMED',
        'PROCESSING',
        'SHIPPED',
        'DELIVERED',
        'CANCELLED'
    ) DEFAULT 'PENDING',
    total_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    shipping_address VARCHAR(255) NOT NULL,

    CONSTRAINT chk_order_amount
    CHECK (total_amount >= 0),

    CONSTRAINT fk_order_customer
    FOREIGN KEY (customer_id)
    REFERENCES Customers(customer_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 8. ORDER_ITEMS
CREATE TABLE Order_Items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,

    subtotal DECIMAL(12,2)
        GENERATED ALWAYS AS (quantity * unit_price) STORED,

    CONSTRAINT uq_order_product
    UNIQUE (order_id, product_id),

    CONSTRAINT chk_item_quantity
    CHECK (quantity > 0),

    CONSTRAINT chk_unit_price
    CHECK (unit_price >= 0),

    CONSTRAINT fk_item_order
    FOREIGN KEY (order_id)
    REFERENCES Orders(order_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,

    CONSTRAINT fk_item_product
    FOREIGN KEY (product_id)
    REFERENCES Products(product_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 9. PAYMENTS
CREATE TABLE Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method ENUM(
        'CASH',
        'UPI',
        'CARD',
        'NET_BANKING',
        'WALLET'
    ) NOT NULL,
    payment_status ENUM(
        'PENDING',
        'PAID',
        'FAILED',
        'REFUNDED'
    ) DEFAULT 'PENDING',
    amount DECIMAL(10,2) NOT NULL,

    CONSTRAINT chk_payment_amount
    CHECK (amount > 0),

    CONSTRAINT fk_payment_order
    FOREIGN KEY (order_id)
    REFERENCES Orders(order_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 10. SHIPMENTS
CREATE TABLE Shipments (
    shipment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    tracking_number VARCHAR(100) NOT NULL UNIQUE,
    courier_name VARCHAR(100),
    shipment_date DATETIME,
    delivery_date DATETIME,
    shipment_status ENUM(
        'PREPARING',
        'SHIPPED',
        'IN_TRANSIT',
        'DELIVERED',
        'RETURNED'
    ) DEFAULT 'PREPARING',

    CONSTRAINT chk_delivery_date
    CHECK (
        delivery_date IS NULL
        OR shipment_date IS NULL
        OR delivery_date >= shipment_date
    ),

    CONSTRAINT fk_shipment_order
    FOREIGN KEY (order_id)
    REFERENCES Orders(order_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 11. STOCK_TRANSACTIONS
CREATE TABLE Stock_Transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    transaction_type ENUM(
        'IN',
        'OUT',
        'ADJUSTMENT'
    ) NOT NULL,
    quantity INT NOT NULL,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    remarks VARCHAR(255),

    CONSTRAINT chk_stock_quantity
    CHECK (quantity > 0),

    CONSTRAINT fk_stock_product
    FOREIGN KEY (product_id)
    REFERENCES Products(product_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ==========================================
-- END OF PHASE 1 FINAL SCHEMA
-- ==========================================
