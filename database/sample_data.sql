-- Sample data for demonstration

INSERT INTO products (product_code, product_name, category, unit)
VALUES
('P001', 'Example Product 1', 'Food', 'piece'),
('P002', 'Example Product 2', 'Drinks', 'piece');

INSERT INTO locations (location_name, location_type, address)
VALUES
('Korzinka Store 1', 'STORE', 'Example address'),
('Korzinka Warehouse 1', 'WAREHOUSE', 'Example warehouse address');

-- Incoming stock
INSERT INTO stock_transactions
(product_id, location_id, transaction_type, quantity, note)
VALUES
(1, 1, 'IN', 100, 'Initial stock'),
(2, 1, 'IN', 50, 'Initial stock');

-- Outgoing stock
INSERT INTO stock_transactions
(product_id, location_id, transaction_type, quantity, note)
VALUES
(1, 1, 'OUT', 10, 'Product movement');

-- Reports
SELECT * FROM current_stock_report;
SELECT * FROM product_movement_report;
