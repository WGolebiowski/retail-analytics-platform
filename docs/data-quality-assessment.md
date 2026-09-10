# Data Quality Assessment

## Duplicate Records

Customers: OK
Orders: OK
Products: OK
Sellers: OK

## Missing Values

Products:
product_category_name = 0 records missing

Order Items:
price = 0 record missing

Reviews:
review_score = 597 records missing

## Data Quality Decisions

Missing product category:
- replace with 'Unknown'

Missing review score:
- keep as NULL