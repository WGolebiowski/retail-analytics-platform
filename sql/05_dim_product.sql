/*
DIM_PRODUCT

Source:
products
*/

CREATE VIEW dim_product AS
SELECT
    product_id,
    COALESCE(product_category_name,'Unknown')
        AS product_category_name,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM products;