
from flask import Flask, render_template, request, redirect, url_for
from db import get_db_connection

app = Flask(__name__)


# ---------------- DASHBOARD ----------------

@app.route("/")
def home():
    connection = get_db_connection()

    if not connection:
        return "Database Connection Failed!"

    try:
        cursor = connection.cursor(dictionary=True)

        # Total Active Products
        cursor.execute("""
            SELECT COUNT(*) AS total
            FROM Products
            WHERE status = 'ACTIVE'
        """)
        total_products = cursor.fetchone()["total"]

        # Total Active Customers
        cursor.execute("""
            SELECT COUNT(*) AS total
            FROM Customers
            WHERE status = 'ACTIVE'
        """)
        total_customers = cursor.fetchone()["total"]

        # Total Orders
        cursor.execute("""
            SELECT COUNT(*) AS total
            FROM Orders
        """)
        total_orders = cursor.fetchone()["total"]

        # Total Revenue
        cursor.execute("""
            SELECT COALESCE(SUM(amount), 0) AS total
            FROM Payments
            WHERE payment_status = 'PAID'
        """)
        total_revenue = cursor.fetchone()["total"]

        # Low Stock Items
        cursor.execute("""
            SELECT COUNT(*) AS total
            FROM Inventory
            WHERE quantity_available <= reorder_level
        """)
        low_stock = cursor.fetchone()["total"]

        # Latest 5 Orders
        cursor.execute("""
            SELECT
                o.order_id,
                CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
                o.order_date,
                o.order_status,
                o.total_amount
            FROM Orders o
            JOIN Customers c
                ON o.customer_id = c.customer_id
            ORDER BY o.order_id DESC
            LIMIT 5
        """)
        recent_orders = cursor.fetchall()

        cursor.close()

        return render_template(
            "index.html",
            total_products=total_products,
            total_customers=total_customers,
            total_orders=total_orders,
            total_revenue=total_revenue,
            low_stock=low_stock,
            recent_orders=recent_orders
        )

    except Exception as e:
        return f"Dashboard Error: {e}"

    finally:
        connection.close()

# ---------------- PRODUCTS ----------------

@app.route("/products")
def products():
    connection = get_db_connection()

    if not connection:
        return "Database Connection Failed!"

    try:
        cursor = connection.cursor(dictionary=True)
        cursor.execute("SELECT * FROM Products ORDER BY product_id ASC")
        product_list = cursor.fetchall()
        cursor.close()

        return render_template("products.html", products=product_list)

    except Exception as e:
        return f"Products Error: {e}"

    finally:
        connection.close()


@app.route("/products/add", methods=["GET", "POST"])
def add_product():
    if request.method == "POST":
        category_id = request.form["category_id"]
        print("Submitted Category ID:", category_id)
        product_name = request.form["product_name"]
        description = request.form.get("description", "")
        price = request.form["price"]
        sku = request.form["sku"]
        status = request.form["status"]

        connection = get_db_connection()

        if not connection:
            return "Database Connection Failed!"

        try:
            cursor = connection.cursor()
            cursor.execute("""
                INSERT INTO Products
                (category_id, product_name, description, price, sku, status)
                VALUES (%s, %s, %s, %s, %s, %s)
            """, (category_id, product_name, description, price, sku, status))

            connection.commit()
            cursor.close()

            return redirect(url_for("products"))

        except Exception as e:
            connection.rollback()
            return f"Could not add product: {e}"

        finally:
            connection.close()

    return render_template("product_form.html", product=None)


@app.route("/products/edit/<int:product_id>", methods=["GET", "POST"])
def edit_product(product_id):
    connection = get_db_connection()

    if not connection:
        return "Database Connection Failed!"

    try:
        cursor = connection.cursor(dictionary=True)

        if request.method == "POST":
            cursor.execute("""
                UPDATE Products
                SET category_id=%s, product_name=%s, description=%s,
                    price=%s, sku=%s, status=%s
                WHERE product_id=%s
            """, (
                request.form["category_id"],
                request.form["product_name"],
                request.form.get("description", ""),
                request.form["price"],
                request.form["sku"],
                request.form["status"],
                product_id
            ))

            connection.commit()
            cursor.close()
            return redirect(url_for("products"))

        cursor.execute(
            "SELECT * FROM Products WHERE product_id=%s",
            (product_id,)
        )
        product = cursor.fetchone()
        cursor.close()

        if not product:
            return "Product not found!"

        return render_template("product_form.html", product=product)

    except Exception as e:
        connection.rollback()
        return f"Product Update Error: {e}"

    finally:
        connection.close()


