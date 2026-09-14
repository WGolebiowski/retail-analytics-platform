/*
DIM_SELLER

Source:
sellers
*/

CREATE VIEW dim_seller AS
SELECT
    seller_id,
    seller_city,
    seller_state
FROM sellers;