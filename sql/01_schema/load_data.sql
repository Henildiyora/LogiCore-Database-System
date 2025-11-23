-- load.sql
-- Loads data from CSV files into the database.
-- IMPORTANT: The order of operations must respect foreign key constraints.

\COPY Customers FROM 'Customers.csv' WITH (FORMAT CSV, HEADER);
\COPY Products FROM 'Products.csv' WITH (FORMAT CSV, HEADER);
\COPY Suppliers FROM 'Suppliers.csv' WITH (FORMAT CSV, HEADER);
\COPY Warehouses FROM 'Warehouses.csv' WITH (FORMAT CSV, HEADER);
\COPY ShippingCarriers FROM 'ShippingCarriers.csv' WITH (FORMAT CSV, HEADER);

-- Level 1 tables can be loaded now
\COPY Orders FROM 'Orders.csv' WITH (FORMAT CSV, HEADER);
\COPY Inventory FROM 'Inventory.csv' WITH (FORMAT CSV, HEADER);
\COPY PurchaseOrders FROM 'PurchaseOrders.csv' WITH (FORMAT CSV, HEADER);

-- Level 2 tables can be loaded now
\COPY OrderItems FROM 'OrderItems.csv' WITH (FORMAT CSV, HEADER);
\COPY PurchaseOrderItems FROM 'PurchaseOrderItems.csv' WITH (FORMAT CSV, HEADER);
\COPY Shipments FROM 'Shipments.csv' WITH (FORMAT CSV, HEADER);

-- Level 3 tables can be loaded now
\COPY ShipmentTrackingHistory FROM 'ShipmentTrackingHistory.csv' WITH (FORMAT CSV, HEADER);

-- Completion
\qecho 'Data loading process completed.'