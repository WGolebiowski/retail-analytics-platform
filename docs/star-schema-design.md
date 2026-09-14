# Star Schema Design

## Fact Table

FACT_SALES

Source:
- orders
- order_items

Grain:
One record represents one order item sold.

Measures:
- price
- freight_value
- sales_amount


## Dimensions

DIM_CUSTOMER
Source:
- customers

DIM_PRODUCT
Source:
- products

DIM_SELLER
Source:
- sellers

DIM_DATE
Source:
- order_purchase_timestamp