@app.route("/products/delete/<int:product_id>", methods=["POST"])
def delete_product(product_id):
    connection = get_db_connection()

    if not connection:
        return "Database Connection Failed!"

    try:
        cursor = connection.cursor()

        cursor.execute("""
            UPDATE Products
            SET status = 'INACTIVE'
            WHERE product_id = %s
        """, (product_id,))

        connection.commit()
        cursor.close()

        return redirect(url_for("products"))

    except Exception as e:
        connection.rollback()
        return f"Could not deactivate product: {e}"

    finally:
        connection.close()



@app.route("/products/activate/<int:product_id>", methods=["POST"])
def activate_product(product_id):
    connection = get_db_connection()

    if not connection:
        return "Database Connection Failed!"

    try:
        cursor = connection.cursor()

        cursor.execute("""
            UPDATE Products
            SET status = 'ACTIVE'
            WHERE product_id = %s
        """, (product_id,))

        connection.commit()
        cursor.close()

        return redirect(url_for("products"))

    except Exception as e:
        connection.rollback()
        return f"Could not activate product: {e}"

    finally:
        connection.close()


# ---------------- CUSTOMERS ----------------

@app.route("/customers")
def customers():
    connection = get_db_connection()

    if not connection:
        return "Database Connection Failed!"

    try:
        cursor = connection.cursor(dictionary=True)
        cursor.execute("SELECT * FROM Customers ORDER BY customer_id ASC")
        customer_list = cursor.fetchall()
        cursor.close()

        return render_template("customers.html", customers=customer_list)

    except Exception as e:
        return f"Customers Error: {e}"

    finally:
        connection.close()


@app.route("/customers/add", methods=["GET", "POST"])
def add_customer():
    if request.method == "POST":
        connection = get_db_connection()

        if not connection:
            return "Database Connection Failed!"

        try:
            cursor = connection.cursor()
            cursor.execute("""
                INSERT INTO Customers
                (first_name, last_name, email, phone, address,
                 city, state, postal_code)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """, (
                request.form["first_name"],
                request.form["last_name"],
                request.form["email"],
                request.form.get("phone", ""),
                request.form.get("address", ""),
                request.form.get("city", ""),
                request.form.get("state", ""),
                request.form.get("postal_code", "")
            ))

            connection.commit()
            cursor.close()
            return redirect(url_for("customers"))

        except Exception as e:
            connection.rollback()
            return f"Could not add customer: {e}"

        finally:
            connection.close()

    return render_template("customer_form.html", customer=None)


@app.route("/customers/edit/<int:customer_id>", methods=["GET", "POST"])
def edit_customer(customer_id):
    connection = get_db_connection()

    if not connection:
        return "Database Connection Failed!"

    try:
        cursor = connection.cursor(dictionary=True)

        if request.method == "POST":
            cursor.execute("""
                UPDATE Customers
                SET first_name=%s, last_name=%s, email=%s,
                    phone=%s, address=%s, city=%s,
                    state=%s, postal_code=%s
                WHERE customer_id=%s
            """, (
                request.form["first_name"],
                request.form["last_name"],
                request.form["email"],
                request.form.get("phone", ""),
                request.form.get("address", ""),
                request.form.get("city", ""),
                request.form.get("state", ""),
                request.form.get("postal_code", ""),
                customer_id
            ))

            connection.commit()
            cursor.close()
            return redirect(url_for("customers"))

        cursor.execute(
            "SELECT * FROM Customers WHERE customer_id=%s",
            (customer_id,)
        )
        customer = cursor.fetchone()
        cursor.close()

        if not customer:
            return "Customer not found!"

        return render_template("customer_form.html", customer=customer)

    except Exception as e:
        connection.rollback()
        return f"Customer Update Error: {e}"

    finally:
        connection.close()


