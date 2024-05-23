-- Ch. 8 Performant SQL

-- Ex. 26 Interpreting the SQL Planner

-- 2.
EXPLAIN
SELECT *
FROM emails
;

-- 3.
EXPLAIN
SELECT *
FROM emails
LIMIT 5
;

-- 4.
EXPLAIN (ANALYZE)
SELECT *
FROM emails
WHERE clicked_date BETWEEN '2011-01-01' AND '2011-02-01'
;

-- Act. 10
EXPLAIN
SELECT *
FROM customers
LIMIT 15
;

EXPLAIN
SELECT *
FROM customers
WHERE latitude BETWEEN 30 AND 40
;

-- Ex. 27
EXPLAIN
SELECT *
FROM customers
WHERE state = 'FO'
;

EXPLAIN
SELECT DISTINCT state
FROM customers
;

CREATE INDEX ix_state ON customers(state)
;

EXPLAIN
SELECT *
FROM customers
WHERE gender = 'M'
;

CREATE INDEX ix_gender ON customers(gender);

EXPLAIN
SELECT *
FROM customers
WHERE (latitude < 38) AND (latitude > 30)
;

CREATE INDEX ix_latitude ON customers(latitude);

EXPLAIN ANALYZE
SELECT *
FROM customers 
WHERE (latitude < 38) AND (latitude > 30)
;

CREATE INDEX ix_latitude_less ON customers(latitude)
WHERE (latitude < 38) AND (latitude > 30)
;

EXPLAIN ANALYZE
SELECT *
FROM customers
WHERE ip_address = '18.131.58.65'
;
/*
"Seq Scan on customers  (cost=0.00..1661.00 rows=1 width=140) (actual time=0.019..6.274 rows=1 loops=1)"
"  Filter: (ip_address = '18.131.58.65'::text)"
"  Rows Removed by Filter: 49999"
"Planning Time: 0.114 ms"
"Execution Time: 6.292 ms"
*/

CREATE INDEX ix_ip_address ON customers(ip_address);

CREATE INDEX ix_ip_address_detailed ON customers(ip_address)
WHERE ip_address = '18.131.58.65';

EXPLAIN ANALYZE
SELECT *
FROM customers
WHERE suffix = 'Jr.'
;

CREATE INDEX ix_suffix ON customers(suffix);

-- Ex. 28
EXPLAIN ANALYZE
SELECT *
FROM customers
WHERE gender = 'M'
;

CREATE INDEX ix_gender ON customers USING HASH(gender);

EXPLAIN ANALYZE
SELECT *
FROM customers
WHERE state = 'FO'
;

CREATE INDEX ix_state ON customers USING HASH(state);

-- Act. 12
EXPLAIN ANALYZE
SELECT *
FROM emails
WHERE email_subject = 'Shocking Holiday Savings On Electric Scooters'
;

EXPLAIN ANALYZE
SELECT *
FROM emails
WHERE email_subject = 'Black Friday. Green Cars.'
;


CREATE INDEX ix_email_subject ON emails USING HASH(email_subject);

-- Ex. 30
CREATE FUNCTION fixed_val() RETURNS integer AS $$
BEGIN
RETURN 1;
END; $$
LANGUAGE PLPGSQL;
SELECT * FROM fixed_val();

EXPLAIN ANALYZE 
SELECT * FROM fixed_val();
---
CREATE FUNCTION num_samples() RETURNS integer AS $total$
DECLARE total integer;
BEGIN
SELECT COUNT(*) INTO total FROM sales;
RETURN total;
END; $total$
LANGUAGE PLPGSQL;
SELECT num_samples();

-- Act. 14
CREATE FUNCTION max_sale() RETURNS integer AS $big_sale$
DECLARE big_sale numeric;
BEGIN
SELECT MAX(sales_amount) INTO big_sale FROM sales;
RETURN big_sale;
END; $big_sale$
LANGUAGE PLPGSQL;

SELECT max_sale(sales_amount) FROM sales;




