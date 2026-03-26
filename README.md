# 📦 **DataCo Supply Chain Analytics**

🚀 **End-to-End Data Engineering + Data Analytics Project**  
*(SQL Server | Snowflake Schema | Power BI)*

---

## 📊 **Dashboard Preview**

![Dashboard](powerbi/assets/dashboard_overview.png)

---

## 📌 **Project Overview**

This project simulates a **real-world supply chain analytics pipeline** where operational data is collected, processed, modeled, and visualized to generate actionable business insights.

The goal is to analyze **delivery performance, operational efficiency, and profitability** by building a complete end-to-end data workflow.

---

## 🏗️ **Project Architecture**

Raw Dataset (CSV) → SQL Server (Raw Layer) → Staging (Data Cleaning) → Data Warehouse (Snowflake Schema) → Analytics Views → Power BI Dashboard

---

## 🛠️ **Tech Stack**

- SQL Server (SSMS)  
- Snowflake Schema Data Modeling  
- SQL (Data Transformation & Analysis)  
- Power BI (DAX, Visualization)  
- GitHub (Version Control)  

---

## ⚙️ **Data Engineering Workflow**

- Imported raw supply chain dataset into SQL Server  
- Cleaned and transformed data using staging tables  
- Designed a **Snowflake schema** for analytical modeling  
- Created dimension and fact tables  
- Built reusable **analytics SQL views** for reporting  

---

## 🧮 **SQL Analysis**

Performed analytical queries to:

- Calculate **late delivery rate** and average delay  
- Identify regions with high delivery inefficiencies  
- Analyze product categories affected by delays  
- Compare revenue vs profit across operations  
- Evaluate shipping mode performance  

---

## 📊 **Power BI Dashboard**

This dashboard provides insights into:

- Delivery performance trends over time  
- Regional fulfillment risk  
- Product category-level delays  
- Shipping mode efficiency  

---

### 🔑 **Key Insights**

- Certain regions experience **consistently higher delivery delays**  
- Specific product categories show **higher operational risk**  
- Lower-cost shipping methods contribute to **increased delays**  
- Delivery inefficiencies may lead to **reduced profit margins**  

---

## 💼 **Business Impact**

- Helps identify **high-risk operational areas**  
- Supports **logistics and shipping optimization**  
- Improves **decision-making using data insights**  
- Enables **profitability-focused supply chain strategies**  

---

## ▶️ **How to Run**

1. Clone the repository  
2. Load dataset into SQL Server  
3. Execute SQL scripts to build warehouse  
4. Run analytics queries  
5. Open Power BI dashboard file  

---

## 🧠 **Skills Demonstrated**

- Data Warehouse Design  
- Snowflake Schema Modeling  
- SQL Data Transformation  
- Business Analytics  
- Power BI Dashboard Development  
- Data Storytelling  

---

## 📁 **Project Structure**

```text
dataco-supply-chain-analytics
│
├── docs
├── sql
│   ├── raw
│   ├── staging
│   ├── dw
│   └── analytics
├── powerbi
│   └── assets
└── data
