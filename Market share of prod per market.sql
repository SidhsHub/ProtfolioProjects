create database practice;
use practice;

CREATE TABLE sales (
    product VARCHAR(10),
    market VARCHAR(25),
    units INT(10)
);

select * from sales;

insert into sales values ("A", "India", 100);
insert into sales values ("B", "India", 200);
insert into sales values ("C", "US", 200);
insert into sales values ("D", "US", 200);
insert into sales values ("E", "US", 200);

UPDATE sales 
SET 
    units = 100
WHERE
    product = 'C';

UPDATE sales
SET 
    units = 200
WHERE
    product = 'D';

UPDATE sales 
SET 
    units = 300
WHERE
    product = 'E';

-- Market share of a product as per market
with cte as
(SELECT 
    market, SUM(units) as no_of_units
FROM
    sales
GROUP BY market)
select s.product, c.market, round((s.units/c.no_of_units)*100, 0) as market_share from cte c join sales s on c.market  = s.market; 

-- Market share of the product in enitre market space
SELECT 
    concat(round((s.units / s1.no_of_units) * 100, 0), "%") as market_share
FROM
    sales s
        CROSS JOIN
    (SELECT 
        SUM(units) as no_of_units
    FROM
        sales) AS s1;