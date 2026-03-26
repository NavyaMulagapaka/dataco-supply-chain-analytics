USE dataco_supply_chain_dw;

----------Solving Business Case Problem
-----1. How big is the late delivery problem?
----Metrcis --> %late deliveries and average delay

---%late delivery
SELECT
ds.delivery_status_name AS deliveryStatus,
COUNT(*) AS orders,
COUNT(*) *100.0/SUM(COUNT(*)) OVER() AS perc
FROM dw.fact_order_item f
JOIN dw.dim_delivery d ON f.delivery_key = d.delivery_key
JOIN dw.dim_delivery_status ds
ON d.delivery_status_key = ds.delivery_status_key
GROUP BY delivery_status_name;

----AVerage Delay
SELECT 
AVG(days_shipping_real - days_shipment_scheduled) AS AverageDelay
FROM dw.fact_order_item ;

---Average delay only for late orders
SELECT 
AVG(days_shipping_real - days_shipment_scheduled) AS avg_late_delay
FROM dw.fact_order_item
WHERE days_shipping_real > days_shipment_scheduled;

---Delay per region distribution
SELECT
ol.order_region,
(days_shipping_real - days_shipment_scheduled) AS delay
FROM dw.fact_order_item f
JOIN dw.dim_order do ON f.order_key = do.order_key
JOIN dw.dim_order_location ol ON do.order_location_key = ol.order_location_key
WHERE days_shipping_real > days_shipment_scheduled
GROUP BY ol.order_region,
days_shipping_real - days_shipment_scheduled
ORDER BY ol.order_region;

----delay days distribution for orders 
SELECT 
(days_shipping_real - days_shipment_scheduled) AS delay,
COUNT(*) AS orders
FROM dw.fact_order_item
WHERE days_shipping_real > days_shipment_scheduled
GROUP BY (days_shipping_real - days_shipment_scheduled)
ORDER BY delay;

----Late delivery rate per region
SELECT 
ol.order_region,
COUNT(CASE 
        WHEN days_shipping_real > days_shipment_scheduled 
        THEN 1 
     END) * 100.0 / COUNT(*) AS late_delivery_rate
FROM dw.fact_order_item f
JOIN dw.dim_order o ON f.order_key = o.order_key
JOIN dw.dim_order_location ol 
ON o.order_location_key = ol.order_location_key
GROUP BY ol.order_region
ORDER BY late_delivery_rate DESC;

----Average delay by region
SELECT 
ol.order_region,
AVG(f.days_shipping_real - f.days_shipment_scheduled) AS averageDelay
FROM dw.fact_order_item f
JOIN dw.dim_order o ON f.order_key = o.order_key
JOIN dw.dim_order_location ol 
ON o.order_location_key = ol.order_location_key
WHERE f.days_shipping_real - f.days_shipment_scheduled > 1
GROUP BY ol.order_region
ORDER BY averageDelay DESC;

SELECT 
ol.order_region,
COUNT(CASE WHEN days_shipping_real > days_shipment_scheduled THEN 1 END) * 100.0
/ COUNT(*) AS late_delivery_rate,
AVG(days_shipping_real - days_shipment_scheduled) AS avg_delay
FROM dw.fact_order_item f
JOIN dw.dim_order o ON f.order_key = o.order_key
JOIN dw.dim_order_location ol
ON o.order_location_key = ol.order_location_key
GROUP BY ol.order_region
ORDER BY late_delivery_rate DESC;

-----Total delayed orders by region
SELECT 
ol.order_region,
COUNT(CASE WHEN f.days_shipping_real > f.days_shipment_scheduled THEN 1 END) AS DelayedOrders
FROM dw.fact_order_item f
JOIN dw.dim_order o ON f.order_key = o.order_key
JOIN dw.dim_order_location ol
ON o.order_location_key = ol.order_location_key
GROUP BY ol.order_region
ORDER BY DelayedOrders DESC;
 


----Late delivery rate by categories OR
----Category sales vs delay rate
SELECT
c.category_name,
COUNT(CASE WHEN ds.delivery_status_name = 'Late delivery' THEN 1 END) * 100.0
/ COUNT(*) AS late_delivery_rate
FROM dw.fact_order_item f
JOIN dw.dim_product p ON f.product_key = p.product_key
JOIN dw.dim_category c ON p.category_key = c.category_key
JOIN dw.dim_delivery dl ON f.delivery_key = dl.delivery_key
JOIN dw.dim_delivery_status ds ON dl.delivery_status_key = ds.delivery_status_key
GROUP BY c.category_name
ORDER BY late_delivery_rate DESC;

