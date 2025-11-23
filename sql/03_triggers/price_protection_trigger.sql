-- TRANSACTION & TRIGGER
-- Business rule:
-- 1. Once a product is active (active_flag = TRUE), its price can never be lowered.
-- 2. Once a product has been sold in a paid order, its price can never be changed at all.

CREATE OR REPLACE FUNCTION prevent_product_price_decrease()
RETURNS TRIGGER AS $$
DECLARE
    old_price NUMERIC;
BEGIN
    IF TG_OP = 'UPDATE' THEN

        -- Active products cannot have their price decreased
        IF OLD.active_flag = TRUE AND NEW.unit_price < OLD.unit_price THEN
            RAISE EXCEPTION 'Price decrease forbidden for active product % (%)! Old: $% → $%',
                OLD.sku, OLD.product_id, OLD.unit_price, NEW.unit_price
            USING HINT = 'You may only increase or keep the price the same for active products.';
        END IF;

        -- Products that were ever sold in a paid order cannot change price change
        IF EXISTS (
            SELECT 1
            FROM OrderItems oi
            JOIN Orders o ON oi.order_id = o.order_id
            WHERE oi.product_id = OLD.product_id
              AND o.payment_status = 'Paid'
        ) AND NEW.unit_price != OLD.unit_price THEN
            RAISE EXCEPTION 'Price change forbidden for product % (%) because it has already been sold in paid orders.',
                OLD.sku, OLD.product_id;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach the trigger
DROP TRIGGER IF EXISTS trigger_prevent_price_drop ON Products;

CREATE TRIGGER trigger_prevent_price_drop
    BEFORE UPDATE ON Products
    FOR EACH ROW
    EXECUTE FUNCTION prevent_product_price_decrease();


-- TEST TRANSACTION

-- 1. Show current price of a product that is active (you can be SKU-112233 or any other )
SELECT sku, name, unit_price, active_flag
FROM Products
WHERE sku = 'SKU-112233';

-- 2. TRY TO DECREASE PRICE -> SHOULD FAIL
UPDATE Products
SET unit_price = 5.99
WHERE sku = 'SKU-112233';

-- 3. TRY TO INCREASE PRICE -> SHOULD SUCCEED
UPDATE Products
SET unit_price = 29.99
WHERE sku = 'SKU-112233';

-- 4. Verify price was actually increased
SELECT sku, name, unit_price, active_flag
FROM Products
WHERE sku = 'SKU-112233';

-- 5. Try to change price of a product that was already sold (pick any product that appears in a paid order)
-- Example (change the product_id to one that really exists in OrderItems of a Paid order)
UPDATE Products
SET unit_price = 15.00
WHERE product_id = '33b003f3-0484-4a1e-b8f5-590566384273';  -- this should FAIL

-- 6. Clean-up (optional – put price back)
UPDATE Products
SET unit_price = 12.99
WHERE sku = 'SKU-112233';