
--  STEP 1: CREATE DATABASE
--  Run this separately in psql or pgAdmin first:
CREATE DATABASE amazon_db;
--    \c amazon_db
-- ============================================================


-- ============================================================
--  STEP 2: CREATE TABLE
-- ============================================================

DROP TABLE IF EXISTS amazon_sales;

CREATE TABLE amazon_sales (
    order_id            VARCHAR(30),
    date                DATE,
    status              VARCHAR(50),
    fulfilment          VARCHAR(30),
    sales_channel       VARCHAR(30),
    ship_service_level  VARCHAR(30),
    style               VARCHAR(50),
    sku                 VARCHAR(50),
    category            VARCHAR(50),
    size                VARCHAR(20),
    asin                VARCHAR(20),
    courier_status      VARCHAR(50),
    qty                 INTEGER,
    currency            VARCHAR(10),
    amount              NUMERIC(12, 2),
    ship_city           VARCHAR(100),
    ship_state          VARCHAR(100),
    ship_postal_code    VARCHAR(20),
    ship_country        VARCHAR(10),
    b2b                 BOOLEAN,
    fulfilled_by        VARCHAR(30),
    order_month         VARCHAR(10)
);


-- ============================================================
--  STEP 3: IMPORT DATA FROM CSV

-- Right-click table → Import/Export Data → select CSV file


-- ============================================================
--  STEP 4: QUICK PREVIEW
-- ============================================================

SELECT * FROM amazon_sales LIMIT 10;


-- ============================================================
--  ANALYTICAL QUERIES — ALL 17
-- ============================================================


-- ----------------------------------------------------------
-- Q1. Total number of orders
-- ----------------------------------------------------------
SELECT COUNT(*) AS total_orders
FROM amazon_sales;


-- ----------------------------------------------------------
-- Q2. Total Revenue
-- ----------------------------------------------------------
SELECT ROUND(SUM(amount)::NUMERIC, 2) AS total_revenue
FROM amazon_sales;


-- ----------------------------------------------------------
-- Q3. Orders by Status
-- ----------------------------------------------------------
SELECT
    status,
    COUNT(*) AS total_orders
FROM amazon_sales
GROUP BY status
ORDER BY total_orders DESC;


-- ----------------------------------------------------------
-- Q4. Unique Product Categories
-- ----------------------------------------------------------
SELECT DISTINCT category
FROM amazon_sales
ORDER BY category;


-- ----------------------------------------------------------
-- Q5. Average Order Value
-- ----------------------------------------------------------
SELECT ROUND(AVG(amount)::NUMERIC, 2) AS avg_order
FROM amazon_sales;


-- ----------------------------------------------------------
-- Q6. How many orders are B2B vs B2C
-- Note: In PostgreSQL, BOOLEAN column stores TRUE/FALSE.
--       MySQL stored 'TRUE'/'FALSE' as string — adjusted here.
-- ----------------------------------------------------------
SELECT
    b2b,
    COUNT(*) AS total_orders
FROM amazon_sales
GROUP BY b2b
ORDER BY total_orders DESC;


-- ----------------------------------------------------------
-- Q7. Month with the highest number of orders
-- ----------------------------------------------------------
SELECT
    order_month,
    COUNT(*) AS total_orders
FROM amazon_sales
GROUP BY order_month
ORDER BY total_orders DESC
LIMIT 1;


-- ----------------------------------------------------------
-- Q8. Top 10 States by Total Revenue
-- Note: MySQL used backtick `ship-state`; PostgreSQL uses
--       double quotes for reserved/special names, but since
--       we renamed the column to ship_state, no quoting needed.
-- ----------------------------------------------------------
SELECT
    ship_state,
    ROUND(SUM(amount)::NUMERIC, 2) AS total_revenue
FROM amazon_sales
GROUP BY ship_state
ORDER BY total_revenue DESC
LIMIT 10;


-- ----------------------------------------------------------
-- Q9. Total Revenue and Units Sold for each Category
-- ----------------------------------------------------------
SELECT
    category,
    ROUND(SUM(amount)::NUMERIC, 2)  AS total_revenue,
    SUM(qty)                         AS total_units_sold,
    ROUND(AVG(amount)::NUMERIC, 2)  AS avg_revenue
FROM amazon_sales
GROUP BY category
ORDER BY total_revenue DESC;


-- ----------------------------------------------------------
-- Q10. Overall Cancellation Rate (%)
-- Note: FILTER clause is the PostgreSQL-native equivalent
--       of MySQL's COUNT(CASE WHEN ... END).
-- ----------------------------------------------------------
SELECT
    ROUND(
        COUNT(*) FILTER (WHERE LOWER(status) = 'cancelled') * 100.0 / COUNT(*),
        2
    ) AS cancellation_rate_pct
