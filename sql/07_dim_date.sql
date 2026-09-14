/*
DIM_DATE

Source:
order_purchase_timestamp
*/

CREATE VIEW dim_date AS
SELECT DISTINCT
    DATE(order_purchase_timestamp) AS order_date,
    STRFTIME('%Y', order_purchase_timestamp) AS year,
    STRFTIME('%m', order_purchase_timestamp) AS month,
    STRFTIME('%d', order_purchase_timestamp) AS day,
    STRFTIME('%W', order_purchase_timestamp) AS week
FROM orders;