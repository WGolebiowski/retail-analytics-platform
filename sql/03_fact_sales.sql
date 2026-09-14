/*
FACT_SALES

Business Grain:
One record represents one order item sold.

Source Tables:
- orders
- order_items
*/

CREATE VIEW fact_sales AS
SELECT

    o.order_id,
    oi.order_item_id,

    o.order_purchase_timestamp,

    o.customer_id,
    oi.product_id,
    oi.seller_id,

    o.order_status,

    oi.price,
    oi.freight_value,

    oi.price + oi.freight_value AS sales_amount

FROM orders o
INNER JOIN order_items oi
    ON o.order_id = oi.order_id;
`