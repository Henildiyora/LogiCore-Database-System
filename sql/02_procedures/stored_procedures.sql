-- 1. 1-2 queries for inserting, deleting, and updating.

-- Query 1 (INSERT 1)
-- Add a new customer who just registered.
INSERT INTO Customers(customer_id, name, email, phone, address_line1, city, state, postal_code, country, registered_at, vip_flag)
VALUES (
    gen_random_uuid(), 
    'ABC New Customer2', 
    'ABCNewCustomer2@example.com', 
    '535-0101', 
    '113 Maple St', 
    'buffalo', 
    'NY', 
    '123235', 
    'USA', 
    NOW(), 
    FALSE
);

SELECT * FROM Customers
WHERE email = 'ABCNewCustomer@example.com';

-- Query 2 (INSERT 2)
-- Add a new product to the company's product catalog.
INSERT INTO Products (product_id, sku, name, description, category, unit_price, weight_kg, dimensions_cm, active_flag, created_at)
VALUES (
    gen_random_uuid(),
    'SKU-112233',
    'Heavy-Duty Packing Tape',
    'Industrial grade, 3-inch wide packing tape for large boxes.',
    'Supplies',
    12.99,
    0.5,
    '10x10x3',
    TRUE,
    NOW()
);

SELECT * FROM Products
WHERE sku = 'SKU-112233';
 
-- Query 3 (UPDATE 1)
-- A shipment has been delivered. Update its status and actual arrival time.
UPDATE Shipments 
SET 
    status = 'Delivered', 
    actual_arrival = NOW()
WHERE shipment_id = 'e095ace2-417b-4c54-af88-00faa335ba4e';

SELECT * FROM Shipments
WHERE shipment_id = 'e095ace2-417b-4c54-af88-00faa335ba4e';

-- Query 4 (UPDATE 2)
-- A customer has moved. Update their address.
UPDATE Customers
SET 
    address_line1 = '456 Oak Ave',
    city = 'Metropolis',
    state = 'IL',
    postal_code = '60601'
WHERE customer_id = '90510ac2-fa10-4be1-b811-54257900ff22';

SELECT * FROM Customers
WHERE customer_id = '90510ac2-fa10-4be1-b811-54257900ff22';

-- Query 5 (DELETE 1)
-- A customer cancelled an item from their order before it was processed.
DELETE FROM OrderItems
WHERE order_item_id = '1fbd41a2-0f35-42d4-9e29-88638a4e51ec';

SELECT * FROM OrderItems
WHERE order_item_id = '1fbd41a2-0f35-42d4-9e29-88638a4e51ec';

-- Query 6 (DELETE 2)
-- A duplicate tracking event was entered by mistake. Remove the erroneous record.
DELETE FROM ShipmentTrackingHistory
WHERE tracking_history_id = 'c7171863-4af1-451d-8d1f-476f89f6abb2';

SELECT * FROM ShipmentTrackingHistory
WHERE tracking_history_id = 'c7171863-4af1-451d-8d1f-476f89f6abb2';




-- 2. At least 4 select queries.

-- Query 1 (JOIN, GROUP BY, ORDER BY, SUM)
-- Find the Top 5 Most Valuable Customers (VIPs) by total amount spent.
SELECT 
    c.name,
    c.email,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_spent
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
WHERE o.payment_status = 'Paid'
GROUP BY c.customer_id, c.name, c.email
ORDER BY total_spent DESC
LIMIT 5;

-- Query 2 (JOIN, GROUP BY, AVG)
-- Analyze Shipping Carrier Performance.
SELECT 
    sc.name,
    COUNT(s.shipment_id) AS total_shipments_handled,
    AVG(s.actual_arrival - s.dispatch_date) AS avg_transit_time,
    AVG(sc.reliability_score) AS avg_reliability
