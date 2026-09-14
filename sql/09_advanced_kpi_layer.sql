/*
============================================================
ADVANCED KPI LAYER
E-Commerce Analytics Platform
============================================================

Database:
SQLite

Required analytical views:
- fact_sales
- dim_customer
- dim_product
- dim_seller

Definitions:
- Product Revenue = SUM(price)
- Gross Sales Value = SUM(price + freight_value)
- Freight Value = SUM(freight_value)
- Customer identity across orders = customer_unique_id

Important:
FACT_SALES grain is one order item.
Order-level metrics must use COUNT(DISTINCT order_id)
or aggregate data to the order level first.
*/


/*
============================================================
1. MONTH-OVER-MONTH PRODUCT REVENUE GROWTH
============================================================

Purpose:
Compares monthly product revenue with the previous month.

Note:
The first available month has no previous month,
so previous_month_revenue and growth percentages are NULL.
*/

WITH monthly_revenue AS (
    SELECT
        STRFTIME(
            '%Y-%m',
            order_purchase_timestamp
        ) AS year_month,
        SUM(price) AS revenue
    FROM fact_sales
    WHERE order_purchase_timestamp IS NOT NULL
    GROUP BY
        STRFTIME(
            '%Y-%m',
            order_purchase_timestamp
        )
),
monthly_comparison AS (
    SELECT
        year_month,
        revenue,
        LAG(revenue) OVER (
            ORDER BY year_month
        ) AS previous_month_revenue
    FROM monthly_revenue
)
SELECT
    year_month,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        previous_month_revenue,
        2
    ) AS previous_month_revenue,
    ROUND(
        revenue - previous_month_revenue,
        2
    ) AS revenue_change,
    ROUND(
        100.0
        * (revenue - previous_month_revenue)
        / NULLIF(previous_month_revenue, 0),
        2
    ) AS revenue_growth_pct
FROM monthly_comparison
ORDER BY
    year_month;


/*
============================================================
2. YEAR-OVER-YEAR PRODUCT REVENUE GROWTH
============================================================

Purpose:
Compares annual product revenue with the previous year.

Caution:
The first and last years in the dataset may be incomplete.
The result should therefore be interpreted together with
the minimum and maximum transaction dates.
*/

WITH yearly_revenue AS (
    SELECT
        CAST(
            STRFTIME(
                '%Y',
                order_purchase_timestamp
            ) AS INTEGER
        ) AS order_year,
        SUM(price) AS revenue
    FROM fact_sales
    WHERE order_purchase_timestamp IS NOT NULL
    GROUP BY
        CAST(
            STRFTIME(
                '%Y',
                order_purchase_timestamp
            ) AS INTEGER
        )
),
yearly_comparison AS (
    SELECT
        order_year,
        revenue,
        LAG(revenue) OVER (
            ORDER BY order_year
        ) AS previous_year_revenue
    FROM yearly_revenue
)
SELECT
    order_year,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        previous_year_revenue,
        2
    ) AS previous_year_revenue,
    ROUND(
        revenue - previous_year_revenue,
        2
    ) AS revenue_change,
    ROUND(
        100.0
        * (revenue - previous_year_revenue)
        / NULLIF(previous_year_revenue, 0),
        2
    ) AS revenue_growth_pct
FROM yearly_comparison
ORDER BY
    order_year;


/*
============================================================
3. REPEAT CUSTOMER RATE
============================================================

Purpose:
Calculates how many unique customers placed more than one order.

Important:
customer_unique_id is used to recognize the same customer
across different orders.
*/

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(
            DISTINCT f.order_id
        ) AS orders_count
    FROM fact_sales f
    INNER JOIN dim_customer c
        ON f.customer_id = c.customer_id
    WHERE c.customer_unique_id IS NOT NULL
    GROUP BY
        c.customer_unique_id
),
customer_summary AS (
    SELECT
        COUNT(*) AS total_customers,
        SUM(
            CASE
                WHEN orders_count > 1 THEN 1
                ELSE 0
            END
        ) AS repeat_customers
    FROM customer_orders
)
SELECT
    total_customers,
    repeat_customers,
    total_customers - repeat_customers
        AS one_time_customers,
    ROUND(
        100.0
        * repeat_customers
        / NULLIF(total_customers, 0),
        2
    ) AS repeat_customer_rate_pct
FROM customer_summary;


