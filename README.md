# 🛒 Amazon India Sales Analysis

> End-to-end data analytics project · Fashion e-commerce · April – June 2022
---

## 👤 Author

**ROHAN KUMAR**
📧 rk7038303@gmail.com
🔗 [LinkedIn Profile](https://www.linkedin.com/in/YOUR-LINKEDIN-USERNAME)
💼 Fresher Data Analyst | Excel · PostgreSQL · Power BI

---

## 📌 Overview

This project performs a **full-stack analysis** of Amazon India's fashion e-commerce sales data using:
- **Microsoft Excel** — data cleaning, transformation, and preparation
- **PostgreSQL** — 17 business-driven SQL queries
- **Power BI** — interactive multi-visual dashboard

The goal is to extract actionable business intelligence from 128,975 raw transactional records and present findings in a recruiter-ready format.

### Key Metrics at a Glance

| Metric | Value |
|---|---|
| Total Orders | 1,28,975 |
| Total Revenue | ₹7.34 Crore |
| Average Order Value | ₹609.83 |
| Cancellation Rate | 13.32% |
| Top Category | Set (₹3.67 Cr) |
| Top State | Maharashtra (₹1.24 Cr) |
| Best Month | April 2022 (₹2.70 Cr) |
| Amazon Fulfilled Orders | 65.1% |

---

## 📁 Project Structure

```
amazon-sales-analysis/
├── README.md
├── data/
│   └── AMZON_SALES.csv                     # Cleaned dataset (128,975 rows × 21 columns)
├── sql/
│   └── sql_analysis.sql                    # 17 analytical SQL queries
├── dashboard/
│   └── amazon_sales_dashboard_New.pbix     # Power BI dashboard file
└── report/
    └── Amazon_Sales_Analysis_Report.docx   # Full portfolio report
```

---

## 🛠️ Tech Stack

| Tool | Purpose |
|---|---|
| **Microsoft Excel** | Data cleaning, null handling, column formatting, data type correction, transformation |
| **PostgreSQL** | Data extraction, aggregation, CTEs, window functions (RANK, NTILE) |
| **Power BI** | KPI cards, bar/donut/line charts, map visual, dynamic slicers |
| **Dataset** | 128,975 rows · 21 columns · Amazon India fashion orders (Apr–Jun 2022) |

---

## 🗃️ Dataset Overview

Each row represents one order with the following key attributes:

| Field Group | Key Columns | Description |
|---|---|---|
| Order Identity | Order ID, Date, Status | Unique reference, date, fulfilment status |
| Product Details | Category, SKU, Style, Size | Fashion classification and size |
| Shipping Info | ship-city, ship-state, service-level | Delivery location and method |
| Financials | Amount, Qty | Order value (INR) and units sold |
| Fulfilment | Fulfilment, B2B, fulfilled-by | Amazon vs Merchant; B2B vs B2C |

---

## ⚙️ Setup & Usage

### 1 — Data Cleaning in Excel

The raw CSV was cleaned and transformed in Microsoft Excel before loading into PostgreSQL:

- **Removed duplicates** — identified and dropped duplicate Order IDs
- **Handled null values** — blank Amount and Qty fields filled or flagged
- **Standardised text columns** — trimmed whitespace in ship-city, ship-state, Category
- **Corrected data types** — Date column formatted to `DD-MM-YYYY`, Amount to number
- **Added helper column** — `Order_Month` extracted from Date using `=TEXT(A2,"MMM-YY")`
- **Filtered junk rows** — removed rows with invalid or missing Order IDs
- **Validated Status values** — standardised casing (e.g. "cancelled" → "Cancelled")

### 2 — Import the cleaned dataset into PostgreSQL

```sql
-- Create the database
CREATE DATABASE amazon_db;

-- Create the table
CREATE TABLE amazon_sales (
    order_id        TEXT,
    order_date      DATE,
    status          TEXT,
    category        TEXT,
    size            TEXT,
    qty             INTEGER,
    amount          NUMERIC(10,2),
    ship_city       TEXT,
    ship_state      TEXT,
    ship_level      TEXT,
    is_b2b          BOOLEAN,
    fulfilled_by    TEXT,
    order_month     TEXT
);

-- Import CSV using COPY command
COPY amazon_sales
FROM '/your-path/AMZON_SALES.csv'
DELIMITER ','
CSV HEADER
ENCODING 'UTF8';
```

### 3 — Run the SQL Analysis

Open `sql/sql_analysis.sql` in **pgAdmin** and execute all 17 queries sequentially.
Results can be exported as CSV and connected to Power BI via the PostgreSQL connector.

### 4 — Open the Power BI Dashboard

1. Download and install [Power BI Desktop](https://powerbi.microsoft.com/desktop/) (free)
2. Open `dashboard/amazon_sales_dashboard_New.pbix`
3. If prompted, reconnect the data source:
   - Get Data → PostgreSQL
   - Server: `localhost`
   - Database: `amazon_db`

---

## 📊 SQL Queries — Business Questions Answered

| # | Business Question | SQL Technique |
|---|---|---|
| Q1 | Total number of orders | COUNT(*) |
| Q2 | Total revenue | SUM() |
| Q3 | Orders by status | GROUP BY + ORDER BY |
| Q4 | Unique product categories | DISTINCT |
| Q5 | Average order value | AVG() |
| Q6 | B2B vs B2C orders | GROUP BY on boolean column |
| Q7 | Month with highest orders | GROUP BY + LIMIT 1 |
| Q8 | Top 10 states by revenue | GROUP BY + ORDER BY + LIMIT |
| Q9 | Revenue & units sold per category | Multi-aggregate GROUP BY |
| Q10 | Overall cancellation rate % | CASE WHEN + ROUND() |
| Q11 | Expedited vs standard shipping | GROUP BY on service level |
| Q12 | Monthly revenue % share | GROUP BY + Window Function |
| Q13 | Top 5 cities by shipped orders | WHERE + GROUP BY + LIMIT |
| Q14 | Amazon vs merchant fulfilment | GROUP BY + multi-aggregate |
| Q15 | Cancellation rate by category | CASE WHEN + GROUP BY |
| Q16 | State revenue tier classification | CTE + NTILE(3) window function |
| Q17 | Top-performing category per month | CTE + RANK() + PARTITION BY |

---

## 📈 Power BI Dashboard

| Visual | Business Question |
|---|---|
| KPI Cards (×4) | Total Orders, Revenue, AOV, Cancellation Rate |
| Clustered Bar Chart | Revenue by Category — identify top/bottom performers |
| Donut Chart | Amazon vs Merchant split; Expedited vs Standard shipping |
| Map Visual | Revenue distribution across Indian states |
| Line / Column Chart | Month-over-month revenue trend |
| Slicers | Filter by Month, Category, State, Fulfilment, Shipping Mode |

---

## 💡 Key Insights & Business Findings

### 1 — Revenue Decline
Revenue fell **18.8%** in just two months: April ₹2.70 Cr → May ₹2.45 Cr → June ₹2.19 Cr.
Requires investigation into seasonal demand and marketing effectiveness.

### 2 — High Cancellation Rate
At **13.32%**, the cancellation rate is well above the fashion e-commerce benchmark of 5–8%.
**Saree (14.69%), Kurta (14.66%), Set (14.60%)** are the highest-risk categories — likely driven by sizing issues or COD drop-offs.

### 3 — Geographic Concentration
**Maharashtra + Karnataka** account for **30.1% of total revenue**.
Top 5 cities by shipped orders: Bengaluru (7,262) › Hyderabad (5,271) › Mumbai (4,158) › Chennai (3,691) › New Delhi (3,660).

### 4 — Fulfilment Performance Gap
**Amazon-fulfilled** orders (65.1% of volume) generated **69.3% of revenue**, confirming higher basket sizes vs Merchant-fulfilled.
**Expedited shipping** dominates at 68.9% of orders and 69.2% of revenue.

### 5 — Category Strategy
**Set** was the #1 revenue category in all 3 months despite having fewer orders than Kurta — higher per-order value drives disproportionate revenue.

### 6 — Untapped B2B Segment
**B2B = only 0.62%** of orders (794 out of 128,975). Significant opportunity to grow bulk/reseller revenue with a dedicated B2B programme.

---

## 📋 Business Problems Solved

| Problem | SQL Queries | Recommendation |
|---|---|---|
| High cancellation rate (13.32%) | Q10, Q15 | Fix size guides, listing quality, COD policy |
| Declining monthly revenue (−18.8%) | Q12, Q17 | Investigate marketing & demand drivers |
| No geographic investment strategy | Q8, Q16 | Tiered state framework via NTILE |
| Merchant vs Amazon fulfilment gap | Q14 | Migrate high-value sellers to FBA |
| Wrong category assumptions | Q9, Q17 | Prioritise Set in ad spend & promotions |
| B2B segment invisible | Q6 | Launch dedicated B2B portal/programme |

---

## 🎯 Skills Demonstrated

- **Microsoft Excel** — Data cleaning, transformation, null handling, text standardisation, date formatting, helper column creation
- **SQL / PostgreSQL (Intermediate–Advanced)** — Aggregations, GROUP BY, HAVING, CASE WHEN, Subqueries, CTEs, Window Functions (NTILE, RANK, PARTITION BY)
- **Data Analysis** — Trend analysis, segmentation, cancellation benchmarking, revenue tiering
- **Data Visualisation** — Power BI KPI cards, map, bar, donut, line charts, slicers
- **Business Communication** — Translating data findings into actionable business recommendations with revenue impact framing

---

## 📄 Report

A full portfolio-ready report (`.docx`) is included in the `/report` folder. It covers:
- Executive summary with KPI cards
- Dataset overview
- All 17 SQL findings with annotated tables
- Power BI dashboard breakdown
- 5 actionable business recommendations
- Skills demonstrated summary

---

## 📜 License

This project is open for **portfolio and educational use**.
Dataset sourced from publicly available Amazon India sales data (Kaggle).
Not affiliated with Amazon.com, Inc.

---

## 🤝 Connect With Me

If you found this project useful or want to collaborate, feel free to connect!

[![LinkedIn](https://www.linkedin.com/in/rohan-kumar-0a34a1256/)

---

*Built as part of a Data Analytics portfolio · Tools: Microsoft Excel · PostgreSQL · Power BI*
