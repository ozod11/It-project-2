-- Korzinka Inventory Management Database
-- PostgreSQL-compatible SQL

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_code VARCHAR(50) UNIQUE NOT NULL,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(100),
    unit VARCHAR(30) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE locations (
    location_id SERIAL PRIMARY KEY,
    location_name VARCHAR(150) NOT NULL,
    location_type VARCHAR(20) NOT NULL
        CHECK (location_type IN ('STORE', 'WAREHOUSE')),
    address VARCHAR(255)
);

CREATE TABLE inventory (
    inventory_id SERIAL PRIMARY KEY,
    product_id INT NOT NULL REFERENCES products(product_id),
    location_id INT NOT NULL REFERENCES locations(location_id),
    quantity NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (quantity >= 0),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (product_id, location_id)
);

CREATE TABLE stock_transactions (
    transaction_id SERIAL PRIMARY KEY,
    product_id INT NOT NULL REFERENCES products(product_id),
    location_id INT NOT NULL REFERENCES locations(location_id),
    transaction_type VARCHAR(10) NOT NULL
        CHECK (transaction_type IN ('IN', 'OUT')),
    quantity NUMERIC(12,2) NOT NULL CHECK (quantity > 0),
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    note VARCHAR(255)
);

-- Add a transaction and update stock.
CREATE OR REPLACE FUNCTION process_stock_transaction()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO inventory (product_id, location_id, quantity)
    VALUES (
        NEW.product_id,
        NEW.location_id,
        CASE WHEN NEW.transaction_type = 'IN'
             THEN NEW.quantity
             ELSE -NEW.quantity
        END
    )
    ON CONFLICT (product_id, location_id)
    DO UPDATE SET
        quantity = inventory.quantity +
            CASE WHEN NEW.transaction_type = 'IN'
                 THEN NEW.quantity
                 ELSE -NEW.quantity
            END,
        updated_at = CURRENT_TIMESTAMP;

    IF EXISTS (
        SELECT 1
        FROM inventory
        WHERE product_id = NEW.product_id
          AND location_id = NEW.location_id
          AND quantity < 0
    ) THEN
        RAISE EXCEPTION 'Insufficient stock for product % at location %',
            NEW.product_id, NEW.location_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_process_stock_transaction
AFTER INSERT ON stock_transactions
FOR EACH ROW
EXECUTE FUNCTION process_stock_transaction();

-- Current stock report.
CREATE VIEW current_stock_report AS
SELECT
    p.product_id,
    p.product_code,
    p.product_name,
    l.location_id,
    l.location_name,
    l.location_type,
    i.quantity,
    i.updated_at
FROM inventory i
JOIN products p ON p.product_id = i.product_id
JOIN locations l ON l.location_id = i.location_id;

-- Product movement report.
CREATE VIEW product_movement_report AS
SELECT
    t.transaction_id,
    t.transaction_date,
    p.product_code,
    p.product_name,
    l.location_name,
    t.transaction_type,
    t.quantity,
    t.note
FROM stock_transactions t
JOIN products p ON p.product_id = t.product_id
JOIN locations l ON l.location_id = t.location_id;
