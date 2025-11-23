-- QUERY OPTIMIZATION 3
-- Query: "Low Inventory Alert".
-- Problem: The 'Inventory' table is a large "fact" table. When
--          joining it with 'Products', the database must scan the
--          entire table to find matching 'product_id's.
-- Solution: Create an index on the 'Inventory(product_id)' column.


-- CREATE THE PROBLEM
-- We will delete the index to simulate a poorly performing database.
DROP INDEX IF EXISTS inventory_product_id_idx;

-- SHOW THE BEFORE PLAN (THE PROBLEM)
-- You will likely see a "Seq Scan" or "Hash Join" that uses
-- a sequential scan on the 'Inventory' table.
EXPLAIN ANALYZE
SELECT
    p.name AS product_name,
    p.sku,
    w.location_name,
    i.quantity_on_hand,
    i.reorder_level
FROM Products p
JOIN Inventory i ON p.product_id = i.product_id 
JOIN Warehouses w ON i.warehouse_id = w.warehouse_id
WHERE 
    i.quantity_on_hand < i.reorder_level;

-- STEP 3: APPLY THE FIX
-- This is our proposed indexing strategy.
CREATE INDEX inventory_product_id_idx ON Inventory (product_id);


-- SHOW THE AFTER PLAN (THE SOLUTION)
-- using the new index on 'Inventory'.
EXPLAIN ANALYZE
SELECT
    p.name AS product_name,
    p.sku,
    w.location_name,
    i.quantity_on_hand,
    i.reorder_level
FROM Products p
JOIN Inventory i ON p.product_id = i.product_id 
JOIN Warehouses w ON i.warehouse_id = w.warehouse_id
WHERE 
    i.quantity_on_hand < i.reorder_level;

