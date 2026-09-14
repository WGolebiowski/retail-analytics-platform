/*
DIM_CUSTOMER

Source:
customers
*/

CREATE VIEW dim_customer AS
SELECT
    customer_id,
    customer_unique_id,
    customer_city,
    customer_state
FROM customers;