
USE dataco_supply_chain_dw;
---Creating Schema for views
CREATE SCHEMA analytics;
GO

-----View 1: Fulfillment overview
CREATE VIEW analytics.fulfillment_overview AS
SELECT
    COUNT(DISTINCT f.order_key) AS total_orders,
    COUNT(*) AS total_order_items,
    SUM(f.sales) AS total_revenue,
    SUM(f.order_profit_per_order) AS total_profit,
    AVG(CAST(f.days_shipping_real - f.days_shipment_scheduled AS DECIMAL(10,2))) AS avg_delay,
    COUNT(CASE WHEN f.days_shipping_real > f.days_shipment_scheduled THEN 1 END) * 100.0 / COUNT(*) AS late_delivery_rate
FROM dw.fact_order_item f;
GO

---DROP VIEW IF EXISTS analytics.region_delay_analysis;
----View 2: Region delay analysis
CREATE VIEW analytics.region_delay_analysis AS
SELECT
    ol.order_region,
    COUNT(DISTINCT f.order_key) AS total_orders,
    SUM(f.sales) AS total_revenue,
    SUM(f.order_profit_per_order) AS total_profit,
    AVG(CAST(f.days_shipping_real - f.days_shipment_scheduled AS DECIMAL(10,2))) AS avg_delay,
    COUNT(CASE WHEN f.days_shipping_real > f.days_shipment_scheduled THEN 1 END) * 100.0 / COUNT(DISTINCT f.order_key) AS late_delivery_rate
FROM dw.fact_order_item f
JOIN dw.dim_order o
    ON f.order_key = o.order_key
JOIN dw.dim_order_location ol
    ON o.order_location_key = ol.order_location_key
GROUP BY
    ol.order_region
ORDER BY late_delivery_rate DESC;
GO

---DROP VIEW IF EXISTS analytics.category_delay_profit_analysis;
---View 3: Category delay and profit analysis
CREATE VIEW analytics.category_delay_profit_analysis AS
SELECT
    c.category_name,
    dep.department_name,

    COUNT(*) AS total_order_items,

    COUNT(DISTINCT f.order_key) AS total_orders,

    SUM(f.sales) AS total_revenue,

    SUM(f.order_profit_per_order) AS total_profit,

    AVG(
        CAST(f.days_shipping_real - f.days_shipment_scheduled AS FLOAT)
    ) AS avg_delay,

    COUNT(DISTINCT CASE
        WHEN f.days_shipping_real > f.days_shipment_scheduled
        THEN f.order_key
    END) * 100.0 / COUNT(DISTINCT f.order_key) AS late_delivery_rate,

    (SUM(f.order_profit_per_order) * 100.0 / NULLIF(SUM(f.sales), 0)) AS profit_margin_percent

FROM dw.fact_order_item f
JOIN dw.dim_product p
    ON f.product_key = p.product_key
JOIN dw.dim_category c
    ON p.category_key = c.category_key
JOIN dw.dim_department dep
    ON c.department_key = dep.department_key

GROUP BY
    c.category_name,
    dep.department_name;
GO

DROP VIEW IF EXISTS analytics.shipping_mode_performance;
-----View 4: Shipping mode performance
CREATE OR ALTER VIEW analytics.shipping_mode_performance AS
SELECT
    sm.shipping_mode_name,
    ol.order_region,
    c.category_name,
    dep.department_name,
    y.year_number AS order_year,

    COUNT(DISTINCT f.order_key) AS total_orders,

    COUNT(DISTINCT CASE
        WHEN f.days_shipping_real > f.days_shipment_scheduled
        THEN f.order_key
    END) AS late_orders,

    SUM(CAST(f.days_shipping_real - f.days_shipment_scheduled AS FLOAT)) AS total_delay_days,

    SUM(f.sales) AS total_revenue,
    SUM(f.order_profit_per_order) AS total_profit

FROM dw.fact_order_item f
JOIN dw.dim_shipping_mode sm
    ON f.shipping_mode_key = sm.shipping_mode_key
JOIN dw.dim_order o
    ON f.order_key = o.order_key
JOIN dw.dim_order_location ol
    ON o.order_location_key = ol.order_location_key
JOIN dw.dim_product p
    ON f.product_key = p.product_key
JOIN dw.dim_category c
    ON p.category_key = c.category_key
JOIN dw.dim_department dep
    ON c.department_key = dep.department_key
JOIN dw.dim_date d
    ON f.order_date_key = d.date_key
JOIN dw.dim_month m
    ON d.month_key = m.month_key
JOIN dw.dim_quarter q
    ON m.quarter_key = q.quarter_key
JOIN dw.dim_year y
    ON q.year_key = y.year_key
GROUP BY
    sm.shipping_mode_name,
    ol.order_region,
    c.category_name,
    dep.department_name,
    y.year_number;


--Late Deliveries Over Time
CREATE VIEW analytics.late_delivery_trend AS
SELECT
d.full_date,
COUNT(DISTINCT CASE 
        WHEN f.days_shipping_real > f.days_shipment_scheduled 
        THEN f.order_key 
     END) AS late_orders,
COUNT(DISTINCT f.order_key) AS total_orders
FROM dw.fact_order_item f
JOIN dw.dim_date d
ON f.order_date_key = d.date_key
GROUP BY d.full_date;

---Revenue vs Profit
CREATE VIEW analytics.revenue_profit_summary AS
SELECT
ds.delivery_status_name,
SUM(f.sales) AS total_revenue,
SUM(f.order_profit_per_order) AS total_profit
FROM dw.fact_order_item f
JOIN dw.dim_delivery d
ON f.delivery_key = d.delivery_key
JOIN dw.dim_delivery_status ds
ON d.delivery_status_key = ds.delivery_status_key
GROUP BY ds.delivery_status_name;

---Delivery Status Distribution
CREATE VIEW analytics.delivery_status_distribution AS
SELECT
ds.delivery_status_name,
COUNT(DISTINCT f.order_key) AS total_orders
FROM dw.fact_order_item f
JOIN dw.dim_delivery d
    ON f.delivery_key = d.delivery_key
JOIN dw.dim_delivery_status ds
    ON d.delivery_status_key = ds.delivery_status_key
GROUP BY ds.delivery_status_name;