
USE dataco_supply_chain_dw;
----------Customer dimension tables
CREATE TABLE dw.dim_customer_segment (
    customer_segment_key INT IDENTITY(1,1) PRIMARY KEY,
    customer_segment_name VARCHAR(50) NOT NULL
);

CREATE TABLE dw.dim_customer_location (
    customer_location_key INT IDENTITY(1,1) PRIMARY KEY,
    customer_street VARCHAR(255) NULL,
    customer_city VARCHAR(100) NULL,
    customer_state VARCHAR(100) NULL,
    customer_country VARCHAR(100) NULL,
    customer_zipcode VARCHAR(20) NULL,
    latitude DECIMAL(10,6) NULL,
    longitude DECIMAL(10,6) NULL
);

CREATE TABLE dw.dim_customer (
    customer_key INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT NOT NULL,
    customer_fname VARCHAR(100) NULL,
    customer_lname VARCHAR(100) NULL,
    customer_email VARCHAR(255) NULL,
    customer_password VARCHAR(255) NULL,
    customer_segment_key INT NOT NULL,
    customer_location_key INT NOT NULL,
    CONSTRAINT fk_dim_customer_segment
        FOREIGN KEY (customer_segment_key) REFERENCES dw.dim_customer_segment(customer_segment_key),
    CONSTRAINT fk_dim_customer_location
        FOREIGN KEY (customer_location_key) REFERENCES dw.dim_customer_location(customer_location_key)
);

----------Inserting values into customer dimension tables
INSERT INTO dw.dim_customer_segment (
    customer_segment_name
)
SELECT DISTINCT
    customer_segment
FROM stg.order_item_clean
WHERE customer_segment IS NOT NULL;


INSERT INTO dw.dim_customer_location (
    customer_street,
    customer_city,
    customer_state,
    customer_country,
    customer_zipcode,
    latitude,
    longitude
)
SELECT DISTINCT
    customer_street,
    customer_city,
    customer_state,
    customer_country,
    customer_zipcode,
    latitude,
    longitude
FROM stg.order_item_clean
WHERE customer_city IS NOT NULL
   OR customer_state IS NOT NULL
   OR customer_country IS NOT NULL;


INSERT INTO dw.dim_customer (
    customer_id,
    customer_fname,
    customer_lname,
    customer_email,
    customer_password,
    customer_segment_key,
    customer_location_key
)
SELECT
    s.customer_id,
    MAX(s.customer_fname) AS customer_fname,
    MAX(s.customer_lname) AS customer_lname,
    MAX(s.customer_email) AS customer_email,
    MAX(s.customer_password) AS customer_password,
    seg.customer_segment_key,
    loc.customer_location_key
FROM stg.order_item_clean s
JOIN dw.dim_customer_segment seg
    ON s.customer_segment = seg.customer_segment_name
JOIN dw.dim_customer_location loc
    ON ISNULL(s.customer_street, '') = ISNULL(loc.customer_street, '')
   AND ISNULL(s.customer_city, '') = ISNULL(loc.customer_city, '')
   AND ISNULL(s.customer_state, '') = ISNULL(loc.customer_state, '')
   AND ISNULL(s.customer_country, '') = ISNULL(loc.customer_country, '')
   AND ISNULL(s.customer_zipcode, '') = ISNULL(loc.customer_zipcode, '')
   AND ISNULL(s.latitude, 0) = ISNULL(loc.latitude, 0)
   AND ISNULL(s.longitude, 0) = ISNULL(loc.longitude, 0)
WHERE s.customer_id IS NOT NULL
GROUP BY
    s.customer_id,
    seg.customer_segment_key,
    loc.customer_location_key;

---------Order dimension tables
CREATE TABLE dw.dim_order_status (
    order_status_key INT IDENTITY(1,1) PRIMARY KEY,
    order_status_name VARCHAR(50) NOT NULL
);

CREATE TABLE dw.dim_order_location (
    order_location_key INT IDENTITY(1,1) PRIMARY KEY,
    order_city VARCHAR(100) NULL,
    order_state VARCHAR(100) NULL,
    order_country VARCHAR(100) NULL,
    order_region VARCHAR(100) NULL
);

CREATE TABLE dw.dim_order (
    order_key INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL,
    order_status_key INT NOT NULL,
    order_location_key INT NOT NULL,
    CONSTRAINT fk_dim_order_status
        FOREIGN KEY (order_status_key) REFERENCES dw.dim_order_status(order_status_key),
    CONSTRAINT fk_dim_order_location
        FOREIGN KEY (order_location_key) REFERENCES dw.dim_order_location(order_location_key)
);

INSERT INTO dw.dim_order_status (
    order_status_name
)
SELECT DISTINCT
    order_status
