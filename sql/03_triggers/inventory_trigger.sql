-- TASK 6: TRANSACTION & TRIGGER (Inventory Validation)
-- This file creates the function and trigger for the main task.
-- Scenario: When an order status is set to 'Shipped', this trigger
-- will fire to check inventory. If stock is insufficient, it will
-- raise an exception, which aborts the transaction and prevents
-- the order from being marked as 'Shipped'.

-- Create the function that will be executed by the trigger.
CREATE OR REPLACE FUNCTION check_and_update_inventory()
RETURNS TRIGGER AS $$
DECLARE
    -- 'rec' will hold each row from the OrderItems loop
    rec RECORD;
    -- 'current_stock' will hold the quantity found in the inventory
    current_stock INTEGER;
BEGIN
    -- We only care if the status is being changed TO 'Shipped'.
    -- We check NEW.status, which is the value the row is about to have.
    IF NEW.status = 'Shipped' AND OLD.status IS DISTINCT FROM 'Shipped' THEN
        
        -- Loop through each item associated with the order being updated
        FOR rec IN
            SELECT product_id, quantity
            FROM OrderItems
            WHERE order_id = NEW.order_id
        LOOP
            -- Check the current stock for this specific product at the fulfillment warehouse of the order
            SELECT quantity_on_hand INTO current_stock
            FROM Inventory
            WHERE product_id = rec.product_id AND warehouse_id = NEW.fulfillment_warehouse_id
            FOR UPDATE;

            -- FAILURE HANDLING
            -- If stock is not sufficient or doesn't exist, raise an exception.
            -- This stops the function and aborts the entire transaction.
            IF current_stock IS NULL OR current_stock < rec.quantity THEN
                RAISE EXCEPTION 'Cannot ship order %: Insufficient stock for product % at warehouse % (Need %, Have %).',
                    NEW.order_id, rec.product_id, NEW.fulfillment_warehouse_id, rec.quantity, COALESCE(current_stock, 0);
            END IF;

            -- THIS IS THE SUCCESS PATH
            -- If we are here, stock is sufficient. Update the inventory.
            UPDATE Inventory
            SET quantity_on_hand = quantity_on_hand - rec.quantity
            WHERE product_id = rec.product_id AND warehouse_id = NEW.fulfillment_warehouse_id;

        END LOOP;
    END IF;

    -- If the function completes without error, return NEW to allow
    -- the original UPDATE (setting status to 'Shipped') to proceed.
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Create the trigger and attach it to the 'Orders' table.
-- This tells the database: "Before any UPDATE on 'Orders', for each row,
-- execute the 'check_and_update_inventory' function."

-- We drop the trigger first to ensure we can re-run this script.
DROP TRIGGER IF EXISTS trigger_inventory_check ON Orders;

CREATE TRIGGER trigger_inventory_check
BEFORE UPDATE ON Orders
FOR EACH ROW
EXECUTE FUNCTION check_and_update_inventory();



-- TASK 6: Transaction with Failure Handling using a Trigger
-- This version 100% matches what the professor asked for.

-- 1. Make sure your first trigger exists (the inventory one from your first file)
-- (You already have it from phase2_task6_triggers.sql)

-- 2. TEST TRANSACTION
-- We will try to: (1) Ship an order AND (2) Add a tracking event in ONE transaction.
-- If stock is too low, the whole transaction will fail and roll back.

-- First, prepare data (run once)
UPDATE Inventory SET quantity_on_hand = 1 
WHERE product_id = '33b003f3-0484-4a1e-b8f5-590566384273' 
  AND warehouse_id = 'bada3cd8-59f6-4534-b949-042137dacabf';

-- FAILURE CASE (take screenshot of the whole block + error message)
BEGIN;
    -- Operation 1
    UPDATE Orders SET status = 'Shipped' 
    WHERE order_id = '38e6302d-f452-4ebb-bced-96c0f0e92a5d';
    
    -- Operation 2
    INSERT INTO ShipmentTrackingHistory (tracking_history_id, shipment_id, status_description, "timestamp")
    VALUES (gen_random_uuid(), 
            (SELECT shipment_id FROM Shipments WHERE order_id = '38e6302d-f452-4ebb-bced-96c0f0e92a5d'),
            'Picked up by carrier', NOW());
COMMIT;

ROLLBACK;

-- SUCCESS CASE (take screenshot of the whole block + "COMMIT" message)
BEGIN;
    -- First fix the stock
    UPDATE Inventory SET quantity_on_hand = 100 
    WHERE product_id = '33b003f3-0484-4a1e-b8f5-590566384273' 
      AND warehouse_id = 'bada3cd8-59f6-4534-b949-042137dacabf';
    
    -- Operation 1
    UPDATE Orders SET status = 'Shipped' 
    WHERE order_id = '38e6302d-f452-4ebb-bced-96c0f0e92a5d';
    
    -- Operation 2
    INSERT INTO ShipmentTrackingHistory (tracking_history_id, shipment_id, status_description, "timestamp")
    VALUES (gen_random_uuid(), 
            (SELECT shipment_id FROM Shipments WHERE order_id = '38e6302d-f452-4ebb-bced-96c0f0e92a5d'),
            'Picked up by carrier', NOW());
