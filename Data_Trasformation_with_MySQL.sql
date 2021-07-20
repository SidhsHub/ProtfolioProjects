/*
Create a visualization that provides a breakdown between 
the male and female employees working in the company each year, starting from 1990. 
*/


select * from t_dept_emp;
select distinct * from t_dept_emp;
-- By executing above queries we are checking YEAR() function will return correct values. 
-- As both the queries output is same, we can say table have unque contract info about every employee.

SELECT 
    YEAR(de.from_date) AS c_year,
    e.gender,
    COUNT(e.emp_no) AS emp_count
FROM
    t_employees e
        JOIN
    t_dept_emp de ON e.emp_no = de.emp_no
GROUP BY c_year , e.gender
HAVING c_year >= 1990
ORDER BY c_year;


/*
Compare the number of male managers to the number of female managers from different departments for each year, starting from 1990.
*/

SELECT 
    d.dept_name,
    ee.gender,
    dm.emp_no,
    dm.from_date,
    dm.to_date,
    e.calender_year,
    CASE
        WHEN e.calender_year BETWEEN YEAR(dm.from_date) AND YEAR(dm.to_date) THEN 1
        ELSE 0
    END AS active
FROM
    (SELECT 
        YEAR(hire_date) AS calender_year
    FROM
        t_employees
    GROUP BY calender_year) e
        CROSS JOIN
    t_dept_manager dm
        JOIN
    t_departments d ON dm.dept_no = d.dept_no
        JOIN
    t_employees ee ON dm.emp_no = ee.emp_no
ORDER BY dm.emp_no , e.calender_year;

/*
Compare the average salary of female versus male employees in the entire company until year 2002, 
and add a filter allowing you to see that per each department.
*/

SELECT 
    e.gender,
    ROUND(AVG(s.salary),2) AS avg_sal,
    d.dept_name,
    YEAR(s.from_date) AS calender_year
FROM
    t_salaries s
        JOIN
    t_employees e ON s.emp_no = e.emp_no
        JOIN
    t_dept_emp de ON e.emp_no = de.emp_no
        JOIN
    t_departments d ON de.dept_no = d.dept_no
GROUP BY e.gender , d.dept_no , calender_year
HAVING calender_year <= 2002
ORDER BY d.dept_no;

/*
Create an SQL stored procedure that will allow you to obtain the average male and female salary per department 
within a certain salary range. Let this range be defined by two values the user can insert when calling the procedure.

Finally, visualize the obtained result-set in Tableau as a double bar chart.
*/

drop procedure if exists filter_salary;

DELIMITER $$
create procedure filter_salary(IN p_min_salary float, IN p_max_salary float)
begin

SELECT 
    d.dept_name,
    COUNT(e.emp_no) AS num_of_emp,
    ROUND(AVG(s.salary), 2) AS avg_salary,
    e.gender
FROM
    t_employees e
        JOIN
    t_salaries s ON e.emp_no = s.emp_no
        JOIN
    t_dept_emp de ON e.emp_no = de.emp_no
        JOIN
    t_departments d ON de.dept_no = d.dept_no
WHERE s.salary BETWEEN p_min_salary AND p_max_salary
GROUP BY d.dept_no , e.gender
ORDER BY d.dept_no;

    end$$
    DELIMITER ;