FROM ShippingCarriers sc
JOIN Shipments s ON sc.carrier_id = s.carrier_id
WHERE s.status = 'Delivered'
GROUP BY sc.carrier_id, sc.name
ORDER BY avg_transit_time ASC;

-- Query 3 (Multi-JOIN, WHERE)
-- Low Inventory Alert.
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

-- Query 4 (Subquery, NOT IN)
-- Find "Inactive" Customers who have not placed an order in the last year.
SELECT 
    customer_id,
    name,
    email,
    registered_at
FROM Customers
WHERE customer_id NOT IN (
    SELECT DISTINCT customer_id
    FROM Orders
    WHERE order_date >= (NOW() - INTERVAL '1 year')
);

-- Query 5 (Multi-JOIN)
-- Full Order Trace for Customer Service.
SELECT
    c.name AS customer_name,
    o.order_id,
    o.order_date,
    p.name AS product_name,
    oi.quantity,
    s.tracking_number,
    sc.name AS carrier_name,
    s.status AS shipment_status,
    (SELECT st.status_description 
     FROM ShipmentTrackingHistory st
     WHERE st.shipment_id = s.shipment_id 
     ORDER BY st."timestamp" DESC 
     LIMIT 1) AS latest_tracking_update
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN OrderItems oi ON o.order_id = oi.order_id
JOIN Products p ON oi.product_id = p.product_id
JOIN Shipments s ON o.order_id = s.order_id
JOIN ShippingCarriers sc ON s.carrier_id = s.carrier_id
WHERE o.order_id = '1283686e-d496-42b8-8cfe-2627a0abcc19';



-- 3. Stored procedures for common operations.

-- Procedure 1: Get Shipment Details for an Order
CREATE OR REPLACE FUNCTION GetShipmentDetails(p_order_id UUID)
RETURNS TABLE(tracking_number VARCHAR, shipment_status VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.tracking_number,
        s.status
    FROM Shipments s
    WHERE s.order_id = p_order_id;
END;
$$ LANGUAGE plpgsql;

-- call:
-- SELECT * FROM GetShipmentDetails('8527860b-32a5-41d1-8e4e-3c5d72ec58da');


-- Procedure 2: Restock Inventory
CREATE OR REPLACE PROCEDURE RestockInventory(
    p_warehouse_id UUID,
    p_product_id UUID,
    p_quantity_added INTEGER
)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE Inventory
    SET 
        quantity_on_hand = quantity_on_hand + p_quantity_added,
        last_restock_date = NOW()
    WHERE 
        warehouse_id = p_warehouse_id AND product_id = p_product_id;
END;
$$;

-- call:
SELECT product_id, quantity_on_hand from Inventory
WHERE warehouse_id = '65545d54-2676-4739-a13b-e4ef2347f983'
AND product_id = '6a5e0fb7-7392-4215-b9b8-b927090b3e92';

CALL RestockInventory('65545d54-2676-4739-a13b-e4ef2347f983', '6a5e0fb7-7392-4215-b9b8-b927090b3e92', 100);

SELECT product_id, quantity_on_hand from Inventory
WHERE warehouse_id = '65545d54-2676-4739-a13b-e4ef2347f983'
AND product_id = '6a5e0fb7-7392-4215-b9b8-b927090b3e92';

-- Procedure 3: Update Order Status
CREATE OR REPLACE PROCEDURE UpdateOrderStatus(
    p_order_id UUID,
    p_new_status VARCHAR
)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE Orders
    SET status = p_new_status
    WHERE order_id = p_order_id;
END;
$$;

-- How to call:

SELECT order_id, status FROM Orders
WHERE order_id = '8527860b-32a5-41d1-8e4e-3c5d72ec58da';

CALL UpdateOrderStatus('8527860b-32a5-41d1-8e4e-3c5d72ec58da', 'Shipped');

SELECT order_id, status FROM Orders
WHERE order_id = '8527860b-32a5-41d1-8e4e-3c5d72ec58da';
