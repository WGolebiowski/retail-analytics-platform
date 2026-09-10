# Source Data Profiling

# Count records in source tables

Customers: 99 441
Orders: 99 441
Products: 32 951
Order Items: 112 650
Sellers: 3095

# Relationships validation

Customers 1:N Orders ✅

Orders 1:N Order Items ✅

Products 1:N Order Items ✅

Sellers 1:N Order Items ✅

Orders 1:N Payments ✅

Orders 1:0..1 Reviews ✅