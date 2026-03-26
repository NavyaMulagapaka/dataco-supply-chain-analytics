--Creating database
CREATE DATABASE dataco_supply_chain_dw;
GO

USE dataco_supply_chain_dw;
GO

--Creating Schemas
CREATE SCHEMA raw;
GO

CREATE SCHEMA stg;
GO

CREATE SCHEMA dw;
GO

---Creating table for raw dataset in the raw schema
CREATE TABLE raw.dataco_orders_raw (
    transaction_type             VARCHAR(50),
    delivery_status              VARCHAR(50),
    late_delivery_risk           INT,
    category_id                  INT,
    category_name                VARCHAR(100),
    customer_id                  INT,
    customer_fname               VARCHAR(100),
    customer_lname               VARCHAR(100),
    customer_email               VARCHAR(255),
    customer_password            VARCHAR(255),
    customer_segment             VARCHAR(50),
    customer_street              VARCHAR(255),
    customer_city                VARCHAR(100),
    customer_state               VARCHAR(100),
    customer_country             VARCHAR(100),
    customer_zipcode             VARCHAR(20),
    latitude                     DECIMAL(10,6),
    longitude                    DECIMAL(10,6),
    department_id                INT,
    department_name              VARCHAR(100),
    order_id                     INT,
    order_city                   VARCHAR(100),
    order_country                VARCHAR(100),
    order_region                 VARCHAR(100),
    order_state                  VARCHAR(100),
    order_status                 VARCHAR(50),
    order_item_id                INT,
    product_card_id              INT,
    product_name                 VARCHAR(255),
    product_image                VARCHAR(1000),
    product_status               INT,
    shipping_mode                VARCHAR(50),
    days_for_shipping_real       INT,
    days_for_shipment_scheduled  INT,
    shipping_date                DATETIME,
    order_date                   DATETIME,
    benefit_per_order            DECIMAL(18,2),
    sales_per_customer           DECIMAL(18,2),
    order_item_discount          DECIMAL(18,2),
    order_item_discount_rate     DECIMAL(18,4),
    order_item_product_price     DECIMAL(18,2),
    order_item_profit_ratio      DECIMAL(18,4),
    order_item_quantity          INT,
    sales                        DECIMAL(18,2),
    order_item_total             DECIMAL(18,2),
    order_profit_per_order       DECIMAL(18,2),
    product_price                DECIMAL(18,2)
);

DROP TABLE raw.dataco_orders_raw;

SELECT TOP 100 * FROM raw.DataCoSupplyChainDataset;

-----------Staging area
-----------Creating a new staging table 
CREATE TABLE stg.order_item_clean (
    order_item_id INT,
    order_id INT,
    customer_id INT,
    product_card_id INT,

    product_name VARCHAR(255),
    product_image VARCHAR(1000),
    product_status INT,
    category_id INT,
    category_name VARCHAR(100),
    department_id INT,
    department_name VARCHAR(100),

    customer_fname VARCHAR(100),
    customer_lname VARCHAR(100),
    customer_email VARCHAR(255),
    customer_password VARCHAR(255),
    customer_segment VARCHAR(50),
    customer_street VARCHAR(255),
    customer_city VARCHAR(100),
    customer_state VARCHAR(100),
    customer_country VARCHAR(100),
    customer_zipcode VARCHAR(20),
    latitude DECIMAL(10,6),
    longitude DECIMAL(10,6),

    order_status VARCHAR(50),
    order_city VARCHAR(100),
    order_state VARCHAR(100),
    order_country VARCHAR(100),
    order_region VARCHAR(100),

    transaction_type VARCHAR(50),
    delivery_status VARCHAR(50),
    late_delivery_risk INT,
    shipping_mode VARCHAR(50),

    order_date DATETIME,
    shipping_date DATETIME,

    days_for_shipping_real INT,
    days_for_shipment_scheduled INT,
    benefit_per_order DECIMAL(18,2),
    sales_per_customer DECIMAL(18,2),
    order_item_discount DECIMAL(18,2),
    order_item_discount_rate DECIMAL(18,4),
    order_item_product_price DECIMAL(18,2),
    order_item_profit_ratio DECIMAL(18,4),
    order_item_quantity INT,
    sales DECIMAL(18,2),
    order_item_total DECIMAL(18,2),
    order_profit_per_order DECIMAL(18,2),
    product_price DECIMAL(18,2)
);


-----Inserting values into the newly created table