/*
============================================================
4. CUSTOMER PURCHASE VALUE
============================================================

Purpose:
Ranks customers by observed product revenue.

This is historical customer value, not predictive CLV.
*/

SELECT
    c.customer_unique_id,
    COUNT(
        DISTINCT f.order_id
    ) AS orders_count,
    ROUND(
        SUM(f.price),
        2
    ) AS product_revenue,
    ROUND(
        SUM(f.freight_value),
        2
    ) AS freight_value,
    ROUND(
        SUM(f.sales_amount),
        2
    ) AS gross_sales_value,
    ROUND(
        SUM(f.sales_amount)
        / NULLIF(
            COUNT(DISTINCT f.order_id),
            0
        ),
        2
    ) AS average_order_value
FROM fact_sales f
INNER JOIN dim_customer c
    ON f.customer_id = c.customer_id
WHERE c.customer_unique_id IS NOT NULL
GROUP BY
    c.customer_unique_id
ORDER BY
    gross_sales_value DESC
LIMIT 20;


/*
============================================================
5. RFM CUSTOMER SEGMENTATION
============================================================

RFM dimensions:
- Recency: days since the customer's most recent order
- Frequency: number of distinct orders
- Monetary: product revenue generated by the customer

Reference date:
The maximum purchase date in the dataset plus one day.

Scoring:
Each RFM dimension is divided into five groups using NTILE.
For recency, a more recent purchase receives a higher score.
*/

WITH dataset_reference AS (
    SELECT
        DATE(
            MAX(order_purchase_timestamp),
            '+1 day'
        ) AS reference_date
    FROM fact_sales
),
customer_rfm AS (
    SELECT
        c.customer_unique_id,
        CAST(
            JULIANDAY(r.reference_date)
            - JULIANDAY(
                DATE(
                    MAX(f.order_purchase_timestamp)
                )
            )
            AS INTEGER
        ) AS recency_days,
        COUNT(
            DISTINCT f.order_id
        ) AS frequency_orders,
        SUM(f.price) AS monetary_value
    FROM fact_sales f
    INNER JOIN dim_customer c
        ON f.customer_id = c.customer_id
    CROSS JOIN dataset_reference r
    WHERE c.customer_unique_id IS NOT NULL
    GROUP BY
        c.customer_unique_id,
        r.reference_date
),
rfm_scores AS (
    SELECT
        customer_unique_id,
        recency_days,
        frequency_orders,
        monetary_value,
        NTILE(5) OVER (
            ORDER BY recency_days DESC
        ) AS recency_score,
        NTILE(5) OVER (
            ORDER BY frequency_orders ASC
        ) AS frequency_score,
        NTILE(5) OVER (
            ORDER BY monetary_value ASC
        ) AS monetary_score
    FROM customer_rfm
),
rfm_segments AS (
    SELECT
        customer_unique_id,
        recency_days,
        frequency_orders,
        monetary_value,
        recency_score,
        frequency_score,
        monetary_score,
        printf(
            '%d%d%d',
            recency_score,
            frequency_score,
            monetary_score
        ) AS rfm_score,
        CASE
            WHEN recency_score >= 4
                 AND frequency_score >= 4
                 AND monetary_score >= 4
                THEN 'Champions'
            WHEN recency_score >= 3
                 AND frequency_score >= 3
                 AND monetary_score >= 3
                THEN 'Loyal Customers'
            WHEN recency_score >= 4
                 AND frequency_score <= 2
                THEN 'New or Promising'
            WHEN recency_score <= 2
                 AND frequency_score >= 3
                THEN 'At Risk'
            WHEN recency_score = 1
                 AND frequency_score <= 2
                THEN 'Inactive'
            ELSE 'Regular Customers'
        END AS customer_segment
    FROM rfm_scores
)
SELECT
    customer_unique_id,
    recency_days,
    frequency_orders,
    ROUND(
        monetary_value,
        2
    ) AS monetary_value,
    recency_score,
    frequency_score,
    monetary_score,
    rfm_score,
    customer_segment
FROM rfm_segments
ORDER BY
    monetary_value DESC;


/*
============================================================
6. RFM SEGMENT SUMMARY
============================================================

Purpose:
Summarizes the number and value of customers in each segment.

The RFM logic is repeated so that this section can be executed
independently in DBeaver.
*/

