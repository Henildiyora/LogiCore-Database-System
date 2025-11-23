import random
import uuid
from faker import Faker
import pandas as pd
import numpy as np
from datetime import datetime, timedelta


NUM_RECORDS_PER_TABLE = 10000
SEED = 42

# Use en_US provider for USA-centric data
fake = Faker('en_US') 
Faker.seed(SEED)
random.seed(SEED)
np.random.seed(SEED)

print("Starting dataset generation\n")

def rand_dt(start_date, end_date):
    return fake.date_time_between(start_date=start_date, end_date=end_date)

# Define a time range for the data
end_time = datetime.now()
start_time = end_time - timedelta(days=365*3)


# Generate Parent Tables First
# 1. Customers
customers = []
for _ in range(NUM_RECORDS_PER_TABLE):
    customers.append({
        "customer_id": str(uuid.uuid4()), "name": fake.name(), "email": fake.unique.safe_email(),
        "phone": fake.phone_number(), 
        "address_line1": fake.street_address().replace(',', ''),
        "city": fake.city(), "state": fake.state_abbr(), "postal_code": fake.postcode(), "country": "USA",
        "registered_at": rand_dt(start_time, end_time),
        "vip_flag": random.choices([True, False], weights=[0.05, 0.95])[0]
    })
df_customers = pd.DataFrame(customers)
df_customers.to_csv("Customers.csv", index=False)
print(f"Generated {len(df_customers)} records in Customers.csv")

# 2. Products
categories = ["Electronics", "Clothing", "Books", "Home Goods", "Sports", "Toys"]
products = []
for _ in range(NUM_RECORDS_PER_TABLE):
    products.append({
        "product_id": str(uuid.uuid4()), "sku": f"SKU-{random.randint(10000000, 99999999)}",
        "name": fake.bs().title(), "description": fake.sentence(nb_words=10),
        "category": random.choice(categories), "unit_price": round(random.uniform(5.0, 1500.0), 2),
        "weight_kg": round(random.uniform(0.1, 25.0), 2),
        "dimensions_cm": f"{random.randint(5,100)}x{random.randint(5,100)}x{random.randint(5,100)}",
        "active_flag": random.choices([True, False], weights=[0.95, 0.05])[0],
        "created_at": rand_dt(start_time, end_time)
    })
df_products = pd.DataFrame(products)
df_products.to_csv("Products.csv", index=False)
print(f"Generated {len(df_products)} records in Products.csv")

# 3. Suppliers
suppliers = []
for _ in range(NUM_RECORDS_PER_TABLE):
    suppliers.append({
        "supplier_id": str(uuid.uuid4()), "name": fake.company(), "contact_name": fake.name(),
        "contact_email": fake.company_email(), "phone": fake.phone_number(), "country": "USA",
        "lead_time_days": random.randint(3, 30), "rating": round(random.uniform(3.5, 5.0), 1),
        "preferred": random.choices([True, False], weights=[0.2, 0.8])[0]
    })
df_suppliers = pd.DataFrame(suppliers)
df_suppliers.to_csv("Suppliers.csv", index=False)
print(f"Generated {len(df_suppliers)} records in Suppliers.csv")

# 4. Warehouses
warehouses = []
for _ in range(NUM_RECORDS_PER_TABLE):
    city = fake.city()
    address = fake.street_address().replace(',', '')
    warehouses.append({
        "warehouse_id": str(uuid.uuid4()), "location_name": f"{city} Distribution Center",
        "address_line1": address, "city": city, "state": fake.state_abbr(),
        "postal_code": fake.postcode(), "country": "USA", "latitude": float(fake.latitude()),
        "longitude": float(fake.longitude()), "capacity": random.randint(50000, 200000),
        "manager_name": fake.name()
    })
df_warehouses = pd.DataFrame(warehouses)
df_warehouses.to_csv("Warehouses.csv", index=False)
print(f"Generated {len(df_warehouses)} records in Warehouses.csv")

