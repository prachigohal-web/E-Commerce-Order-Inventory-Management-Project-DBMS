
E-Commerce Order & Inventory Management System

ER DIAGRAM

The ER diagram represents 11 entities:
1. Customers
2. Categories
3. Products
4. Suppliers
5. Supplier_Products
6. Inventory
7. Orders
8. Order_Items
9. Payments
10. Shipments
11. Stock_Transactions

Relationships:
Customers to Orders = 1:M
Categories to Products = 1:M
Suppliers to Supplier_Products = 1:M
Products to Supplier_Products = 1:M
Products to Inventory = 1:1
Orders to Order_Items = 1:M
Products to Order_Items = 1:M
Orders to Payments = 1:M
Orders to Shipments = 1:M
Products to Stock_Transactions = 1:M