@app.route("/customers/delete/<int:customer_id>", methods=["POST"])
def delete_customer(customer_id):
    connection = get_db_connection()

    if not connection:
        return "Database Connection Failed!"

    try:
        cursor = connection.cursor()
        cursor.execute(
            "DELETE FROM Customers WHERE customer_id=%s",
            (customer_id,)
        )
        connection.commit()
        cursor.close()
        return redirect(url_for("customers"))

    except Exception as e:
        connection.rollback()
        return f"Could not delete customer. This customer may have orders: {e}"

    finally:
        connection.close()


# ---------------- DEACTIVATE CUSTOMER ----------------

@app.route("/customers/deactivate/<int:customer_id>", methods=["POST"])
def deactivate_customer(customer_id):
    connection = get_db_connection()

    if not connection:
        return "Database Connection Failed!"

    try:
        cursor = connection.cursor()

        cursor.execute("""
            UPDATE Customers
            SET status = 'INACTIVE'
            WHERE customer_id = %s
        """, (customer_id,))

        connection.commit()
        cursor.close()

        return redirect(url_for("customers"))

    except Exception as e:
        connection.rollback()
        return f"Could not deactivate customer: {e}"

    finally:
        connection.close()


# ---------------- ACTIVATE CUSTOMER ----------------

@app.route("/customers/activate/<int:customer_id>", methods=["POST"])
def activate_customer(customer_id):
    connection = get_db_connection()

    if not connection:
        return "Database Connection Failed!"

    try:
        cursor = connection.cursor()

        cursor.execute("""
            UPDATE Customers
            SET status = 'ACTIVE'
            WHERE customer_id = %s
        """, (customer_id,))

        connection.commit()
        cursor.close()

        return redirect(url_for("customers"))

    except Exception as e:
        connection.rollback()
        return f"Could not activate customer: {e}"

    finally:
        connection.close()


# ---------------- REVENUE & PAYMENTS ----------------

@app.route("/revenue")
def revenue():
    connection = get_db_connection()

    if not connection:
        return "Database Connection Failed!"

    try:
        cursor = connection.cursor(dictionary=True)

        cursor.execute("""
            SELECT COALESCE(SUM(amount), 0) AS total_revenue
            FROM Payments
            WHERE payment_status='PAID'
        """)
        total_revenue = cursor.fetchone()["total_revenue"]

        cursor.execute("""
            SELECT COUNT(*) AS total_payments
            FROM Payments
        """)
        total_payments = cursor.fetchone()["total_payments"]

        cursor.execute("""
            SELECT *
            FROM Payments
            ORDER BY payment_date DESC
        """)
        payment_list = cursor.fetchall()

        cursor.close()

        return render_template(
            "revenue.html",
            total_revenue=total_revenue,
            total_payments=total_payments,
            payments=payment_list
        )

    except Exception as e:
        return f"Revenue Error: {e}"

    finally:
        connection.close()

        # ---------------- UPDATE PAYMENT STATUS ----------------

@app.route("/payments/update-status/<int:payment_id>", methods=["POST"])
def update_payment_status(payment_id):

    connection = get_db_connection()

    if not connection:
        return "Database Connection Failed!"

    try:
        new_status = request.form.get("payment_status")

        allowed_statuses = [
            "PENDING",
            "PAID",
            "FAILED",
            "REFUNDED"
        ]

        if new_status not in allowed_statuses:
            return "Invalid Payment Status!"

        cursor = connection.cursor()

        cursor.execute("""
            UPDATE Payments
            SET payment_status = %s
            WHERE payment_id = %s
        """, (new_status, payment_id))

        connection.commit()
        cursor.close()

        return redirect(url_for("revenue"))

    except Exception as e:
        connection.rollback()
        return f"Payment Status Update Error: {e}"

    finally:
        connection.close()

