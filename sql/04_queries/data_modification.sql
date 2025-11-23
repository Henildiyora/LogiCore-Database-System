-- queries for inserting, deleting, and updating.

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

-- Query 2 (INSERT)
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
 
-- Query 3 (UPDATE)
-- A shipment has been delivered. Update its status and actual arrival time.
UPDATE Shipments 
SET 
    status = 'Delivered', 
    actual_arrival = NOW()
WHERE shipment_id = 'e095ace2-417b-4c54-af88-00faa335ba4e';

SELECT * FROM Shipments
WHERE shipment_id = 'e095ace2-417b-4c54-af88-00faa335ba4e';

-- Query 4 (UPDATE)
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

-- Query 5 (DELETE)
-- A customer cancelled an item from their order before it was processed.
DELETE FROM OrderItems
WHERE order_item_id = '1fbd41a2-0f35-42d4-9e29-88638a4e51ec';

SELECT * FROM OrderItems
WHERE order_item_id = '1fbd41a2-0f35-42d4-9e29-88638a4e51ec';

-- Query 6 (DELETE)
-- A duplicate tracking event was entered by mistake. Remove the erroneous record.
DELETE FROM ShipmentTrackingHistory
WHERE tracking_history_id = 'c7171863-4af1-451d-8d1f-476f89f6abb2';

SELECT * FROM ShipmentTrackingHistory
WHERE tracking_history_id = 'c7171863-4af1-451d-8d1f-476f89f6abb2';