FROM amazon_sales;


-- ----------------------------------------------------------
-- Q11. Expedited vs Standard Shipping usage
-- ----------------------------------------------------------
SELECT
    ship_service_level,
    COUNT(*)                         AS total_orders,
    ROUND(AVG(amount)::NUMERIC, 2)  AS avg_order_value,
    ROUND(SUM(amount)::NUMERIC, 2)  AS total_revenue
FROM amazon_sales
GROUP BY ship_service_level
ORDER BY total_orders DESC;


-- ----------------------------------------------------------
-- Q12. Monthly Revenue with % share of total revenue
-- Note: MySQL query was identical to Q11 (likely a copy error).
--       Corrected here to properly show monthly revenue + share.
-- ----------------------------------------------------------
SELECT
    order_month,
    ROUND(SUM(amount)::NUMERIC, 2) AS monthly_revenue,
    ROUND(
        SUM(amount) * 100.0 / SUM(SUM(amount)) OVER (),
        2
    ) AS revenue_share_pct
FROM amazon_sales
GROUP BY order_month
ORDER BY monthly_revenue DESC;


-- ----------------------------------------------------------
-- Q13. Top 5 Cities by number of Shipped orders
-- ----------------------------------------------------------
SELECT
    ship_city,
    COUNT(*) AS total_orders
FROM amazon_sales
WHERE LOWER(status) = 'shipped'
GROUP BY ship_city
ORDER BY total_orders DESC
LIMIT 5;


-- ----------------------------------------------------------
-- Q14. Revenue: Amazon Fulfilled vs Merchant Fulfilled
-- ----------------------------------------------------------
SELECT
    fulfilment,
    COUNT(*)                         AS total_orders,
    ROUND(SUM(amount)::NUMERIC, 2)  AS total_revenue,
    ROUND(AVG(amount)::NUMERIC, 2)  AS avg_revenue
FROM amazon_sales
GROUP BY fulfilment
ORDER BY total_revenue DESC;


-- ----------------------------------------------------------
-- Q15. Cancellation Rate (%) for each Category
-- ----------------------------------------------------------
SELECT
    category,
    COUNT(*)                                                              AS total_orders,
    COUNT(*) FILTER (WHERE LOWER(status) = 'cancelled')                  AS cancelled_orders,
    ROUND(
        COUNT(*) FILTER (WHERE LOWER(status) = 'cancelled') * 100.0 / COUNT(*),
        2
    )                                                                     AS cancellation_rate_pct
FROM amazon_sales
GROUP BY category
ORDER BY cancellation_rate_pct DESC;


-- ----------------------------------------------------------
-- Q16. Classify States into Top / Mid / Low Tier by Revenue
-- Note: NTILE() works the same in PostgreSQL.
--       CASE WHEN syntax is identical.
-- ----------------------------------------------------------
WITH state_revenue AS (
    SELECT
        ship_state,
        SUM(amount)                                    AS total_revenue,
        NTILE(3) OVER (ORDER BY SUM(amount) DESC)      AS tier
    FROM amazon_sales
    GROUP BY ship_state
)
SELECT
    ship_state,
    ROUND(total_revenue::NUMERIC, 2) AS total_revenue,
    CASE tier
        WHEN 1 THEN 'Top Tier'
        WHEN 2 THEN 'Mid Tier'
        WHEN 3 THEN 'Low Tier'
    END AS state_tier
FROM state_revenue
ORDER BY total_revenue DESC;


-- ----------------------------------------------------------
-- Q17. Top Performing Category for each Month
-- Note: RANK() + PARTITION BY works identically in PostgreSQL.
--       MIN(date) used to sort months chronologically.
-- ----------------------------------------------------------
WITH monthly_cat AS (
    SELECT
        order_month,
        MIN(date)                                          AS month_start,
        category,
        ROUND(SUM(amount)::NUMERIC, 2)                    AS revenue,
        RANK() OVER (
            PARTITION BY order_month
            ORDER BY SUM(amount) DESC
        )                                                  AS rnk
    FROM amazon_sales
    GROUP BY order_month, category
)
SELECT
    order_month,
    category,
    revenue
FROM monthly_cat
WHERE rnk = 1
ORDER BY month_start;


-- ============================================================
--  END OF FILE
--  Amazon India Sales Analysis | PostgreSQL Version
--  Tools: Excel · MySQL → PostgreSQL · Power BI
-- ============================================================