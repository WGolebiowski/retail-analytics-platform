## Tables

SELECT COUNT(*) as customers
FROM customers;

SELECT COUNT(*) as orders
FROM orders;

SELECT COUNT(*) as products
FROM products;

SELECT COUNT(*) as sellers
FROM sellers;

SELECT COUNT(*) as order_items
FROM order_items;

# Relationships validation

SELECT
    customer_id,
    COUNT(*) as orders_count
FROM orders
GROUP BY customer_id
ORDER BY orders_count DESC;

SELECT
    product_id,
    COUNT(*) as product_sales
FROM order_items
GROUP BY product_id
ORDER BY product_sales DESC;

SELECT
    seller_id,
    COUNT(*) as seller_sales
FROM order_items
GROUP BY seller_id
ORDER BY seller_sales DESC;

SELECT
    order_id,
    COUNT(*) as payment_count
FROM payments
GROUP BY order_id
ORDER BY payment_count DESC;

SELECT 
	order_id,
	COUNT(*) as review_count
FROM order_reviews
GROUP BY order_id
HAVING review_count = 0