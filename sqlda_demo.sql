--SQL for PowerBI_demo
--created by JBroberg; for AStakeholder; on 2023-02-14

--Exploratory
--Repeat sales by customer_id
SELECT customer_id AS repeat_customers
	, COUNT(*) AS sales_per_customer
FROM sales
GROUP BY 1
	HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC
;
-- sample result
-- "repeat_customers"	"sales_per_customer"
-- 17105	6
-- 827	6
-- 7267	6


--Exploratory
--Total active customers; Total Sales Volume
SELECT COUNT(DISTINCT customer_id) AS customers
	, COUNT(customer_id) AS sales_volume
FROM sales
;
-- result
-- "customers"	"sales_volume"
-- 26590	37711


--Window function and subquery (CTE) demo: Rolling 30-day avg of revenue
DROP VIEW window_sales;

--Note: DO NOT run DROP VIEW and CREATE VIEW at same time; will create fatal error

CREATE VIEW window_sales AS

WITH daily_revenue AS (
SELECT sales_transaction_date::DATE
    , SUM(sales_amount) AS revenue_daily
FROM sales
GROUP BY 1
)
SELECT t1.sales_transaction_date
    , t2.revenue_daily
    , AVG(t1.revenue_daily) OVER 
        (ORDER BY t1.sales_transaction_date 
         ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS revenue_30day_avg
FROM daily_revenue t1
    INNER JOIN daily_revenue t2
        ON t1.sales_transaction_date = t2.sales_transaction_date
ORDER BY 1 DESC
;
-- sample result
-- "sales_transaction_date"	"revenue_daily"	"revenue_30day_avg"
-- "2019-05-31"	387619.841	221246.87610000005
-- "2019-05-30"	326009.717	208762.0401333334
-- "2019-05-29"	264114.724	203980.04253333338
-- "2019-05-28"	188874.666	198581.87503333337
-- "2019-05-27"	260879.727	200325.87583333335