/* 
ZoomZoom_Revenue 
C:\Users\jbrob\git\PowerBI_demo\ZoomZoom_Revenue.pbix
created by JBroberg, for MBoss, on 2023-02-08
*/


-- Revenue Dashboards

-- Repeat Custoemers 
-- duplicate customer_id
SELECT customer_id, COUNT(*)
FROM sales
GROUP BY 1
--ORDER BY COUNT(*) DESC
HAVING COUNT(*) > 1
;

-- 20 Dealerships, 1 in each city
SELECT COUNT(DISTINCT dealership_id) AS dealerships
	, COUNT(DISTINCT city) AS cities
    , COUNT(DISTINCT street_address) AS streets
    , COUNT(DISTINCT state) AS states
FROM dealerships
;

DROP VIEW window_sales;

--DO NOT run DROP VIEW and CREATE VIEW at same time; will create fatal error

-- window function (rolling 30 day avg) for revenue

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

----------------------------------------------------

-- Bat Scooter Sales Analysis


-- 4. 
SELECT model
	, product_id 
INTO product_names
FROM products
WHERE product_type = 'scooter'
;

/*
 Ex. 35
*/ 

-- 3.
SELECT model
	, customer_id
	, sales_transaction_date
	, sales_amount
	, channel
	, dealership_id
INTO product_sales
FROM sales s
INNER JOIN product_names p
	ON s.product_id = p.product_id
;

-- 4.
SELECT *
FROM product_sales
LIMIT 5
;

-- 5.
SELECT *
FROM product_sales
WHERE model = 'Bat'
ORDER BY sales_transaction_date
;

-- 6.
SELECT COUNT(model)
FROM product_sales
WHERE model = 'Bat'
;

-- 7.
SELECT MAX(sales_transaction_date)
FROM product_sales
WHERE model = 'Bat'
;

-- 8.
SELECT *
INTO bat_sales
FROM product_sales 
WHERE model = 'Bat'
ORDER BY sales_transaction_date
;

-- 9.
UPDATE bat_sales
SET sales_transaction_date = DATE(sales_transaction_date)
;

--10.
SELECT *
FROM bat_sales
ORDER BY sales_transaction_date
LIMIT 5
;

-- 11.
SELECT sales_transaction_date
	, COUNT(sales_transaction_date) as sales_vol_daily
INTO bat_sales_daily
FROM bat_sales
GROUP BY sales_transaction_date
ORDER BY sales_transaction_date
;

-- 12.
SELECT *
FROM bat_sales_daily
LIMIT 22
;

-- Activity 18
-- 2.
SELECT sales_transaction_date
	, SUM(sales_vol_daily) OVER (ORDER BY sales_transaction_date) AS sales_vol_cumulative
INTO bat_sales_growth
FROM bat_sales_daily
;

-- 3.
SELECT sales_transaction_date
	, sales_vol_cumulative
	, LAG(sales_vol_cumulative,7) OVER (ORDER BY sales_transaction_date) AS sales_vol_cumulative_7daylag
INTO bat_sales_daily_delay
FROM bat_sales_growth
;

SELECT *
FROM bat_sales_daily
limit 15
;
-- ADD TO PBI CHART
WITH cte1 AS (
SELECT *
	, SUM(sales_vol_daily) OVER (ORDER BY sales_transaction_date) AS sales_vol_cumulative
FROM bat_sales_daily
) 

, cte2 AS (
SELECT *
	, LAG(sales_vol_cumulative,7) OVER (ORDER BY sales_transaction_date) AS sales_vol_cumulative_7daylag
FROM cte1
)

SELECT *
	, (sales_vol_cumulative - sales_vol_cumulative_7daylag) / sales_vol_cumulative_7daylag AS growth
INTO bat_sales_delay_vol
FROM cte2
;

-- Ex. 36
-- 2.
SELECT *, EXTRACT(MONTH FROM production_start_date)
FROM products
WHERE product_type = 'scooter'
ORDER BY EXTRACT(MONTH FROM production_start_date)

--5.
SELECT p.model
	, s.sales_transaction_date
INTO bat_ltd_sales
FROM sales s
	INNER JOIN products p
	 ON s.product_id = p.product_id
WHERE s. product_id = 8
ORDER BY s.sales_transaction_date
;

--8.
SELECT MIN(sales_transaction_date), MAX(sales_transaction_date)
FROM bat_ltd_sales
;

-- 9.
ALTER TABLE bat_ltd_sales
	ALTER COLUMN sales_transaction_date
		TYPE date
;

-- 11.
SELECT sales_transaction_date
	, count(sales_transaction_date)
INTO bat_ltd_sales_count
FROM bat_ltd_sales
GROUP BY sales_transaction_date
ORDER BY sales_transaction_date
;

-- 13.
SELECT *
	, SUM(count) OVER (ORDER BY sales_transaction_date)
INTO bat_ltd_sales_growth
FROM bat_ltd_sales_count
;

-- 16.
SELECT *
	, lag(sum, 7) OVER (ORDER BY sales_transaction_date)
INTO bat_ltd_sales_delay
FROM bat_ltd_sales_growth
;

-- 17.
-- ADD TO PBI CHART, AND COMPARE TO BAT GROWTH
SELECT *
	, (sum - lag) / lag AS volume
INTO bat_ltd_sales_vol
FROM bat_ltd_sales_delay
;

-- Act. 19
-- 2.
SELECT sales_transaction_date
INTO lemon_sales
FROM sales
WHERE product_id = 3
;

select min(sales_transaction_date), max(sales_transaction_date)
from lemon_sales
--"2013-05-01"	"2018-12-27"