FROM stg.order_item_clean
WHERE order_status IS NOT NULL;

INSERT INTO dw.dim_order_location (
    order_city,
    order_state,
    order_country,
    order_region
)
SELECT DISTINCT
    order_city,
    order_state,
    order_country,
    order_region
FROM stg.order_item_clean
WHERE order_city IS NOT NULL
   OR order_state IS NOT NULL
   OR order_country IS NOT NULL
   OR order_region IS NOT NULL;

INSERT INTO dw.dim_order (
    order_id,
    order_status_key,
    order_location_key
)
SELECT
    s.order_id,
    st.order_status_key,
    loc.order_location_key
FROM stg.order_item_clean s
JOIN dw.dim_order_status st
    ON s.order_status = st.order_status_name
JOIN dw.dim_order_location loc
    ON ISNULL(s.order_city, '') = ISNULL(loc.order_city, '')
   AND ISNULL(s.order_state, '') = ISNULL(loc.order_state, '')
   AND ISNULL(s.order_country, '') = ISNULL(loc.order_country, '')
   AND ISNULL(s.order_region, '') = ISNULL(loc.order_region, '')
WHERE s.order_id IS NOT NULL
GROUP BY
    s.order_id,
    st.order_status_key,
    loc.order_location_key;

------delivery dimension tables and shipping mode
CREATE TABLE dw.dim_delivery_status (
    delivery_status_key INT IDENTITY(1,1) PRIMARY KEY,
    delivery_status_name VARCHAR(50) NOT NULL
);

CREATE TABLE dw.dim_transaction_type (
    transaction_type_key INT IDENTITY(1,1) PRIMARY KEY,
    transaction_type_name VARCHAR(50) NOT NULL
);

CREATE TABLE dw.dim_delivery (
    delivery_key INT IDENTITY(1,1) PRIMARY KEY,
    late_delivery_risk INT NOT NULL,
    delivery_status_key INT NOT NULL,
    transaction_type_key INT NOT NULL,
    CONSTRAINT fk_dim_delivery_status
        FOREIGN KEY (delivery_status_key) REFERENCES dw.dim_delivery_status(delivery_status_key),
    CONSTRAINT fk_dim_delivery_transaction_type
        FOREIGN KEY (transaction_type_key) REFERENCES dw.dim_transaction_type(transaction_type_key)
);

CREATE TABLE dw.dim_shipping_mode (
    shipping_mode_key INT IDENTITY(1,1) PRIMARY KEY,
    shipping_mode_name VARCHAR(50) NOT NULL
);

INSERT INTO dw.dim_delivery_status (
    delivery_status_name
)
SELECT DISTINCT
    delivery_status
FROM stg.order_item_clean
WHERE delivery_status IS NOT NULL;

INSERT INTO dw.dim_transaction_type (
    transaction_type_name
)
SELECT DISTINCT
    transaction_type
FROM stg.order_item_clean
WHERE transaction_type IS NOT NULL;

INSERT INTO dw.dim_delivery (
    late_delivery_risk,
    delivery_status_key,
    transaction_type_key
)
SELECT DISTINCT
    s.late_delivery_risk,
    ds.delivery_status_key,
    tt.transaction_type_key
FROM stg.order_item_clean s
JOIN dw.dim_delivery_status ds
    ON s.delivery_status = ds.delivery_status_name
JOIN dw.dim_transaction_type tt
    ON s.transaction_type = tt.transaction_type_name
WHERE s.late_delivery_risk IS NOT NULL
  AND s.delivery_status IS NOT NULL
  AND s.transaction_type IS NOT NULL;

  INSERT INTO dw.dim_shipping_mode (
    shipping_mode_name
)
SELECT DISTINCT
    shipping_mode
FROM stg.order_item_clean
WHERE shipping_mode IS NOT NULL;

-------Date dimension tables
CREATE TABLE dw.dim_year (
    year_key INT IDENTITY(1,1) PRIMARY KEY,
    year_number INT NOT NULL
);

CREATE TABLE dw.dim_quarter (
    quarter_key INT IDENTITY(1,1) PRIMARY KEY,
    quarter_number INT NOT NULL,
    year_key INT NOT NULL,
    CONSTRAINT fk_dim_quarter_year
        FOREIGN KEY (year_key) REFERENCES dw.dim_year(year_key)
);

CREATE TABLE dw.dim_month (
    month_key INT IDENTITY(1,1) PRIMARY KEY,
    month_number INT NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    quarter_key INT NOT NULL,
    CONSTRAINT fk_dim_month_quarter
        FOREIGN KEY (quarter_key) REFERENCES dw.dim_quarter(quarter_key)
);

