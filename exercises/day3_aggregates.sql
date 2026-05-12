-- ============================================
-- Day 3: Aggregate Functions
-- Concepts: COUNT, SUM, AVG, MIN, MAX, GROUP BY, HAVING
-- ============================================

-- --------------------------------------------
-- Exercise 1: Total number of employees
-- --------------------------------------------
-- Attempt:
SELECT COUNT(*) FROM employees;
-- Review: ✅ Correct.

-- --------------------------------------------
-- Exercise 2: Average salary per department
-- --------------------------------------------
-- Attempt:
SELECT AVG(salary) FROM employees GROUP BY dept_id;
-- Review: ✅ Correct — with an improvement.
--   Include dept_id in SELECT so you can see which avg belongs to which dept:
SELECT dept_id, AVG(salary) AS avg_salary FROM employees GROUP BY dept_id;
-- Optimization: Always alias aggregate columns for readable output.

-- --------------------------------------------
-- Exercise 3: Highest and lowest salary in the company
-- --------------------------------------------
-- Attempt:
SELECT MAX(salary), MIN(salary) FROM employees;
-- Review: ✅ Perfect.

-- --------------------------------------------
-- Exercise 4: Number of employees per department
-- --------------------------------------------
-- Attempt:
SELECT dept_id, COUNT(*) FROM employees GROUP BY dept_id;
-- Review: ✅ Correct.
--   Improvement — alias for readability:
SELECT dept_id, COUNT(*) AS employee_count FROM employees GROUP BY dept_id;

-- --------------------------------------------
-- Exercise 5: Departments with more than 2 employees
-- --------------------------------------------
-- Attempt:
SELECT dept_id FROM employees GROUP BY dept_id HAVING COUNT(*) > 2;
-- Review: ✅ Correct use of HAVING.
--   Note: dept_id = NULL (Hank) also shows as a group. Exclude NULLs if needed:
SELECT dept_id, COUNT(*) AS employee_count
FROM employees
WHERE dept_id IS NOT NULL
GROUP BY dept_id
HAVING COUNT(*) > 2;

-- --------------------------------------------
-- Exercise 6: Total hours logged per project
-- --------------------------------------------
-- Attempt:
SELECT project_id, SUM(hours) FROM emp_projects GROUP BY project_id;
-- Review: ✅ Correct.
--   Improvement — alias for readability:
SELECT project_id, SUM(hours) AS total_hours FROM emp_projects GROUP BY project_id;

-- --------------------------------------------
-- Exercise 7: Projects with total hours > 200
-- --------------------------------------------
-- Attempt:
SELECT project_id FROM emp_projects GROUP BY project_id HAVING SUM(hours) > 200;
-- Review: ✅ Correct.
--   Improvement — include SUM in SELECT so result is meaningful:
SELECT project_id, SUM(hours) AS total_hours
FROM emp_projects
GROUP BY project_id
HAVING SUM(hours) > 200;

-- ============================================
-- Key Takeaways
-- ============================================
-- SQL logical execution order (memorize this — explains most query errors):
--
--   FROM       → which table(s)
--   JOIN       → combine tables
--   WHERE      → filter rows BEFORE grouping
--   GROUP BY   → group rows
--   HAVING     → filter AFTER grouping (use aggregate here, not WHERE)
--   SELECT     → pick columns
--   ORDER BY   → sort
--   LIMIT      → restrict output
--
-- WHERE vs HAVING:
--   WHERE  salary > 50000    → filters individual rows
--   HAVING COUNT(*) > 2      → filters groups (after GROUP BY)
