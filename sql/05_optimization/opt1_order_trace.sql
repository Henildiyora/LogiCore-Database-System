-- QUERY OPTIMIZATION 1
-- Query: "Full Order Trace".
-- Problem: The query is slow when the database grows because it must
--          scan the entire 'Shipments' table to find the matching 'order_id'.
-- Solution: Create an index on the 'Shipments(order_id)' column.


-- CREATE THE PROBLEM
-- We will delete the index to simulate a poorly performing database.
DROP INDEX IF EXISTS shipments_order_id_idx;


-- SHOW THE BEFORE PLAN (THE PROBLEM)
-- You will see a Sequential Scan on the 'Shipments' table.
EXPLAIN ANALYZE
SELECT
    c.name AS customer_name,
    o.order_id,
    p.name AS product_name,
    s.tracking_number,
    sc.name AS carrier_name
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN OrderItems oi ON o.order_id = oi.order_id
JOIN Products p ON oi.product_id = p.product_id
JOIN Shipments s ON o.order_id = s.order_id
JOIN ShippingCarriers sc ON s.carrier_id = sc.carrier_id
WHERE o.order_id = '1283686e-d496-42b8-8cfe-2627a0abcc19';


-- APPLY THE FIX (OUR IMPROVEMENT)
-- This is our proposed indexing strategy.
CREATE INDEX shipments_order_id_idx ON Shipments (order_id);


-- SHOW THE AFTER PLAN (THE SOLUTION)
-- Now, the Execution Plan will show a fast "Index Scan".
-- Take a screenshot and compare the new, lower 'cost' and 'time'.
EXPLAIN ANALYZE
SELECT
    c.name AS customer_name,
    o.order_id,
    p.name AS product_name,
    s.tracking_number,
    sc.name AS carrier_name
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN OrderItems oi ON o.order_id = oi.order_id
JOIN Products p ON oi.product_id = p.product_id
JOIN Shipments s ON o.order_id = s.order_id 
JOIN ShippingCarriers sc ON s.carrier_id = sc.carrier_id
WHERE o.order_id = '1283686e-d496-42b8-8cfe-2627a0abcc19';