CREATE TABLE dw.dim_date (
    date_key INT IDENTITY(1,1) PRIMARY KEY,
    full_date DATE NOT NULL,
    day_number INT NOT NULL,
    day_name VARCHAR(20) NOT NULL,
    week_number INT NOT NULL,
    month_key INT NOT NULL,
    CONSTRAINT fk_dim_date_month
        FOREIGN KEY (month_key) REFERENCES dw.dim_month(month_key)
);

INSERT INTO dw.dim_year (
    year_number
)
SELECT DISTINCT
    YEAR(d.full_date) AS year_number
FROM (
    SELECT CAST(order_date AS DATE) AS full_date
    FROM stg.order_item_clean
    WHERE order_date IS NOT NULL

    UNION

    SELECT CAST(shipping_date AS DATE) AS full_date
    FROM stg.order_item_clean
    WHERE shipping_date IS NOT NULL
) d;

INSERT INTO dw.dim_quarter (
    quarter_number,
    year_key
)
SELECT DISTINCT
    DATEPART(QUARTER, d.full_date) AS quarter_number,
    y.year_key
FROM (
    SELECT CAST(order_date AS DATE) AS full_date
    FROM stg.order_item_clean
    WHERE order_date IS NOT NULL

    UNION

    SELECT CAST(shipping_date AS DATE) AS full_date
    FROM stg.order_item_clean
    WHERE shipping_date IS NOT NULL
) d
JOIN dw.dim_year y
    ON YEAR(d.full_date) = y.year_number;

INSERT INTO dw.dim_month (
    month_number,
    month_name,
    quarter_key
)
SELECT DISTINCT
    MONTH(d.full_date) AS month_number,
    DATENAME(MONTH, d.full_date) AS month_name,
    q.quarter_key
FROM (
    SELECT CAST(order_date AS DATE) AS full_date
    FROM stg.order_item_clean
    WHERE order_date IS NOT NULL

    UNION

    SELECT CAST(shipping_date AS DATE) AS full_date
    FROM stg.order_item_clean
    WHERE shipping_date IS NOT NULL
) d
JOIN dw.dim_quarter q
    ON DATEPART(QUARTER, d.full_date) = q.quarter_number
JOIN dw.dim_year y
    ON q.year_key = y.year_key
   AND YEAR(d.full_date) = y.year_number;

INSERT INTO dw.dim_date (
    full_date,
    day_number,
    day_name,
    week_number,
    month_key
)
SELECT DISTINCT
    d.full_date,
    DAY(d.full_date) AS day_number,
    DATENAME(WEEKDAY, d.full_date) AS day_name,
    DATEPART(WEEK, d.full_date) AS week_number,
    m.month_key
FROM (
    SELECT CAST(order_date AS DATE) AS full_date
    FROM stg.order_item_clean
    WHERE order_date IS NOT NULL

    UNION

    SELECT CAST(shipping_date AS DATE) AS full_date
    FROM stg.order_item_clean
    WHERE shipping_date IS NOT NULL
) d
JOIN dw.dim_month m
    ON MONTH(d.full_date) = m.month_number
JOIN dw.dim_quarter q
    ON m.quarter_key = q.quarter_key
JOIN dw.dim_year y
    ON q.year_key = y.year_key
   AND YEAR(d.full_date) = y.year_number;

---SELECT TOP 10* FROM dw.dim_date;


---------Fact table

CREATE TABLE dw.fact_order_item(
order_item_key INT IDENTITY(1,1) PRIMARY KEY,
order_item_id INT NOT NULL,

order_key INT NOT NULL,
customer_key INT NOT NULL,
product_key INT NOT NULL,
delivery_key INT NOT NULL,
shipping_mode_key INT NOT NULL,
order_date_key INT NOT NULL,
shipping_date_key INT NOT NULL,

days_shipping_real INT NOT NULL,
days_shipment_scheduled INT NOT NULL,
benefit_per_order DECIMAL(18,2),
sales_per_customer DECIMAL(18,2),
order_item_discount DECIMAL(18,2),
order_item_discount_rate DECIMAL(18,2),
order_item_product_price DECIMAL(18,2),
order_item_profit_ratio DECIMAL(18,2),
order_item_quantity INT ,
sales DECIMAL(18,2),
order_item_total DECIMAL(18,2),
order_profit_per_order DECIMAL(18,2),
product_price DECIMAL(18,2)

CONSTRAINT fk_fact_order
        FOREIGN KEY (order_key) REFERENCES dw.dim_order(order_key),
CONSTRAINT fk_fact_customer
        FOREIGN KEY (customer_key) REFERENCES dw.dim_customer(customer_key),

CONSTRAINT fk_fact_product
        FOREIGN KEY (product_key) REFERENCES dw.dim_product(product_key),

CONSTRAINT fk_fact_delivery
        FOREIGN KEY (delivery_key) REFERENCES dw.dim_delivery(delivery_key),

CONSTRAINT fk_fact_shipping
        FOREIGN KEY (shipping_mode_key) REFERENCES dw.dim_shipping_mode(shipping_mode_key),

CONSTRAINT fk_fact_order_date
        FOREIGN KEY (order_date_key) REFERENCES dw.dim_date(date_key),

CONSTRAINT fk_fact_shipping_date
        FOREIGN KEY (shipping_date_key) REFERENCES dw.dim_date(date_key)
);

