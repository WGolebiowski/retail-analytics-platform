# PRIMARY KEYS CHECK

SELECT
    customer_id,
    COUNT(*)
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT
    order_id,
    COUNT(*)
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT
    product_id,
    COUNT(*)
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT
    seller_id,
    COUNT(*)
FROM sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;

# MISSING VALUES CHECK

SELECT
    COUNT(*) as missing_customer
FROM orders
WHERE customer_id IS NULL;

SELECT
    COUNT(*) as missing_category
FROM products
WHERE product_category_name IS NULL;

SELECT
    COUNT(*) as missing_price
FROM order_items
WHERE price IS NULL;

SELECT
    COUNT(*) as missing_review_score
FROM reviews
WHERE review_score IS NULL;

# DATE VALIDATION CHECK

SELECT
    MIN(order_purchase_timestamp),
    MAX(order_purchase_timestamp)
FROM orders;

SELECT
    COUNT(*)
FROM orders
WHERE order_purchase_timestamp IS NULL;