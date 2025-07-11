-- Monday Coffee -- Data Analysis

select * from city;
select * from products;
select * from customers;
select * from sales;

-- Reports and Data Analysis

-- Q1. Coffee Consumers Count
-- How many people in each city are estimated to consume coffee, given that 25% of the population does?

SELECT 
  city_name,
  ROUND((population * 0.25) / 1000000, 2) AS coffee_consumers_in_millions,
  city_rank
FROM city 
ORDER BY coffee_consumers_in_millions DESC;

-- Q2. Total Revenue from Coffee Sales
-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?

select 
	sum(total) as total_revenue
from sales
where
	extract(year from sale_date) = 2023
    and extract(quarter from sale_date) = 4;
	
    
select 
	c.city_name,
	sum(total) as total_revenue
from sales as s
join customers as cu
on  s.customer_id = cu.customer_id
join city as c
on c.city_id = cu.city_id
where
	extract(year from sale_date) = 2023
    and extract(quarter from sale_date) = 4
group by 1
order by 2 desc;


-- Q3. Sales Count for Each Product
-- How many units of each coffee product have been sold?

select 
	p.product_name,
    count(s.sale_id) as total_orders 
from products as p
left join
sales as s
on s.product_id = p.product_id
group by 1
order by 2 desc;

-- Q4. Average Sales Amount per City
-- What is the average sales amount per customer in each city?

-- city and total sale
-- no. of customer in each these city

select 
	c.city_name,
	sum(s.total) as total_revenue,
    count(distinct s.customer_id) as total_cx,
    round(sum(s.total)/count(distinct s.customer_id),2) as avg_sale_pr_cx
from sales as s
join customers as cu
on  s.customer_id = cu.customer_id
join city as c
on c.city_id = cu.city_id
group by 1
order by 2 desc;


-- Q5. City Population and Coffee Consumers
-- Provide a list of cities along with their populations and estimated coffee consumers.

with city_table as (
	select 
		city_id,
        city_name,
        round((population * 0.25)/1000000,2) as coffee_consumers
	from city
),
customer_table as (
	select 
		c.city_id,
        count(distinct c.customer_id) as unique_cx
	from customers c
    join sales s 
    on s.customer_id = c.customer_id
    group by c.city_id
)
select
	ct.city_name,
    ct.coffee_consumers as coffee_consumers_in_millions,
    cu.unique_cx
from city_table ct
join customer_table cu 
on ct.city_id = cu.city_id
order by ct.coffee_consumers desc


-- Q6. Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?


select *
from
(
select 
	ci.city_name,
    p.product_name,
    count(s.sale_id) as total_orders,
    dense_rank() over(partition by  ci.city_name order by count(s.sale_id) desc) as ranking
from sales as s
join products as p
on s.product_id = p.product_id
join customers as c
on c.customer_id = s.customer_id
join city as ci
on ci.city_id  = c.city_id
group by ci.city_name , p.product_name
) as t1
where ranking <= 3


-- Q7. Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?

select
	ci.city_name,
    count(distinct c.customer_id) as unique_cx
from city as ci
join customers as c
on ci.city_id = c.city_id
join sales as s
on s.customer_id = c.customer_id
where 
	s.product_id <= 14
group by 1

-- Q8. Average Sale vs Rent
-- Find each city and their average sale per customer and avg rent per customer

with city_table
as
(
	select 
			ci.city_name,
			sum(s.total) as total_revenue,
			count(distinct s.customer_id) as total_cx,
			round(
			sum(s.total)/count(distinct s.customer_id)
				,2) as avg_sale_pr_cx
	from sales as s
	join customers as c
	on s.customer_id = c.customer_id
	join city as ci
	on c.city_id = ci.city_id
	group by 1
	order by 2
),
city_rent
as
(
select 
	city_name,
    estimated_rent
from city
)
select 
	cr.city_name,
    cr.estimated_rent,
    ct.total_cx,
    ct.avg_sale_pr_cx,
    round(
		cr.estimated_rent/ct.total_cx
        ,2) as avg_rent_per_cx
from city_rent as cr
join city_table as ct
on ct.city_name = cr.city_name
order by 4 desc


-- Q9. Monthly Sales Growth
-- Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly)
-- by each City


with monthly_sales as
(
	select
		ci.city_name,
		extract(month from sale_date) as month,
		extract(year from sale_date) as year,
		sum(s.total) as total_sale
	from sales s
	join customers c 
	on c.customer_id = s.customer_id
	join city ci
	on ci.city_id = c.city_id
	group by ci.city_name,month,year
	order by ci.city_name,year,month
),
growth_ratio
as
(
		select
				city_name,
				month,
				year,
				total_sale as cr_month_sale,
				Lag(total_sale,1) over(partition by city_name order by year, month) as last_month_sale
		from monthly_sales
 )
select
		city_name,
		month,
		cr_month_sale,
		last_month_sale,
		round(
				(cr_month_sale - last_month_sale)/last_month_sale * 100
				, 2
				)as growth_ratio
from growth_ratio
where
		last_month_sale is not null
		


-- Q10. Market Potential Analysis
-- Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer


with city_table as
(
select 
	ci.city_name,
    sum(s.total) as total_revenue,
    count(distinct s.customer_id ) as total_cx,
    round(sum(s.total)/count(distinct s.customer_id ),2) as avg_sale_per_cx
from sales as s
join customers as c
on c.customer_id = s.customer_id
join city as ci
on ci.city_id = c.city_id
group by 1
order by 2
),
city_rent 
as
( 
	select 
		city_name,
        estimated_rent,
        round((population * 0.25)/1000000,3) as estimated_coffee_consumers_in_millions
    from city
)
select
	cr.city_name,
    total_revenue,
    cr.estimated_rent as total_rent,
    ct.total_cx,
    estimated_coffee_consumers_in_millions,
    ct.avg_sale_per_cx,
    round(
			cr.estimated_rent/ct.total_cx	
            ,2) as avg_rent_per_cx
from city_rent as cr
join city_table as ct
on cr.city_name = ct.city_name
order by 2 desc