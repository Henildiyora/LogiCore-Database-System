DROP TABLE IF EXISTS ShipmentTrackingHistory, PurchaseOrderItems, OrderItems, Shipments, PurchaseOrders, Orders, Inventory, ShippingCarriers, Warehouses, Suppliers, Products, Customers CASCADE;

CREATE TABLE Customers (
    customer_id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(50),
    address_line1 VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(50),
    registered_at TIMESTAMP WITH TIME ZONE,
    vip_flag BOOLEAN DEFAULT FALSE
);

CREATE TABLE Products (
    product_id UUID PRIMARY KEY,
    sku VARCHAR(100) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    unit_price NUMERIC(10, 2) NOT NULL CHECK (unit_price >= 0),
    weight_kg NUMERIC(10, 3),
    dimensions_cm VARCHAR(100),
    active_flag BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE Suppliers (
    supplier_id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    contact_name VARCHAR(255),
    contact_email VARCHAR(255),
    phone VARCHAR(50),
    country VARCHAR(100),
    lead_time_days INTEGER,
    rating NUMERIC(3, 2),
    preferred BOOLEAN
);

-- create.sql -- FIX THIS BLOCK

CREATE TABLE Warehouses (
    warehouse_id UUID PRIMARY KEY,
    location_name VARCHAR(255) NOT NULL,
    address_line1 VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100),
    latitude NUMERIC(9, 6),
    longitude NUMERIC(9, 6),
    capacity INTEGER,
    manager_name VARCHAR(255)
);

CREATE TABLE ShippingCarriers (
    carrier_id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    tracking_url VARCHAR(512),
    phone VARCHAR(50),
    service_level VARCHAR(50),
    reliability_score NUMERIC(4, 3),
    avg_transit_days INTEGER
);

-- Child Tables (Level 1 - Dependencies on Level 0)
CREATE TABLE Orders (
    order_id UUID PRIMARY KEY,
    customer_id UUID NOT NULL REFERENCES Customers(customer_id),
    order_date TIMESTAMP WITH TIME ZONE,
    status VARCHAR(50),
    total_amount NUMERIC(12, 2),
    currency VARCHAR(10),
    shipping_address TEXT,
    payment_method VARCHAR(50),
    payment_status VARCHAR(50),
    fulfillment_warehouse_id UUID REFERENCES Warehouses(warehouse_id)
);

CREATE TABLE Inventory (
    warehouse_id UUID NOT NULL REFERENCES Warehouses(warehouse_id),
    product_id UUID NOT NULL REFERENCES Products(product_id),
    quantity_on_hand INTEGER NOT NULL,
    reorder_level INTEGER,
    last_restock_date TIMESTAMP WITH TIME ZONE,
    safety_stock INTEGER,
    PRIMARY KEY (warehouse_id, product_id)
);

CREATE TABLE PurchaseOrders (
    po_id UUID PRIMARY KEY,
    supplier_id UUID NOT NULL REFERENCES Suppliers(supplier_id),
    warehouse_id UUID NOT NULL REFERENCES Warehouses(warehouse_id),
    po_date TIMESTAMP WITH TIME ZONE,
    expected_delivery_date DATE,
    status VARCHAR(50),
    total_cost NUMERIC(12, 2),
    created_by VARCHAR(255)
);

-- Child Tables (Level 2 - Dependencies on Level 1)
CREATE TABLE OrderItems (
    order_item_id UUID PRIMARY KEY,
    order_id UUID NOT NULL REFERENCES Orders(order_id),
    product_id UUID NOT NULL REFERENCES Products(product_id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    price_at_time_of_sale NUMERIC(10, 2) NOT NULL,
    discount NUMERIC(4, 2),
    tax_amount NUMERIC(10, 2),
    line_total NUMERIC(12, 2)
);

CREATE TABLE PurchaseOrderItems (
    po_item_id UUID PRIMARY KEY,
    po_id UUID NOT NULL REFERENCES PurchaseOrders(po_id),
    product_id UUID NOT NULL REFERENCES Products(product_id),
    quantity INTEGER NOT NULL,
    unit_cost NUMERIC(10, 2),
    expected_recv_date DATE,
    received_qty INTEGER,
    line_total NUMERIC(12, 2)
);

CREATE TABLE Shipments (
    shipment_id UUID PRIMARY KEY,
    order_id UUID NOT NULL REFERENCES Orders(order_id),
    carrier_id UUID NOT NULL REFERENCES ShippingCarriers(carrier_id),
    tracking_number VARCHAR(255) UNIQUE,
    dispatch_date TIMESTAMP WITH TIME ZONE,
    estimated_arrival DATE,
    actual_arrival TIMESTAMP WITH TIME ZONE,
    shipping_cost NUMERIC(10, 2),
    origin_warehouse_id UUID REFERENCES Warehouses(warehouse_id),
    status VARCHAR(50)
);

-- Child Table (Level 3 - Dependencies on Level 2)
CREATE TABLE ShipmentTrackingHistory (
    tracking_history_id UUID PRIMARY KEY,
    shipment_id UUID NOT NULL REFERENCES Shipments(shipment_id),
    "timestamp" TIMESTAMP WITH TIME ZONE,
    status_description VARCHAR(255),
    location VARCHAR(255)
);

-- Create Indexes on Foreign Keys for better query performance
CREATE INDEX ON Orders (customer_id);
CREATE INDEX ON OrderItems (order_id);
CREATE INDEX ON OrderItems (product_id);
CREATE INDEX ON PurchaseOrders (supplier_id);
CREATE INDEX ON Shipments (order_id);
CREATE INDEX ON Shipments (carrier_id);
CREATE INDEX ON ShipmentTrackingHistory (shipment_id);