-- 5.
ALTER TABLE lemon_sales
	ALTER COLUMN sales_transaction_date
		TYPE date
		
-- 6.
SELECT *
	, COUNT(*)
INTO TEMP lemon_sales_count 
FROM lemon_sales
GROUP BY sales_transaction_date
ORDER BY sales_transaction_date
;

select *
from lemon_sales_count
;

-- 7. 
SELECT *
	, SUM(count) OVER (ORDER BY sales_transaction_date) AS lemon_sales_cumulative
INTO TEMP lemon_sales_sum
FROM lemon_sales_count
;

-- 8.
SELECT *
	, lag(lemon_sales_cumulative, 7) OVER (ORDER BY sales_transaction_date) 
		AS lemon_sales_cumulative_7daylag
INTO TEMP lemon_sales_delay
FROM lemon_sales_sum
;

-- 9. ADD TO PBI CHART AND COMPARE TO BAT SCOOTER SALES
SELECT *
	, (lemon_sales_cumulative - lemon_sales_cumulative_7daylag) / lemon_sales_cumulative_7daylag
		AS lemon_sales_growth
FROM lemon_sales_delay
LIMIT 22
;

-- Ex. 37
-- 2.
SELECT *
FROM emails
limit 5
;

-- 3.
SELECT e.email_subject
	, e.customer_id
	, e.opened
	, e.sent_date
	, e.opened_date
	, b.sales_transaction_date
INTO TEMP bat_emails
FROM emails e
	INNER JOIN bat_sales b
		ON e.customer_id = b.customer_id
ORDER BY b.sales_transaction_date
;

-- 4.
SELECT * FROM bat_emails LIMIT 10;

-- 5.
SELECT *
FROM bat_emails
WHERE sent_date < sales_transaction_date
ORDER BY customer_id
limit 22
;

-- 6.
DELETE FROM bat_emails
WHERE sent_date < '2016-04-10'
;

-- 7.
DELETE FROM bat_emails WHERE sent_date > sales_transaction_date;

-- 8.
DELETE FROM bat_emails WHERE (sales_transaction_date - sent_date) > '30 days';

-- 9.
SELECT * FROM bat_emails ORDER BY customer_id LIMIT 22;

-- 10.
SELECT DISTINCT (email_subject) FROM bat_emails;

-- 11. and 12.
DELETE FROM bat_emails WHERE position('Black Friday' in email_subject) > 0;
DELETE FROM bat_emails WHERE position('25% off all EVs' in email_subject) > 0;
DELETE FROM bat_emails WHERE position('Some New EVs' in email_subject) > 0;

-- 13.
SELECT COUNT (sales_transaction_date) FROM bat_emails;

-- 14.
SELECT COUNT(opened) FROM bat_emails WHERE opened = 't'

-- 15. 
SELECT COUNT(DISTINCT(customer_id)) FROM bat_emails;

-- 16.
SELECT COUNT(DISTINCT(customer_id)) FROM bat_sales;

-- 17.
SELECT 396.0/6659.0 AS email_rate

--18.
SELECT *
INTO TEMP bat_emails_threewks
FROM bat_emails 
WHERE sales_transaction_date < '2016-11-01'
;

--20.
SELECT COUNT(opened)
FROM bat_emails_threewks
WHERE opened = 't'
;

--21.
SELECT COUNT(DISTINCT(customer_id)) FROM bat_emails_threewks;

--22.
SELECT 15.0/82.0 AS sales_rate;

--23.
SELECT COUNT(DISTINCT(customer_id))
FROM bat_sales
WHERE sales_transaction_date < '2016-11-01'
;

-- Ex. 38
--2. 
DROP TABLE lemon_sales;

--3.
SELECT customer_id , sales_transaction_date
INTO TEMP lemon_sales
FROM sales
WHERE product_id = 3
;

--4.
SELECT e.customer_id
	, e.email_subject
	, e.opened
	, e.sent_date
	, e.opened_date
	, l.sales_transaction_date
INTO TEMP lemon_emails
FROM emails e
	INNER JOIN lemon_sales l
			ON e.customer_id = l.customer_id
;
--5.
SELECT production_start_date FROM products WHERE product_id = 3;
--result: 2013-05-01 00:00:00

DELETE FROM lemon_emails
WHERE sent_date < '2013-05-01 00:00:00'
;

--6.
DELETE FROM lemon_emails
WHERE sent_date > sales_transaction_date
;

--7.
DELETE FROM lemon_emails WHERE (sales_transaction_date - sent_date) > '30 days';

--8.
SELECT DISTINCT(email_subject) FROM lemon_emails;

DELETE FROM lemon_emails
WHERE POSITION ('25% off all EVs' IN email_subject) > 0
	OR POSITION ('Like a Bat out of Heaven' IN email_subject) > 0
	OR POSITION ('Save the Planet' IN email_subject) > 0
	OR POSITION ('An Electric Car' IN email_subject) > 0
	OR POSITION ('We cut you a deal' IN email_subject) > 0
	OR POSITION ('Black Friday' IN email_subject) > 0
	OR POSITION ('Zoom' IN email_subject) > 0
;

--9.
SELECT COUNT(opened) FROM lemon_emails WHERE opened = 't';

--10.
SELECT COUNT(DISTINCT(customer_id)) FROM lemon_emails;

--11.
SELECT 128.0 / 506.0 AS email_reate;

--12.
SELECT COUNT(DISTINCT(customer_id)) FROM lemon_sales;

--13.
SELECT 506.0 / 13854.0 AS email_sales;

--14.
SELECT *
--INTO TEMP lemon_emails_threewks
FROM lemon_emails
order by sales_transaction_date
WHERE sales_transaction_date < '2013-06-01  00:00:00'
;
	