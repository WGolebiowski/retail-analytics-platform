/*
====================================================
KPI LAYER
E-Commerce Analytics Platform
====================================================
*/


/*
====================================================
1. REVENUE
====================================================
*/

SELECT
    ROUND(SUM(sales_amount), 2) AS revenue
FROM fact_sales;


/*
====================================================
2. NUMBER OF ORDERS
====================================================
*/

SELECT
    COUNT(DISTINCT order_id) AS orders
FROM fact_sales;


/*
====================================================
3. NUMBER OF CUSTOMERS
====================================================
*/

SELECT
    COUNT(DISTINCT customer_id) AS customers
FROM fact_sales;


/*
====================================================
4. AVERAGE ORDER VALUE (AOV)
====================================================
*/

SELECT
    ROUND(
        SUM(sales_amount) * 1.0
        / COUNT(DISTINCT order_id),
    2) AS average_order_value
FROM fact_sales;


/*
====================================================
5. MONTHLY REVENUE TREND
====================================================
*/

SELECT
    STRFTIME(
        '%Y-%m',
        order_purchase_timestamp
    ) AS year_month,
    ROUND(
        SUM(sales_amount),
        2
    ) AS revenue
FROM fact_sales
GROUP BY
    STRFTIME(
        '%Y-%m',
        order_purchase_timestamp
    )
ORDER BY
    year_month;


/*
====================================================
6. TOP PRODUCT CATEGORIES
====================================================
*/

SELECT
    p.product_category_name_english,
    ROUND(
        SUM(f.sales_amount),
        2
    ) AS revenue
FROM fact_sales f
INNER JOIN dim_product p
    ON f.product_id = p.product_id
GROUP BY
    p.product_category_name_english
ORDER BY
    revenue DESC
LIMIT 10;


/*
====================================================
7. TOP SELLERS
====================================================
*/

SELECT
    s.seller_id,
    ROUND(
        SUM(f.sales_amount),
        2
    ) AS revenue
FROM fact_sales f
INNER JOIN dim_seller s
    ON f.seller_id = s.seller_id
GROUP BY
    s.seller_id
ORDER BY
    revenue DESC
LIMIT 10;


/*
====================================================
8. REVENUE BY CUSTOMER STATE
====================================================
*/

SELECT
    c.customer_state,
    ROUND(
        SUM(f.sales_amount),
        2
    ) AS revenue
FROM fact_sales f
INNER JOIN dim_customer c
    ON f.customer_id = c.customer_id
GROUP BY
    c.customer_state
ORDER BY
    revenue DESC;

/*
====================================================
9. REPEAT CUSTOMERS
====================================================
*/

SELECT
    customer_id,
    COUNT(
        DISTINCT order_id
    ) AS orders_count
FROM fact_sales
GROUP BY
    customer_id
HAVING
    COUNT(
        DISTINCT order_id
    ) > 1
ORDER BY
    orders_count DESC;


/*
====================================================
10. TOP CUSTOMERS BY REVENUE
====================================================
*/

SELECT
    customer_id,
    ROUND(
        SUM(sales_amount),
        2
    ) AS revenue
FROM fact_sales
GROUP BY
    customer_id
ORDER BY
    revenue DESC
LIMIT 10;