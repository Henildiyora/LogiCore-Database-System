import pandas as pd

def verify_fk_relationship(parent_csv, parent_pk_col, child_csv, child_fk_col):
    """
    Verifies that all foreign key values in the child CSV exist in the
    parent CSV's primary key column.
    """
    try:
        df_parent = pd.read_csv(parent_csv)
        df_child = pd.read_csv(child_csv)

        # Get the set of unique primary and foreign keys
        parent_keys = set(df_parent[parent_pk_col])
        child_keys = set(df_child[child_fk_col])

        print(f"Checking: {child_csv} ({child_fk_col}) -> {parent_csv} ({parent_pk_col})")
        
        # Check if the set of child keys is a subset of the parent keys
        if child_keys.issubset(parent_keys):
            print(" PASSED: All foreign keys are valid.\n")
            return True
        else:
            # Find the exact keys that are causing the violation
            invalid_keys = child_keys - parent_keys
            print(f"FAILED: Found {len(invalid_keys)} invalid foreign key(s).")
            # Print a few examples of invalid keys
            print(f"     Examples of invalid keys: {list(invalid_keys)[:5]}\n")
            return False

    except FileNotFoundError as e:
        print(f"Error: Could not find file {e.filename}. Please check file paths.\n")
        return False
    except KeyError as e:
        print(f"Error: Column {e} not found. Please check column names.\n")
        return False

# Define the relationships to verify
relationships = [
    ("Customers.csv", "customer_id", "Orders.csv", "customer_id"),
    ("Warehouses.csv", "warehouse_id", "Orders.csv", "fulfillment_warehouse_id"),
    ("Orders.csv", "order_id", "OrderItems.csv", "order_id"),
    ("Products.csv", "product_id", "OrderItems.csv", "product_id"),
    ("Warehouses.csv", "warehouse_id", "Inventory.csv", "warehouse_id"),
    ("Products.csv", "product_id", "Inventory.csv", "product_id"),
    ("Suppliers.csv", "supplier_id", "PurchaseOrders.csv", "supplier_id"),
    ("Warehouses.csv", "warehouse_id", "PurchaseOrders.csv", "warehouse_id"),
    ("PurchaseOrders.csv", "po_id", "PurchaseOrderItems.csv", "po_id"),
    ("Products.csv", "product_id", "PurchaseOrderItems.csv", "product_id"),
    ("Orders.csv", "order_id", "Shipments.csv", "order_id"),
    ("ShippingCarriers.csv", "carrier_id", "Shipments.csv", "carrier_id"),
    ("Warehouses.csv", "warehouse_id", "Shipments.csv", "origin_warehouse_id"),
    ("Shipments.csv", "shipment_id", "ShipmentTrackingHistory.csv", "shipment_id")
]

# Run the verification for all relationships
all_passed = True
for parent_csv, parent_pk, child_csv, child_fk in relationships:
    if not verify_fk_relationship(parent_csv, parent_pk, child_csv, child_fk):
        all_passed = False

if all_passed:
    print("All referential integrity checks passed! Your dataset is consistent and ready for loading.")
else:
    print("Some integrity checks failed. Please review the errors above and fix the data generation script.")