CREATE DATABASE IF NOT EXISTS opt_db;
USE opt_db;

CREATE TABLE IF NOT EXISTS opt_clients (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    surname VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    address TEXT NOT NULL,
    status ENUM('active', 'inactive') NOT NULL
);

CREATE TABLE IF NOT EXISTS opt_products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    product_category ENUM('Category1', 'Category2', 'Category3', 'Category4', 'Category5') NOT NULL,
    description TEXT
);

CREATE TABLE IF NOT EXISTS opt_orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    order_date DATE NOT NULL,
    client_id CHAR(36),
    product_id INT,
    FOREIGN KEY (client_id) REFERENCES opt_clients(id),
    FOREIGN KEY (product_id) REFERENCES opt_products(product_id)
);

EXPLAIN ANALYZE SELECT opt_clients.name, opt_clients.surname, 
	   opt_products.product_name, opt_products.product_category, 
	   opt_orders.order_date, 
	   (SELECT COUNT(*) FROM opt_orders WHERE opt_orders.client_id = opt_clients.id) AS total_orders
FROM opt_orders
JOIN opt_clients ON opt_orders.client_id = opt_clients.id
JOIN opt_products ON opt_orders.product_id = opt_products.product_id
WHERE opt_products.product_category = 'Category1' AND opt_clients.status = 'active';
  
CREATE INDEX idx_orders_client_id ON opt_orders(client_id);
CREATE INDEX idx_orders_product_id ON opt_orders(product_id);
CREATE INDEX idx_clients_id_status ON opt_clients(id, status);
CREATE INDEX idx_products_id_category ON opt_products(product_id, product_category);

EXPLAIN ANALYZE WITH client_order_counts AS (SELECT client_id, COUNT(*) AS total_orders
FROM opt_orders
GROUP BY client_id)

SELECT opt_clients.name, opt_clients.surname,
       opt_products.product_name, opt_products.product_category,
       opt_orders.order_date, client_order_counts.total_orders
FROM opt_orders
JOIN opt_clients ON opt_orders.client_id = opt_clients.id
JOIN opt_products ON opt_orders.product_id = opt_products.product_id
JOIN client_order_counts ON opt_clients.id = client_order_counts.client_id
WHERE opt_products.product_category = 'Category1' AND opt_clients.status = 'active';




