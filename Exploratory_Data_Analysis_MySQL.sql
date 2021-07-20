/*
Find the average salary of the male and female employees in each department.
*/

SELECT 
    e.gender, ROUND(AVG(s.salary), 2) AS avg_sal, d.dept_name
FROM
    employees_mod.t_employees e
        JOIN
    employees_mod.t_salaries s ON e.emp_no = s.emp_no
        JOIN
    employees_mod.t_dept_emp de ON e.emp_no = de.emp_no
        JOIN
    employees_mod.t_departments d ON de.dept_no = d.dept_no
GROUP BY e.gender , d.dept_no
ORDER BY d.dept_no;

/*
Find the lowest department number encountered in the 'dept_emp' table. Then, find the highest department number.
*/

use employees;

SELECT 
    MIN(dept_no), MAX(dept_no)
FROM
    dept_emp;
    
/*
Obtain a table containing the following three fields for all individuals whose employee number is not greater than 10040:
- employee number
- the lowest department number among the departments where the employee has worked in (Hint: use a subquery to retrieve this value from the 'dept_emp' table)
- assign '110022' as 'manager' to all individuals whose employee number is lower than or equal to 10020, and '110039' to those whose number is between 10021 and 10040 inclusive.
Use a CASE statement to create the third field.
If you've worked correctly, you should obtain an output containing 40 rows.
*/

SELECT 
    emp_no,
    (SELECT 
            MIN(dept_no)
        FROM
            dept_emp de
        WHERE
            e.emp_no = de.emp_no) AS first_dept,
    CASE
        WHEN emp_no <= 10020 THEN 110022
        ELSE 110039
    END AS manager_id
FROM
    employees e
WHERE
    emp_no <= 10040;

SELECT 
    a.*
FROM
    (SELECT 
        e.emp_no,
            MIN(de.dept_no) AS first_dept,
            (SELECT 
                    emp_no
                FROM
                    dept_manager
                WHERE
                    emp_no = 110022) AS manager_id
    FROM
        employees e
    JOIN dept_emp de ON e.emp_no = de.emp_no
    WHERE
        e.emp_no <= 10020
    GROUP BY e.emp_no) AS a union
    SELECT 
    b.*
FROM
    (SELECT 
        e.emp_no,
            MIN(de.dept_no) AS first_dept,
            (SELECT 
                    emp_no
                FROM
                    dept_manager
                WHERE
                    emp_no = 110039) AS manager_id
    FROM
        employees e
    JOIN dept_emp de ON e.emp_no = de.emp_no
    WHERE
        e.emp_no between 10021 and 10040
    GROUP BY e.emp_no) AS b;
    
/*
Retrieve a list of all employees that have been hired in 2000.
*/

SELECT 
    emp_no
FROM
    employees
WHERE
    YEAR(hire_date) = 2000;
    
/*
Retrieve a list of all employees from the ‘titles’ table who are engineers.
Repeat the exercise, this time retrieving a list of all employees from the ‘titles’ table who are senior engineers.
After LIKE, you could indicate what you are looking for with or without using parentheses. 
Both options are correct and will deliver the same output. 
We think using parentheses is better for legibility and that’s why it is the first option we’ve suggested.
*/

SELECT 
    COUNT(DISTINCT emp_no)
FROM
    titles
WHERE
    title LIKE ('%engineer%') OR ('%senior engineer%');
    
/*
Create a procedure that asks you to insert an employee number and that will obtain an output containing the same number, 
as well as the number and name of the last department the employee has worked in.
Finally, call the procedure for employee number 10010.
If you've worked correctly, you should see that employee number 10010 has worked for department number 6 - "Quality Management".
*/

drop procedure if exists get_dept

DELIMITER $$
create procedure get_dept(in p_emp_no float) 
BEGIN
SELECT 
    d.dept_no, d.dept_name
FROM
    employees e
        JOIN
    dept_emp de ON e.emp_no = de.emp_no
        JOIN
    departments d ON de.dept_no = d.dept_no
WHERE
    e.emp_no = p_emp_no
        AND de.from_date = (SELECT 
            MAX(from_date)
        FROM
            dept_emp
        WHERE
            emp_no = p_emp_no);
END $$
DELIMITER ;

/*
How many contracts have been registered in the ‘salaries’ table with duration of more than one year and of value higher than or equal to $100,000?
Hint: You may wish to compare the difference between the start and end date of the salaries contracts.
*/

select * from salaries;

SELECT 
    count(emp_no)
FROM
    salaries
WHERE
    DATEDIFF(to_date, from_date) > 365
AND
	salary >= 100000;
    
# Define a function that retrieves the largest contract salary value of an employee. Apply it to employee number 11356. 
# Also, what is the lowest salary value per contract of the same employee? You may want to create a new function that will deliver this number to you.  Apply it to employee number 11356 again.
# Feel free to apply the function to other employee numbers as well.

SELECT 
    MAX(salary)
FROM
    salaries
WHERE
    emp_no = 10001;

drop function if exists f_highest_salary;

DELIMITER $$
CREATE FUNCTION f_highest_salary(p_emp_no integer, p_sal_min_max varchar(250)) returns decimal(10,2) DETERMINISTIC
BEGIN
DECLARE v_max_sal decimal(10,2);
	SELECT
    case when p_sal_min_max = 'max' then max(salary)
         when p_sal_min_max = 'min' then max(salary)
         else max(salary) - min(salary)
	end as salary into v_max_sal
    FROM
    salaries
WHERE
    emp_no = p_emp_no;
    
return v_max_sal;
END $$
DELIMITER ;