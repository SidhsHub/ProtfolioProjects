use practice;

CREATE TABLE products (
    product_id int(10),
    sales INT(10)
);

insert into products values (1, 500);
insert into products values (2, 1000);
insert into products values (3, 400);
insert into products values (4, 2500);
insert into products values (5, 3000);

select * from products;

-- List the products contributing to 80% of sales. Sales contribution can be 82% but not 78%

WITH running_total_cte as
(SELECT 
	product_id, 
	sum(sales) over (order by sales desc) as running_sales_total
FROM products),
eighty_percent_cte as
(SELECT 
    SUM(sales) * 0.84 AS eighty_per_sales
FROM
    products)
SELECT 
	product_id as prod_eight_percent_sales 
FROM  
running_total_cte cross join eighty_percent_cte 
where running_sales_total <= eighty_per_sales;