# ---------------- INVENTORY ----------------

@app.route("/inventory")
def inventory():
    connection = get_db_connection()

    if not connection:
        return "Database Connection Failed!"

    try:
        cursor = connection.cursor(dictionary=True)

        cursor.execute("""
            SELECT
                i.inventory_id,
                p.product_name,
                i.quantity_available,
                i.reorder_level,
                i.last_updated
            FROM Inventory i
            JOIN Products p
                ON i.product_id = p.product_id
            ORDER BY i.inventory_id ASC
        """)

        inventory_list = cursor.fetchall()
        cursor.close()

        return render_template(
            "inventory.html",
            inventory=inventory_list
        )

    except Exception as e:
        return f"Inventory Error: {e}"

    finally:
        connection.close()


# ---------------- UPDATE INVENTORY STOCK ----------------

@app.route("/inventory/update/<int:inventory_id>", methods=["POST"])
def update_inventory_stock(inventory_id):

    connection = get_db_connection()

    if not connection:
        return "Database Connection Failed!"

    try:
        cursor = connection.cursor(dictionary=True)

        action = request.form.get("action")
        quantity = request.form.get("quantity")

        if action not in ["ADD", "SET"]:
            return "Invalid stock update option!"

        try:
            quantity = int(quantity)
        except (TypeError, ValueError):
            return "Please enter a valid quantity!"

        if quantity < 0:
            return "Quantity cannot be negative!"

        if action == "ADD" and quantity == 0:
            return "Please enter a quantity greater than zero!"

        cursor.execute("""
            SELECT inventory_id
            FROM Inventory
            WHERE inventory_id = %s
            FOR UPDATE
        """, (inventory_id,))

        item = cursor.fetchone()

        if not item:
            connection.rollback()
            return "Inventory record not found!"

        if action == "ADD":

            cursor.execute("""
                UPDATE Inventory
                SET quantity_available = quantity_available + %s,
                    last_updated = CURRENT_TIMESTAMP
                WHERE inventory_id = %s
            """, (quantity, inventory_id))

        elif action == "SET":

            cursor.execute("""
                UPDATE Inventory
                SET quantity_available = %s,
                    last_updated = CURRENT_TIMESTAMP
                WHERE inventory_id = %s
            """, (quantity, inventory_id))

        connection.commit()
        cursor.close()

        return redirect(url_for("inventory"))

    except Exception as e:
        connection.rollback()
        return f"Stock Update Error: {e}"

    finally:
        connection.close()


# ---------------- ORDERS ----------------

@app.route("/orders")
def orders():
    connection = get_db_connection()

    if not connection:
        return "Database Connection Failed!"

    try:
        cursor = connection.cursor(dictionary=True)

        cursor.execute("""
            SELECT
                o.order_id,
                CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
                o.order_date,
                o.order_status,
                o.total_amount,
                o.shipping_address
            FROM Orders o
            JOIN Customers c
                ON o.customer_id = c.customer_id
            ORDER BY o.order_date ASC
        """)

        order_list = cursor.fetchall()
        cursor.close()

        return render_template(
            "orders.html",
            orders=order_list
        )

    except Exception as e:
        return f"Orders Error: {e}"

    finally:
        connection.close()


# ---------------- ADD ORDER ----------------

