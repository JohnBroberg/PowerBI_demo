--SQL Demo

select customer_id, count(*)
from sales
group by 1
--order by count(*) desc
having count(*) > 1
;

select count(distinct customer_id), count(customer_id)
from sales
;

select count(distinct dealership_id), count(distinct city)
    , count(distinct street_address)
    , count(distinct state)
from dealerships
limit 10

;

DROP VIEW window_sales;

--DO NOT run DROP VIEW and CREATE VIEW at same time; will create fatal error


--demo: window function (rolling 30 day avg) for revenue
--created by JBroberg, for Zello, on 2022-06-24
--

CREATE VIEW window_sales as

WITH daily_revenue as (
select sales_transaction_date::DATE
    , sum(sales_amount) as revenue_daily
from sales
group by 1
)
select t1.sales_transaction_date
    , t2.revenue_daily
    , avg(t1.revenue_daily) over 
        (order by t1.sales_transaction_date 
         rows between 29 preceding and current row) as revenue_30day_avg
from daily_revenue t1
    inner join daily_revenue t2
        on t1.sales_transaction_date = t2.sales_transaction_date
order by 1 desc

;