# 5. ShippingCarriers
carriers = []
for _ in range(NUM_RECORDS_PER_TABLE):
    company = fake.company()
    carriers.append({
        "carrier_id": str(uuid.uuid4()), "name": f"{company} Logistics",
        "tracking_url": f"https://track.{company.lower().replace(' ', '')}.com/?id=",
        "phone": fake.phone_number(), "service_level": random.choice(["Standard", "Express", "Overnight"]),
        "reliability_score": round(random.uniform(0.90, 0.99), 2),
        "avg_transit_days": random.randint(1, 8)
    })
df_carriers = pd.DataFrame(carriers)
df_carriers.to_csv("ShippingCarriers.csv", index=False)
print(f"Generated {len(df_carriers)} records in ShippingCarriers.csv")

# Collect all PKs for guaranteed FK integrity in child tables
customer_pks = df_customers["customer_id"].tolist()
product_pks = df_products["product_id"].tolist()
supplier_pks = df_suppliers["supplier_id"].tolist()
warehouse_pks = df_warehouses["warehouse_id"].tolist()
carrier_pks = df_carriers["carrier_id"].tolist()
price_map = dict(zip(df_products["product_id"], df_products["unit_price"]))
print("\nParent tables generated. Now generating child tables with strict FKs.\n")


# Generate Child Tables
# 6. Orders
orders = []
for _ in range(NUM_RECORDS_PER_TABLE):
    shipping_addr = fake.address().replace('\n', ' ').replace(',', '')
    orders.append({
        "order_id": str(uuid.uuid4()), "customer_id": random.choice(customer_pks),
        "order_date": rand_dt(start_time, end_time),
        "status": random.choice(["Placed", "Shipped", "Delivered", "Cancelled"]),
        "total_amount": 0.0, "currency": "USD", "shipping_address": shipping_addr,
        "payment_method": random.choice(["Credit Card", "PayPal", "COD"]),
        "payment_status": random.choice(["Paid", "Pending", "Failed"]),
        "fulfillment_warehouse_id": random.choice(warehouse_pks)
    })
df_orders = pd.DataFrame(orders)
order_pks = df_orders["order_id"].tolist()
print(f"Generated {len(df_orders)} initial records for Orders.csv")

# 7. OrderItems
order_items = []
for _ in range(NUM_RECORDS_PER_TABLE):
    pid = random.choice(product_pks)
    unit_price = price_map[pid]
    qty = random.randint(1, 5)
    line_total = round(qty * unit_price, 2)
    order_items.append({
        "order_item_id": str(uuid.uuid4()),
        "order_id": random.choice(order_pks), 
        "product_id": pid, "quantity": qty, "price_at_time_of_sale": unit_price,
        "discount": 0.0, "tax_amount": 0.0, "line_total": line_total
    })
df_order_items = pd.DataFrame(order_items)

# Update order totals based on actual items
order_totals = df_order_items.groupby("order_id")["line_total"].sum().reset_index()
order_totals = order_totals.rename(columns={"line_total": "calculated_total"})
df_orders = pd.merge(df_orders, order_totals, on="order_id", how="left")
df_orders["total_amount"] = df_orders["calculated_total"].fillna(0.0)
df_orders.drop(columns=["calculated_total"], inplace=True)
df_orders.to_csv("Orders.csv", index=False)
df_order_items.to_csv("OrderItems.csv", index=False)
print(f"Generated {len(df_order_items)} records in OrderItems.csv and updated Orders.csv")

# 8. Inventory
inventory_rows = []
inventory_pairs = set()
while len(inventory_pairs) < NUM_RECORDS_PER_TABLE:
    inventory_pairs.add((random.choice(warehouse_pks), random.choice(product_pks)))

for wid, pid in inventory_pairs:
    inventory_rows.append({
        "warehouse_id": wid, "product_id": pid,
        "quantity_on_hand": random.randint(0, 2000), "reorder_level": random.randint(20, 100),
        "last_restock_date": rand_dt(start_time, end_time), "safety_stock": random.randint(10, 50)
    })
