/*
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

use practice;

CREATE TABLE tv_serial (
    id INT(10),
    channel_id INT(10),
    start_time INT(10),
    end_time INT(10)
);

insert into tv_serial values (1, 1, 500, 540);
insert into tv_serial values (2, 1, 540, 570);
insert into tv_serial values (3, 1, 590, 700);
insert into tv_serial values (4, 2, 520, 600);
insert into tv_serial values (5, 2, 610, 680);
insert into tv_serial values (6, 2, 680, 800);

SELECT 
    *
FROM
    tv_serial;
    
-- Final solution
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


-- trials
WITH cte AS
(SELECT 
	t1.id,
    t1.channel_id,
	t1.start_time,
    case when t1.end_time = t2.start_time then t2.end_time
    else t1.end_time
    end as new_end_time
FROM
    tv_serial t1
        JOIN
    tv_serial t2 ON t1.channel_id = t2.channel_id
        AND t1.id <> t2.id
ORDER BY t1.id)
SELECT 
    channel_id, start_time, max(new_end_time)
FROM
    cte
group by channel_id, start_time
order by channel_id, start_time;

SELECT 
    *
FROM
    tv_serial t1
        LEFT JOIN
    tv_serial t2 ON t1.channel_id = t2.channel_id
    and t1.end_time = t2.start_time
-- WHERE t1.end_time <> t2.end_time
ORDER BY t1.id;