------Total delayed orders
SELECT 
COUNT(CASE WHEN f.days_shipping_real > f.days_shipment_scheduled THEN 1 END) AS DelayedOrders
FROM dw.fact_order_item f
JOIN dw.dim_order o ON f.order_key = o.order_key
JOIN dw.dim_order_location ol
ON o.order_location_key = ol.order_location_key;

-----Average profit per order (late vs on time) 
SELECT
ds.delivery_status_name,
AVG(f.order_profit_per_order) AS avg_profit
FROM dw.fact_order_item f
JOIN dw.dim_delivery d ON f.delivery_key = d.delivery_key
JOIN dw.dim_delivery_status ds
ON d.delivery_status_key = ds.delivery_status_key
GROUP BY ds.delivery_status_name;

----Total profit lost due to delays 
WITH profit_metrics AS
(
SELECT 
AVG(CASE 
    WHEN ds.delivery_status_name = 'Shipping on time' 
    THEN order_profit_per_order 
END) AS avg_on_time_profit,

AVG(CASE 
    WHEN ds.delivery_status_name = 'Late delivery' 
    THEN order_profit_per_order 
END) AS avg_late_profit
FROM dw.fact_order_item f
JOIN dw.dim_delivery d ON f.delivery_key = d.delivery_key
JOIN dw.dim_delivery_status ds
ON d.delivery_status_key = ds.delivery_status_key
),

late_orders AS
(
SELECT COUNT(*) AS total_late_orders
FROM dw.fact_order_item f
JOIN dw.dim_delivery d ON f.delivery_key = d.delivery_key
JOIN dw.dim_delivery_status ds
ON d.delivery_status_key = ds.delivery_status_key
WHERE ds.delivery_status_name = 'Late delivery'
)

SELECT 
(total_late_orders * (avg_on_time_profit - avg_late_profit)) 
AS total_profit_lost_due_to_delays
FROM profit_metrics, late_orders;


-----Basic Revenue VS Profit Comparision 
SELECT 
ds.delivery_status_name AS delivery_status,
SUM(f.sales) AS total_revenue,
SUM(f.order_profit_per_order) AS total_profit,
AVG(f.order_profit_per_order) AS avg_profit_per_order
FROM dw.fact_order_item f
JOIN dw.dim_delivery d 
    ON f.delivery_key = d.delivery_key
JOIN dw.dim_delivery_status ds
    ON d.delivery_status_key = ds.delivery_status_key
GROUP BY ds.delivery_status_name
ORDER BY total_revenue DESC;

----Revenue VS profit by Category (profit margin)
SELECT 
c.category_name,
SUM(f.sales) AS total_revenue,
SUM(f.order_profit_per_order) AS total_profit,
(SUM(f.order_profit_per_order) * 100.0 / SUM(f.sales)) AS profit_margin
FROM dw.fact_order_item f
JOIN dw.dim_product p 
    ON f.product_key = p.product_key
JOIN dw.dim_category c 
    ON p.category_key = c.category_key
GROUP BY c.category_name
ORDER BY total_revenue DESC;

---Late delivery rate by shipping mode
SELECT
d.shipping_mode_name AS ShippingMode,
COUNT(CASE WHEN ds.delivery_status_name = 'Late delivery' THEN 1 END) * 100.0
/ COUNT(*) AS late_delivery_rate
FROM dw.fact_order_item f
JOIN dw.dim_shipping_mode d ON
f.shipping_mode_key = d.shipping_mode_key
JOIN dw.dim_delivery dl ON f.delivery_key = dl.delivery_key
JOIN dw.dim_delivery_status ds ON dl.delivery_status_key = ds.delivery_status_key
GROUP BY d.shipping_mode_name
ORDER BY late_delivery_rate DESC;


----AVerage Shipping delay
SELECT 
sm.shipping_mode_name,
COUNT(CASE WHEN days_shipping_real > days_shipment_scheduled THEN 1 END) * 100.0
/ COUNT(*) AS late_delivery_rate,
AVG(days_shipping_real - days_shipment_scheduled) AS avg_delay
FROM dw.fact_order_item f
JOIN dw.dim_shipping_mode sm
ON f.shipping_mode_key = sm.shipping_mode_key
GROUP BY sm.shipping_mode_name
ORDER BY late_delivery_rate DESC;

-----Profit By shipping mode
SELECT 
sm.shipping_mode_name,
SUM(f.order_profit_per_order) AS total_profit
FROM dw.fact_order_item f
JOIN dw.dim_shipping_mode sm
ON f.shipping_mode_key = sm.shipping_mode_key
GROUP BY sm.shipping_mode_name;