COMMIT;

-- Verify success (take screenshot)
SELECT status FROM Orders WHERE order_id = '38e6302d-f452-4ebb-bced-96c0f0e92a5d';
SELECT COUNT(*) FROM ShipmentTrackingHistory 
WHERE shipment_id = (SELECT shipment_id FROM Shipments WHERE order_id = '38e6302d-f452-4ebb-bced-96c0f0e92a5d');

-- Cleanup (optional, for next run)
UPDATE Orders SET status = 'Placed' WHERE order_id = '38e6302d-f452-4ebb-bced-96c0f0e92a5d';
DELETE FROM ShipmentTrackingHistory WHERE status_description = 'Picked up by carrier';


-- -- TESTING TRIGGER 1 (check_and_update_inventory)
-- -- GOAL: Prove that an order cannot be 'Shipped' if stock is too low.

-- -- Step 1. Find a Target Order to Test
-- -- Run this query to find an order that is 'Placed' and its items.
-- -- We need the order_id, product_id, fulfillment_warehouse_id, and quantity.

-- SELECT
--     o.order_id,
--     o.status AS order_status,
--     oi.product_id,
--     oi.quantity AS quantity_needed,
--     o.fulfillment_warehouse_id,
--     (SELECT quantity_on_hand FROM Inventory i WHERE i.product_id = oi.product_id AND i.warehouse_id = o.fulfillment_warehouse_id) AS current_stock
-- FROM Orders o
-- JOIN OrderItems oi ON o.order_id = oi.order_id
-- WHERE o.status = 'Placed'
--   AND o.fulfillment_warehouse_id IS NOT NULL
-- LIMIT 5;

-- -- Example result:
-- -- order_id: '38e6302d-f452-4ebb-bced-96c0f0e92a5d'
-- -- product_id: '33b003f3-0484-4a1e-b8f5-590566384273'
-- -- quantity_needed: 3
-- -- fulfillment_warehouse_id: 'bada3cd8-59f6-4534-b949-042137dacabf'
-- -- current_stock: 150


-- -- Step 1.2: FAILURE CASE (Insufficient Stock)
-- -- We will manually set the stock to a low number, then try to ship.

-- -- 1. Manually set stock to be less than quantity_needed
-- UPDATE Inventory
-- SET quantity_on_hand = 1
-- WHERE product_id = '33b003f3-0484-4a1e-b8f5-590566384273' AND warehouse_id = 'bada3cd8-59f6-4534-b949-042137dacabf';

-- -- 2. ACTION: Try to ship the order. This will FAIL.
-- UPDATE Orders
-- SET status = 'Shipped'
-- WHERE order_id = '38e6302d-f452-4ebb-bced-96c0f0e92a5d';


-- -- 3. CLEANUP: Revert the stock change
-- UPDATE Inventory
-- SET quantity_on_hand = 100
-- WHERE product_id = '33b003f3-0484-4a1e-b8f5-590566384273' AND warehouse_id = 'bada3cd8-59f6-4534-b949-042137dacabf';


-- -- -------------------------------------------------------------------
-- -- Step 1.3: SUCCESS CASE (Sufficient Stock)
-- -- -------------------------------------------------------------------
-- -- We will ensure stock is high enough, ship, and verify the new stock.

-- -- 1. SETUP: Manually set stock to a high number
-- -- match column order to the Inventory PK (warehouse_id, product_id)
-- INSERT INTO Inventory (warehouse_id, product_id, quantity_on_hand)
-- VALUES ('bada3cd8-59f6-4534-b949-042137dacabf', '33b003f3-0484-4a1e-b8f5-590566384273', 100)
-- ON CONFLICT (warehouse_id, product_id)
-- DO UPDATE SET quantity_on_hand = 100;

-- SELECT *
-- FROM Inventory
-- WHERE product_id = '33b003f3-0484-4a1e-b8f5-590566384273' AND warehouse_id = 'bada3cd8-59f6-4534-b949-042137dacabf';

-- -- 2. ACTION: Try to ship the order. This will SUCCEED.
-- UPDATE Orders
-- SET status = 'Shipped'
-- WHERE order_id = '38e6302d-f452-4ebb-bced-96c0f0e92a5d';


-- -- 3. VERIFICATION: Check the inventory.
-- SELECT quantity_on_hand
-- FROM Inventory
-- WHERE product_id = '33b003f3-0484-4a1e-b8f5-590566384273' AND warehouse_id = 'bada3cd8-59f6-4534-b949-042137dacabf';


-- -- 4. CLEANUP: Revert the order status and stock for future tests
-- UPDATE Orders
-- SET status = 'Placed'
-- WHERE order_id = '38e6302d-f452-4ebb-bced-96c0f0e92a5d';

-- UPDATE Inventory
-- SET quantity_on_hand = 100
-- WHERE product_id = '33b003f3-0484-4a1e-b8f5-590566384273' AND warehouse_id = 'bada3cd8-59f6-4534-b949-042137dacabf';