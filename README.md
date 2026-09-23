# Retail Analytics Platform

End-to-end analytics portfolio project built using SQL, SQLite, Power BI and Data Governance practices.

The project demonstrates the complete analytics lifecycle:

**Source Data → Data Quality → Data Modeling → KPI Layer → Business Intelligence → Data Governance → AI Insights**

---

# Business Problem

Retail organizations often store large amounts of transaction data but struggle to convert raw data into actionable business insights.

The objective of this project was to design and build a complete analytics platform capable of:

- Monitoring sales performance
- Analyzing customer behavior
- Identifying high-value customer segments
- Evaluating product portfolio effectiveness
- Applying Data Governance practices
- Generating business-oriented insights

---

# Dataset

## Source

Brazilian E-Commerce Public Dataset (Olist)

Dataset contains approximately:

- 100,000 orders
- Customers
- Products
- Sellers
- Payments
- Reviews
- Geolocation data

The dataset enables sales, customer, product and operational analysis across multiple business dimensions.

---

# Project Architecture

```text
Source CSV Files
        ↓
SQLite Database
        ↓
Data Profiling & Quality Assessment
        ↓
Star Schema
        ↓
Analytical Views
        ↓
Power BI Semantic Layer
        ↓
Business Dashboards
        ↓
Data Governance Layer
        ↓
AI Insights Layer
```

---

# Data Model

## Source Model

The project uses the following source entities:

- Customers
- Orders
- Order Items
- Products
- Sellers
- Payments
- Reviews

## Analytical Model

### Fact Table

- FACT_SALES

### Dimensions

- DIM_CUSTOMER
- DIM_PRODUCT
- DIM_SELLER
- DIM_DATE

### Analytical Views

- customer_order_summary
- customer_rfm
- product_pareto

---

# Data Quality

The project includes:

- Source data profiling
- Relationship validation
- Duplicate detection
- Missing value assessment
- Analytical data preparation

Data quality findings and decisions are documented in the project documentation.

---

# KPI Framework

## Executive KPIs

- Product Revenue
- Gross Sales Value
- Orders
- Customers
- Average Order Value (AOV)

## Customer KPIs

- Repeat Customer Rate
- Customer Value
- Revenue per Customer
- Orders per Customer

## Product KPIs

- Revenue by Product Category
- Revenue by ABC Class
- Product Revenue Share
- Top Categories Revenue Share

## Advanced Analytics

- Month-over-Month Growth
- Year-over-Year Growth
- RFM Segmentation
- Pareto Analysis
- Revenue Concentration

---

# Dashboards

## Executive Overview

Provides a high-level view of sales performance.

Main KPIs:

- Product Revenue
- Orders
- Customers
- Average Order Value

Visualizations:

- Monthly Revenue Trend
- Revenue by Product Category
- Revenue by Customer State

screenshots/executive_overview.png

---

## Customer Analytics

Provides insights into customer behavior and retention.

Visualizations:

- Repeat Customer Rate
- Average Revenue per Customer
- Top Customers by Revenue
- Orders per Customer Distribution

screenshots/customer_analytics.png

---

## Customer Segmentation (RFM)

Customer segmentation based on:

- Recency
- Frequency
- Monetary Value

Segments:

- Champions
- Loyal Customers
- New or Promising
- Regular Customers
- At Risk
- Inactive

Visualizations:

- Customer Segment Distribution
- Revenue by Segment
- Average Customer Value by Segment
- Average Recency by Segment

screenshots/customer_segmentation.png

---

## Product Analysis

Product portfolio evaluation based on ABC and Pareto analysis.

Visualizations:

- Revenue by Product Category
- ABC Classification Distribution
- Revenue by ABC Class
- Top Categories Revenue Share

screenshots/product_analysis.png

---

# Data Governance Layer

The project includes governance artifacts that support consistency and transparency of analytical assets.

## Business Glossary

Business definitions used across dashboards and analytical models.

## KPI Catalog

Central repository of KPI definitions, formulas and business meaning.

## Data Catalog

Inventory of source tables, dimensions, facts and analytical views.

## Data Lineage

Documentation of data flow from source data through analytical models into Power BI dashboards.

Governance artifacts are available in:

```text
governance/
```

---

# AI Insights Layer

The project contains a conceptual AI Insights layer used to transform analytical results into business recommendations.

Example use cases:

- Executive summaries
- Customer insights
- Product portfolio recommendations
- Retention opportunities
- Revenue concentration detection

Artifacts available in:

```text
ai/
```

---

# Repository Structure


retail-analytics-platform/
│
├── architecture/
├── docs/
├── governance/
├── powerbi/
├── screenshots/
├── sql/
├── ai/
│
├── README.md
└── .gitignore
```

---

# Technology Stack

## Data Storage

- SQLite

## Query Language

- SQL

## Analytics & BI

- Power BI

## Governance

- Business Glossary
- KPI Catalog
- Data Catalog
- Data Lineage

## Version Control

- Git
- GitHub

---

# Key Business Findings

- Product revenue is highly concentrated within a limited number of product categories.
- ABC analysis confirms a strong Pareto distribution.
- Customer repeat rate is relatively low.
- At Risk customers represent significant revenue potential.
- Revenue is geographically concentrated in a small number of states.
- Revenue contribution is strongly driven by Category A products.

---

# Project Goals Achieved

✅ Data Quality Assessment

✅ Star Schema Design

✅ Analytical SQL Layer

✅ Advanced KPI Framework

✅ Power BI Reporting

✅ Customer Segmentation (RFM)

✅ ABC / Pareto Analysis

✅ Data Governance Layer

✅ AI Insight Layer

---

# Author

**Wojciech Gołębiowski**

Data Analytics | SQL | Power BI | Data Governance