-- Stored procedures for common operations.

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

-- call:
-- SELECT order_id, status FROM Orders
-- WHERE order_id = '8527860b-32a5-41d1-8e4e-3c5d72ec58da';

-- CALL UpdateOrderStatus('8527860b-32a5-41d1-8e4e-3c5d72ec58da', 'Shipped');

-- SELECT order_id, status FROM Orders
-- WHERE order_id = '8527860b-32a5-41d1-8e4e-3c5d72ec58da';