df_inventory = pd.DataFrame(inventory_rows)
df_inventory.to_csv("Inventory.csv", index=False)
print(f"Generated {len(df_inventory)} records in Inventory.csv")

# 9. PurchaseOrders
purchase_orders = []
for _ in range(NUM_RECORDS_PER_TABLE):
    purchase_orders.append({
        "po_id": str(uuid.uuid4()), "supplier_id": random.choice(supplier_pks),
        "warehouse_id": random.choice(warehouse_pks), "po_date": rand_dt(start_time, end_time),
        "expected_delivery_date": rand_dt(end_time, end_time + timedelta(days=30)),
        "status": random.choice(["Ordered", "In Transit", "Received", "Cancelled"]),
        "total_cost": round(random.uniform(500, 50000), 2), "created_by": fake.name()
    })
df_purchase_orders = pd.DataFrame(purchase_orders)
po_pks = df_purchase_orders["po_id"].tolist()
df_purchase_orders.to_csv("PurchaseOrders.csv", index=False)
print(f"Generated {len(df_purchase_orders)} records in PurchaseOrders.csv")

# 10. PurchaseOrderItems
po_items = []
for _ in range(NUM_RECORDS_PER_TABLE):
    pid = random.choice(product_pks)
    unit_cost = round(price_map[pid] * random.uniform(0.4, 0.7), 2)
    qty = random.randint(50, 1000)
    po_items.append({
        "po_item_id": str(uuid.uuid4()), "po_id": random.choice(po_pks), "product_id": pid,
        "quantity": qty, "unit_cost": unit_cost,
        "expected_recv_date": rand_dt(end_time, end_time + timedelta(days=30)),
        "received_qty": 0, "line_total": round(qty * unit_cost, 2)
    })
df_po_items = pd.DataFrame(po_items)
df_po_items.to_csv("PurchaseOrderItems.csv", index=False)
print(f"Generated {len(df_po_items)} records in PurchaseOrderItems.csv")

# 11. Shipments
shipments = []
for _ in range(NUM_RECORDS_PER_TABLE):
    shipments.append({
        "shipment_id": str(uuid.uuid4()), 
        "order_id": random.choice(order_pks),
        "carrier_id": random.choice(carrier_pks),
        "tracking_number": f"TRK{random.randint(10**12, 10**13-1)}",
        "dispatch_date": rand_dt(start_time, end_time),
        "estimated_arrival": rand_dt(end_time, end_time + timedelta(days=10)),
        "actual_arrival": rand_dt(end_time, end_time + timedelta(days=12)),
        "shipping_cost": round(random.uniform(5.0, 100.0), 2),
        "origin_warehouse_id": random.choice(warehouse_pks),
        "status": random.choice(["In Transit", "Delivered", "Delayed"])
    })
df_shipments = pd.DataFrame(shipments)
shipment_pks = df_shipments["shipment_id"].tolist()
df_shipments.to_csv("Shipments.csv", index=False)
print(f"Generated {len(df_shipments)} records in Shipments.csv")

# 12. ShipmentTrackingHistory
track_rows = []
for _ in range(NUM_RECORDS_PER_TABLE):
    track_rows.append({
        "tracking_history_id": str(uuid.uuid4()), "shipment_id": random.choice(shipment_pks),
        "timestamp": rand_dt(start_time, end_time),
        "status_description": random.choice(["Label Created", "Picked Up", "In Transit", "Out for Delivery", "Delivered"]),
        "location": f"{fake.city()}, {fake.state_abbr()}"
    })
df_tracking = pd.DataFrame(track_rows)
df_tracking['location'] = df_tracking['location'].str.replace(',', '', regex=False)
df_tracking.to_csv("ShipmentTrackingHistory.csv", index=False)
print(f"Generated {len(df_tracking)} records in ShipmentTrackingHistory.csv")

print("\n Dataset generated successfully")