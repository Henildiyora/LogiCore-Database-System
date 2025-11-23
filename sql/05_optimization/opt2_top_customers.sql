-- QUERY OPTIMIZATION 2
-- Query: "Top 5 Most Valuable Customers".
-- Problem: The query is slow when the 'Orders' table is large. To
--          group by customer, the database must scan the entire
--          'Orders' table to match orders to customers.
-- Solution: Create an index on the 'Orders(customer_id)' column.


-- CREATE THE PROBLEM
-- We will delete the index to simulate a poorly performing database.
DROP INDEX IF EXISTS orders_customer_id_idx;


-- SHOW THE BEFORE PLAN (THE PROBLEM)
-- You will likely see a "Seq Scan" on 'Orders' being used
-- as part of a "Hash Join".
EXPLAIN ANALYZE
SELECT 
    c.name,
    c.email,
    SUM(o.total_amount) AS total_spent,
    COUNT(o.order_id) AS number_of_orders
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id 
WHERE o.payment_status = 'Paid'
GROUP BY c.customer_id, c.name, c.email
ORDER BY total_spent DESC
LIMIT 5;



-- APPLY THE FIX (OUR IMPROVEMENT)
-- This is our proposed indexing strategy.
CREATE INDEX orders_customer_id_idx ON Orders (customer_id);



-- SHOW THE AFTER PLAN (THE SOLUTION)
-- likely a "Merge Join" or "Nested Loop" using the new index.
-- Take a screenshot and compare the new, lower 'cost' and 'time'.
EXPLAIN ANALYZE
SELECT 
    c.name,
    c.email,
    SUM(o.total_amount) AS total_spent,
    COUNT(o.order_id) AS number_of_orders
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id 
WHERE o.payment_status = 'Paid'
GROUP BY c.customer_id, c.name, c.email
ORDER BY total_spent DESC
LIMIT 5;