WITH dataset_reference AS (
    SELECT
        DATE(
            MAX(order_purchase_timestamp),
            '+1 day'
        ) AS reference_date

    FROM fact_sales
),
customer_rfm AS (
    SELECT
        c.customer_unique_id,
        CAST(
            JULIANDAY(r.reference_date)
            - JULIANDAY(
                DATE(
                    MAX(f.order_purchase_timestamp)
                )
            )
            AS INTEGER
        ) AS recency_days,
        COUNT(
            DISTINCT f.order_id
        ) AS frequency_orders,

        SUM(f.price) AS monetary_value
    FROM fact_sales f
    INNER JOIN dim_customer c
        ON f.customer_id = c.customer_id
    CROSS JOIN dataset_reference r
    WHERE c.customer_unique_id IS NOT NULL
    GROUP BY
        c.customer_unique_id,
        r.reference_date
),
rfm_scores AS (
    SELECT
        customer_unique_id,
        recency_days,
        frequency_orders,
        monetary_value,
        NTILE(5) OVER (
            ORDER BY recency_days DESC
        ) AS recency_score,
        NTILE(5) OVER (
            ORDER BY frequency_orders ASC
        ) AS frequency_score,
        NTILE(5) OVER (
            ORDER BY monetary_value ASC
        ) AS monetary_score
    FROM customer_rfm
),
rfm_segments AS (
    SELECT
        customer_unique_id,
        frequency_orders,
        monetary_value,
        CASE
            WHEN recency_score >= 4
                 AND frequency_score >= 4
                 AND monetary_score >= 4
                THEN 'Champions'

            WHEN recency_score >= 3
                 AND frequency_score >= 3
                 AND monetary_score >= 3
                THEN 'Loyal Customers'

            WHEN recency_score >= 4
                 AND frequency_score <= 2
                THEN 'New or Promising'

            WHEN recency_score <= 2
                 AND frequency_score >= 3
                THEN 'At Risk'

            WHEN recency_score = 1
                 AND frequency_score <= 2
                THEN 'Inactive'

            ELSE 'Regular Customers'
        END AS customer_segment
    FROM rfm_scores
)
SELECT
    customer_segment,
    COUNT(*) AS customers,
    ROUND(
        SUM(monetary_value),
        2
    ) AS product_revenue,
    ROUND(
        AVG(monetary_value),
        2
    ) AS average_customer_value,
    ROUND(
        AVG(frequency_orders),
    2
    ) AS average_orders_per_customer
FROM rfm_segments
GROUP BY
    customer_segment
ORDER BY
    product_revenue DESC;


/*
============================================================
7. PRODUCT CATEGORY PARETO ANALYSIS
============================================================

Purpose:
Calculates each category's contribution to product revenue
and the cumulative revenue percentage.

Pareto classification:
- Category A: cumulative contribution up to 80%
- Category B: cumulative contribution from 80% to 95%
- Category C: remaining contribution
*/

WITH category_revenue AS (
    SELECT
        COALESCE(
            p.product_category_name_english,
            'Unknown'
        ) AS product_category_name,
        SUM(f.price) AS revenue
    FROM fact_sales f
    INNER JOIN dim_product p
        ON f.product_id = p.product_id
    GROUP BY
        COALESCE(
            p.product_category_name_english,
            'Unknown'
        )
),
category_contribution AS (
    SELECT
        p.product_category_name_english,
        revenue,
        100.0
        * revenue
        / NULLIF(
            SUM(revenue) OVER (),
            0
        ) AS revenue_share_pct,
        100.0
        * SUM(revenue) OVER (
            ORDER BY revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        )
        / NULLIF(
            SUM(revenue) OVER (),
            0
        ) AS cumulative_revenue_pct
    FROM category_revenue
)

SELECT
    p.product_category_name_english,
    ROUND(
        revenue,
        2
    ) AS revenue,
    ROUND(
        revenue_share_pct,
        2
    ) AS revenue_share_pct,
    ROUND(
        cumulative_revenue_pct,
        2
    ) AS cumulative_revenue_pct,
    CASE
        WHEN cumulative_revenue_pct <= 80
            THEN 'A'
        WHEN cumulative_revenue_pct <= 95
            THEN 'B'
        ELSE 'C'
    END AS abc_class
FROM category_contribution
ORDER BY
    revenue DESC;


/*
============================================================
8. TOP 10 PRODUCT CATEGORIES CONTRIBUTION
============================================================

Purpose:
Shows how much of total product revenue is generated
by the ten highest-revenue product categories.
*/

