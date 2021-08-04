/* Q1
Product	 Market	Unit
A		 India	100
B		 India	200
C		 US		100
D		 US		200
E		 US		300
*/

-- Market share of a product as in the market
with cte as
(SELECT 
    market, SUM(units) as no_of_units
FROM
    sales
GROUP BY market)
select s.product, c.market, round((s.units/c.no_of_units)*100, 0) as market_share from cte c join sales s on c.market  = s.market;

-- Market share of the product in the enitre market space
SELECT 
    concat(round((s.units / s1.no_of_units) * 100, 0), "%") as market_share
FROM
    sales s
        CROSS JOIN
    (SELECT 
        SUM(units) as no_of_units
    FROM
        sales) AS s1;
----------------------------------------------------------------------------------------------------------------------------------------------

/* Q2
prod_id	 Sales
1		 500
2		 1000
3	 	 400
4		 2500
5		 3000
*/

-- List the products contributing to 80% of sales. Sales contribution can be 82% but not 78%

WITH cte as
(SELECT 
	product_id, 
	sum(sales) over (order by sales desc) as running_sales_total,
    b.eighty_per_sales
FROM products
	cross join
    (SELECT 
    SUM(sales) * 0.84 AS eighty_per_sales
FROM
    products)b)
select product_id from cte where running_sales_total <= eighty_per_sales;

----------------------------------------------------------------------------------------------------------------------------------------------

/* Q3
id	qtr	 	transaction_amt		balance
1	2019-Q1		3				10
1	2019-Q1		5				5
1	2019-Q2		10				20
1	2019-Q2		5				5
1	2019-Q3		10				30
1	2019-Q1		2				10
2	2019-Q2		2				10
2	2019-Q2		5				20
*/

-- Find the balance left in the card at the qtr end
-- Assumption here is min balance is the latest balance per qtr
SELECT 
    id, qtr, MIN(balance) AS qtr_end_balance
FROM
    cards
GROUP BY id , qtr
ORDER BY id , qtr;

----------------------------------------------------------------------------------------------------------------------------------------------

/* Q4
If there is no gap between tv sessions of a channel (i.e. if end time of 1st session is equal to start time of the second session) show that as a single session
 eg 
id	ch_id	start_time	end_time
1	1		500			540
2	1		540			570
3	1		590			700
 
 output
 ch_id	start_time	end_time
 1		500			570
 1		590			700
*/

WITH data_transformation_cte AS
(SELECT 
    t1.channel_id AS ch_id,
    t1.id AS id1,
    t2.id AS id2,
    t1.channel_id,
    t1.start_time AS st1,
    t1.end_time AS et1,
    t2.start_time AS st2,
    t2.end_time AS et2
FROM
    tv_serial t1
        LEFT JOIN
    tv_serial t2 ON t1.channel_id = t2.channel_id
        AND t1.end_time = t2.start_time)
SELECT 
    ch_id AS channel_id,
    st1 AS start_time,
    CASE
        WHEN et1 = st2 THEN et2
        ELSE et1
    END AS final_end_time
FROM
    data_transformation_cte
WHERE
    id1 NOT IN (SELECT DISTINCT
            id2
        FROM
            data_transformation_cte
        WHERE
           id2 IS NOT NULL
           )
ORDER BY ch_id;