ALTER TABLE dw.fact_order_item
DROP COLUMN customer_location_key;

INSERT INTO dw.fact_order_item (
    order_item_id,
    order_key,
    customer_key,
    product_key,
    delivery_key,
    shipping_mode_key,
    order_date_key,
    shipping_date_key,
    days_shipping_real,
    days_shipment_scheduled,
    benefit_per_order,
    sales_per_customer,
    order_item_discount,
    order_item_discount_rate,
    order_item_product_price,
    order_item_profit_ratio,
    order_item_quantity,
    sales,
    order_item_total,
    order_profit_per_order,
    product_price
)

SELECT
    s.order_item_id,
    o.order_key,
    c.customer_key,
    p.product_key,
    d.delivery_key,
    sm.shipping_mode_key,
    od.date_key,
    sd.date_key,
    s.days_for_shipping_real,
    s.days_for_shipment_scheduled,
    s.benefit_per_order,
    s.sales_per_customer,
    s.order_item_discount,
    s.order_item_discount_rate,
    s.order_item_product_price,
    s.order_item_profit_ratio,
    s.order_item_quantity,
    s.sales,
    s.order_item_total,
    s.order_profit_per_order,
    s.product_price

FROM stg.order_item_clean s

JOIN dw.dim_order o
    ON s.order_id = o.order_id

JOIN dw.dim_customer c
    ON s.customer_id = c.customer_id

JOIN dw.dim_product p
    ON s.product_card_id = p.product_card_id

JOIN dw.dim_shipping_mode sm
    ON s.shipping_mode = sm.shipping_mode_name

JOIN dw.dim_delivery_status ds
    ON s.delivery_status = ds.delivery_status_name

JOIN dw.dim_transaction_type tt
    ON s.transaction_type = tt.transaction_type_name

JOIN dw.dim_delivery d
    ON s.late_delivery_risk = d.late_delivery_risk
   AND d.delivery_status_key = ds.delivery_status_key
   AND d.transaction_type_key = tt.transaction_type_key

JOIN dw.dim_date od
    ON CAST(s.order_date AS DATE) = od.full_date

JOIN dw.dim_date sd
    ON CAST(s.shipping_date AS DATE) = sd.full_date

WHERE s.order_item_id IS NOT NULL;

SELECT TOP 20* FROM dw.fact_order_item;

SELECT order_item_id, COUNT(*)
FROM dw.fact_order_item
GROUP BY order_item_id
HAVING COUNT(*) > 1;


SELECT COUNT(*) FROM stg.order_item_clean;
SELECT COUNT(*) FROM dw.fact_order_item;


SELECT
    y.year_number,
    SUM(f.sales) AS total_sales
FROM dw.fact_order_item f
JOIN dw.dim_date d
    ON f.order_date_key = d.date_key
JOIN dw.dim_month m
    ON d.month_key = m.month_key
JOIN dw.dim_quarter q
    ON m.quarter_key = q.quarter_key
JOIN dw.dim_year y
    ON q.year_key = y.year_key
GROUP BY y.year_number
ORDER BY y.year_number;

-------------Data Quality Checks
----1. Completeness checks
SELECT COUNT(*) 
FROM dw.fact_order_item
WHERE order_key IS NULL
OR customer_key IS NULL
OR product_key IS NULL;

---2. Uniqueness Checks
SELECT order_item_id, COUNT(*)
FROM dw.fact_order_item
GROUP BY order_item_id
HAVING COUNT(*) > 1;

----3. Consistency Checks
SELECT COUNT(*) FROM raw.DataCoSupplyChainDataset;
SELECT COUNT(*) FROM stg.order_item_clean;
SELECT COUNT(*) FROM dw.fact_order_item;

----4. Referential Integrity Checks
SELECT *
FROM dw.fact_order_item f
LEFT JOIN dw.dim_product p
ON f.product_key = p.product_key
WHERE p.product_key IS NULL;

----5. Range / Validity Checks--Check negative values.
SELECT *
FROM dw.fact_order_item
WHERE sales < 0;

----Unrealistic shipping time 
SELECT *
FROM dw.fact_order_item
WHERE days_shipping_real > 60;

----6. Business Logic Checks
SELECT *
FROM dw.fact_order_item
WHERE days_shipping_real < days_shipment_scheduled;





