-- TASK 7: QUERY OPTIMIZATION 4
-- Query: "Find a customer by their full name"
-- Problem: This is a very common query for a customer service rep.
--          Without an index, the database must perform a "Seq Scan"
--          on the entire Customers table, which is very slow.
-- Solution: Create an index on the 'Customers(name)' column.


-- STEP 1: CREATE THE "PROBLEM"
-- We will delete the index to simulate a poorly performing database.
DROP INDEX IF EXISTS idx_customers_name;



-- STEP 2: SHOW THE "BEFORE" PLAN (THE PROBLEM)
-- You will see a "Seq Scan" on the 'Customers' table.
EXPLAIN ANALYZE
SELECT *
FROM Customers
WHERE name = 'Alice Johnson';



-- STEP 3: APPLY THE FIX
-- This is our proposed indexing strategy.
CREATE INDEX idx_customers_name ON Customers (name);



-- STEP 4: SHOW THE "AFTER" PLAN (THE SOLUTION)
EXPLAIN ANALYZE
SELECT *
FROM Customers
WHERE name = 'Alice Johnson';