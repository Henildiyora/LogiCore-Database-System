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
