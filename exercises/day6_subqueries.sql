-- ============================================
-- Day 6: Subqueries
-- Concepts: Scalar, IN/NOT IN, Correlated, EXISTS
-- ============================================

-- Exercise 1: Employees earning more than company average salary (Scalar)
SELECT first_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-- Exercise 2: Employees in the same department as Alice (Scalar)
SELECT first_name, dept_id
FROM employees
WHERE dept_id = (SELECT dept_id FROM employees WHERE first_name = 'Alice');

-- Exercise 3: Departments with at least one employee on a project (IN)
SELECT dept_id, dept_name
FROM departments
WHERE dept_id IN (
    SELECT DISTINCT dept_id
    FROM employees e
    WHERE e.emp_id IN (SELECT emp_id FROM emp_projects)
);

-- Exercise 4: Employees NOT working on any project (NOT IN)
SELECT emp_id, first_name
FROM employees
WHERE emp_id NOT IN (SELECT emp_id FROM emp_projects);

-- Exercise 5: Each employee's name, salary, and their dept average (Correlated)
SELECT
    first_name,
    salary,
    dept_id,
    (SELECT AVG(salary) FROM employees e2 WHERE e2.dept_id = e.dept_id) AS dept_avg_salary
FROM employees e;

-- Exercise 6: Employees working on the most expensive project (Nested Scalar)
SELECT emp_id, first_name
FROM employees e
WHERE e.emp_id IN (
    SELECT emp_id
    FROM emp_projects
    WHERE project_id = (
        SELECT project_id FROM projects WHERE budget = (SELECT MAX(budget) FROM projects)
    )
);
