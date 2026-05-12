-- ============================================
-- Day 3: Aggregate Functions
-- Concepts: COUNT, SUM, AVG, MIN, MAX, GROUP BY, HAVING
-- ============================================

-- Exercise 1: Total number of employees
SELECT COUNT(*) FROM employees;

-- Exercise 2: Average salary per department
SELECT dept_id, AVG(salary) AS avg_salary FROM employees GROUP BY dept_id;

-- Exercise 3: Highest and lowest salary in the company
SELECT MAX(salary), MIN(salary) FROM employees;

-- Exercise 4: Number of employees per department
SELECT dept_id, COUNT(*) AS employee_count FROM employees GROUP BY dept_id;

-- Exercise 5: Departments with more than 2 employees
SELECT dept_id, COUNT(*) AS employee_count
FROM employees
GROUP BY dept_id
HAVING COUNT(*) > 2;

-- Exercise 6: Total hours logged per project
SELECT project_id, SUM(hours) AS total_hours FROM emp_projects GROUP BY project_id;

-- Exercise 7: Projects with total hours > 200
SELECT project_id, SUM(hours) AS total_hours
FROM emp_projects
GROUP BY project_id
HAVING SUM(hours) > 200;