INSERT INTO stg.order_item_clean (
    order_item_id,
    order_id,
    customer_id,
    product_card_id,

    product_name,
    product_image,
    product_status,
    category_id,
    category_name,
    department_id,
    department_name,

    customer_fname,
    customer_lname,
    customer_email,
    customer_password,
    customer_segment,
    customer_street,
    customer_city,
    customer_state,
    customer_country,
    customer_zipcode,
    latitude,
    longitude,

    order_status,
    order_city,
    order_state,
    order_country,
    order_region,

    transaction_type,
    delivery_status,
    late_delivery_risk,
    shipping_mode,

    order_date,
    shipping_date,

    days_for_shipping_real,
    days_for_shipment_scheduled,
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
    TRY_CAST(order_item_id AS INT),
    TRY_CAST(order_id AS INT),
    TRY_CAST(customer_id AS INT),
    TRY_CAST(product_card_id AS INT),

    product_name,
    product_image,
    TRY_CAST(product_status AS INT),
    TRY_CAST(category_id AS INT),
    category_name,
    TRY_CAST(department_id AS INT),
    department_name,

    customer_fname,
    customer_lname,
    customer_email,
    customer_password,
    customer_segment,
    customer_street,
    customer_city,
    customer_state,
    customer_country,
   TRY_CAST(customer_zipcode AS VARCHAR(20)) AS customer_zipcode,
    TRY_CAST(latitude AS DECIMAL(10,6)),
    TRY_CAST(longitude AS DECIMAL(10,6)),

    order_status,
    order_city,
    order_state,
    order_country,
    order_region,

    LTRIM(RTRIM([Type])) AS transaction_type,
    delivery_status,
    TRY_CAST(late_delivery_risk AS INT),
    shipping_mode,

    TRY_CAST(order_date_DateOrders AS DATETIME),
    TRY_CAST(shipping_date_DateOrders AS DATETIME),

    TRY_CAST(days_for_shipping_real AS INT),
    TRY_CAST(days_for_shipment_scheduled AS INT),
    TRY_CAST(benefit_per_order AS DECIMAL(18,2)),
    TRY_CAST(sales_per_customer AS DECIMAL(18,2)),
    TRY_CAST(order_item_discount AS DECIMAL(18,2)),
    TRY_CAST(order_item_discount_rate AS DECIMAL(18,4)),
    TRY_CAST(order_item_product_price AS DECIMAL(18,2)),
    TRY_CAST(order_item_profit_ratio AS DECIMAL(18,4)),
    TRY_CAST(order_item_quantity AS INT),
    TRY_CAST(sales AS DECIMAL(18,2)),
    TRY_CAST(order_item_total AS DECIMAL(18,2)),
    TRY_CAST(order_profit_per_order AS DECIMAL(18,2)),
    TRY_CAST(product_price AS DECIMAL(18,2))

FROM raw.DataCoSupplyChainDataset;

----Validation queries after loading
SELECT COUNT(*) AS raw_count
FROM raw.DataCoSupplyChainDataset;

SELECT COUNT(*) AS stg_count
FROM stg.order_item_clean;

-----------Critical null checks
SELECT COUNT(*) AS null_order_item_id
FROM stg.order_item_clean
WHERE order_item_id IS NULL;

SELECT COUNT(*) AS null_order_id
FROM stg.order_item_clean
WHERE order_id IS NULL;

SELECT COUNT(*) AS null_customer_id
FROM stg.order_item_clean
WHERE customer_id IS NULL;

SELECT COUNT(*) AS null_product_card_id
FROM stg.order_item_clean
WHERE product_card_id IS NULL;

---------------Duplicate grain check
SELECT order_item_id, COUNT(*) AS cnt
FROM stg.order_item_clean
GROUP BY order_item_id
HAVING COUNT(*) > 1;

--------Date check
SELECT TOP 20 order_date, shipping_date
FROM stg.order_item_clean;

--------Numeric check
SELECT TOP 20 sales, order_item_total, product_price, order_item_discount
FROM stg.order_item_clean;

----------Creation of dimension tables
CREATE TABLE dw.dim_department (
department_key INT IDENTITY(1,1) PRIMARY KEY,
department_id INT NOT NULL,
department_name VARCHAR(100) NOT NULL);

CREATE TABLE dw.dim_category(
category_key INT IDENTITY(1,1) PRIMARY KEY,
category_id INT NOT NULL,
category_name VARCHAR(100) NOT NULL,
department_key INT NOT NULL,
CONSTRAINT fk_dim_category_department 
FOREIGN KEY(department_key) REFERENCES dw.dim_department(department_key));

CREATE TABLE dw.dim_product(
product_key INT IDENTITY(1,1) PRIMARY KEY,
product_card_id INT NOT NULL,
product_name VARCHAR(255) NOT NULL,
product_image VARCHAR(1000) NOT NULL,
category_key INT NOT NULL,
CONSTRAINT fk_dim_product_category
FOREIGN KEY(category_key) REFERENCES dw.dim_category(category_key));

----Intially dropping constraint then dropping tables- doin this
----becasue made an error while inserting values
ALTER TABLE dw.dim_category 
DROP CONSTRAINT fk_dim_category_department;

ALTER TABLE dw.dim_product
DROP CONSTRAINT fk_dim_product_category;

DROP TABLE dw.dim_department;

DROP TABLE dw.dim_category;

DROP TABLE dw.dim_product;

---inserting values into created dimnesion tables
INSERT INTO dw.dim_department (
    department_id,
    department_name
)
SELECT DISTINCT
    department_id,
    department_name
FROM stg.order_item_clean
WHERE department_id IS NOT NULL
  AND department_name IS NOT NULL;
-----------------

INSERT INTO dw.dim_category (
    category_id,
    category_name,
    department_key
)
SELECT DISTINCT
    s.category_id,
    s.category_name,
    d.department_key
FROM stg.order_item_clean s
JOIN dw.dim_department d
    ON s.department_id = d.department_id
   AND s.department_name = d.department_name
WHERE s.category_id IS NOT NULL
  AND s.category_name IS NOT NULL;
------------
INSERT INTO dw.dim_product (
    product_card_id,
    product_name,
    product_image,
    category_key
)
SELECT DISTINCT
    s.product_card_id,
    s.product_name,
    s.product_image,
    c.category_key
FROM stg.order_item_clean s
JOIN dw.dim_category c
    ON s.category_id = c.category_id
   AND s.category_name = c.category_name
WHERE s.product_card_id IS NOT NULL
  AND s.product_name IS NOT NULL;