WITH category_revenue AS (
    SELECT
        COALESCE(
            p.product_category_name,
            'Unknown'
        ) AS product_category_name,
        SUM(f.price) AS revenue
    FROM fact_sales f
    INNER JOIN dim_product p
        ON f.product_id = p.product_id
    GROUP BY
        COALESCE(
            p.product_category_name,
            'Unknown'
        )
),
ranked_categories AS (
    SELECT
        product_category_name,
        revenue,
        ROW_NUMBER() OVER (
            ORDER BY revenue DESC
        ) AS category_rank
    FROM category_revenue
)
SELECT
    ROUND(
        SUM(
            CASE
                WHEN category_rank <= 10
                    THEN revenue
                ELSE 0
            END
        ),
        2
    ) AS top_10_categories_revenue,
    ROUND(
        SUM(revenue),
        2
    ) AS total_revenue,
    ROUND(
        100.0
        * SUM(
            CASE
                WHEN category_rank <= 10
                    THEN revenue
                ELSE 0
            END
        )
        / NULLIF(
            SUM(revenue),
            0
        ),
        2
    ) AS top_10_revenue_share_pct
FROM ranked_categories;


/*
============================================================
9. SELLER REVENUE CONCENTRATION
============================================================

Purpose:
Measures revenue concentration among sellers.

This helps identify whether product revenue depends heavily
on a relatively small number of sellers.
*/

WITH seller_revenue AS (
    SELECT
        seller_id,
        SUM(price) AS revenue
    FROM fact_sales
    GROUP BY
        seller_id
),
ranked_sellers AS (
    SELECT
        seller_id,
        revenue,
        ROW_NUMBER() OVER (
            ORDER BY revenue DESC
        ) AS seller_rank,
        COUNT(*) OVER () AS total_sellers
    FROM seller_revenue
)
SELECT
    seller_id,
    ROUND(
        revenue,
        2
    ) AS revenue,
    seller_rank,
    total_sellers,
    ROUND(
        100.0
        * revenue
        / NULLIF(
            SUM(revenue) OVER (),
            0
        ),
        2
    ) AS revenue_share_pct,
    ROUND(
        100.0
        * SUM(revenue) OVER (
            ORDER BY revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW
        )
        / NULLIF(
            SUM(revenue) OVER (),
            0
        ),
        2
    ) AS cumulative_revenue_pct
FROM ranked_sellers
ORDER BY
    seller_rank;


/*
============================================================
10. AVERAGE ITEMS PER ORDER
============================================================

Purpose:
Calculates the average number of order-item rows per order.

This measures line items, not the quantity of physical units,
because the Olist order_items table does not contain
a separate quantity column.
*/

WITH order_item_counts AS (
    SELECT
        order_id,
        COUNT(*) AS items_count
    FROM fact_sales
    GROUP BY
        order_id
)
SELECT
    ROUND(
        AVG(items_count),
        2
    ) AS average_items_per_order,
    MIN(items_count) AS minimum_items_per_order,
    MAX(items_count) AS maximum_items_per_order
FROM order_item_counts;


/*
============================================================
11. FREIGHT SHARE OF GROSS SALES VALUE
============================================================

Purpose:
Shows freight value as a percentage of gross sales value.

Gross Sales Value:
price + freight_value
*/

SELECT
    ROUND(
        SUM(price),
        2
    ) AS product_revenue,
    ROUND(
        SUM(freight_value),
        2
    ) AS freight_value,
    ROUND(
        SUM(sales_amount),
        2
    ) AS gross_sales_value,
    ROUND(
        100.0
        * SUM(freight_value)
        / NULLIF(
            SUM(sales_amount),
            0
        ),
        2
    ) AS freight_share_pct
FROM fact_sales;


/*
============================================================
12. ORDER STATUS DISTRIBUTION
============================================================

Purpose:
Shows the number and percentage of orders by order status.

COUNT(DISTINCT order_id) is required because FACT_SALES
contains one row per order item.
*/

WITH status_orders AS (
    SELECT
        order_status,
        COUNT(
            DISTINCT order_id
        ) AS orders
    FROM fact_sales
    GROUP BY
        order_status
)
SELECT
    order_status,
    orders,
    ROUND(
        100.0
        * orders
        / NULLIF(
            SUM(orders) OVER (),
            0
        ),
        2
    ) AS orders_share_pct
FROM status_orders
ORDER BY
    orders DESC;


/*