@app.route("/orders/add", methods=["GET", "POST"])
def add_order():

    connection = get_db_connection()

    if not connection:
        return "Database Connection Failed!"

    try:
        cursor = connection.cursor(dictionary=True)

        # Show form
        if request.method == "GET":

            cursor.execute("""
                SELECT customer_id, first_name, last_name
                FROM Customers
                WHERE status = 'ACTIVE'
                ORDER BY first_name
            """)
            customer_list = cursor.fetchall()

            cursor.execute("""
                SELECT
                    p.product_id,
                    p.product_name,
                    p.price,
                    i.quantity_available
                FROM Products p
                JOIN Inventory i
                    ON p.product_id = i.product_id
                WHERE p.status = 'ACTIVE'
                ORDER BY p.product_name
            """)
            product_list = cursor.fetchall()

            cursor.close()

            return render_template(
                "add_order.html",
                customers=customer_list,
                products=product_list
            )

        # Save order
        customer_id = request.form.get("customer_id")
        product_id = request.form.get("product_id")
        quantity = int(request.form.get("quantity", 0))
        shipping_address = request.form.get("shipping_address", "").strip()

        if quantity <= 0:
            return "Quantity must be greater than zero!"

        if not shipping_address:
            return "Shipping address is required!"

        # Check active customer
        cursor.execute("""
            SELECT customer_id
            FROM Customers
            WHERE customer_id = %s AND status = 'ACTIVE'
        """, (customer_id,))

        if not cursor.fetchone():
            connection.rollback()
            return "Invalid or inactive customer!"

        # Check product and stock
        cursor.execute("""
            SELECT p.price, i.quantity_available
            FROM Products p
            JOIN Inventory i
                ON p.product_id = i.product_id
            WHERE p.product_id = %s
              AND p.status = 'ACTIVE'
            FOR UPDATE
        """, (product_id,))

        product = cursor.fetchone()

        if not product:
            connection.rollback()
            return "Invalid or inactive product!"

        if quantity > product["quantity_available"]:
            connection.rollback()
            return "Insufficient stock available!"

        # Calculate total
        total_amount = product["price"] * quantity

        # Insert order
        cursor.execute("""
            INSERT INTO Orders
                (customer_id, total_amount, shipping_address)
            VALUES (%s, %s, %s)
        """, (customer_id, total_amount, shipping_address))

        order_id = cursor.lastrowid

        # Insert order item
        cursor.execute("""
            INSERT INTO Order_Items
                (order_id, product_id, quantity, unit_price)
            VALUES (%s, %s, %s, %s)
        """, (
            order_id,
            product_id,
            quantity,
            product["price"]
        ))

        # Update inventory
        cursor.execute("""
            UPDATE Inventory
            SET quantity_available = quantity_available - %s
            WHERE product_id = %s
        """, (quantity, product_id))

        connection.commit()
        cursor.close()

        return redirect(url_for("orders"))

    except Exception as e:
        connection.rollback()
        return f"Add Order Error: {e}"

    finally:
        connection.close()



# ---------------- UPDATE ORDER STATUS ----------------

@app.route("/orders/update-status/<int:order_id>", methods=["POST"])
def update_order_status(order_id):

    connection = get_db_connection()

    if not connection:
        return "Database Connection Failed!"

    try:
        new_status = request.form.get("order_status")

        allowed_statuses = [
            "PENDING",
            "CONFIRMED",
            "PROCESSING",
            "SHIPPED",
            "DELIVERED",
            "CANCELLED"
        ]

        if new_status not in allowed_statuses:
            return "Invalid Order Status!"

        cursor = connection.cursor(dictionary=True)

        cursor.execute("""
            SELECT order_status
            FROM Orders
            WHERE order_id = %s
            FOR UPDATE
        """, (order_id,))

        order = cursor.fetchone()

        if not order:
            connection.rollback()
            return "Order not found!"

        if order["order_status"] == "CANCELLED":
            connection.rollback()
            return "Cancelled orders cannot be changed!"

        # Restore stock when an order is cancelled
        if new_status == "CANCELLED":

            cursor.execute("""
                SELECT product_id, quantity
                FROM Order_Items
                WHERE order_id = %s
            """, (order_id,))

            items = cursor.fetchall()

            for item in items:
                cursor.execute("""
                    UPDATE Inventory
                    SET quantity_available = quantity_available + %s
                    WHERE product_id = %s
                """, (item["quantity"], item["product_id"]))

        cursor.execute("""
            UPDATE Orders
            SET order_status = %s
            WHERE order_id = %s
        """, (new_status, order_id))

        connection.commit()
        cursor.close()

        return redirect(url_for("orders"))

    except Exception as e:
        connection.rollback()
        return f"Order Status Update Error: {e}"

    finally:
        connection.close()


if __name__ == "__main__":
    app.run(debug=True)


