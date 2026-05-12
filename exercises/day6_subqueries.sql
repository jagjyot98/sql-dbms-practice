-- ============================================
-- Day 6: Subqueries
-- Concepts: Scalar, IN/NOT IN, Correlated, EXISTS
-- ============================================

-- Subquery Type Reference:
-- Scalar     → returns 1 value, used in WHERE or SELECT
-- IN/NOT IN  → returns a list of values
-- Correlated → references outer query, runs once per row
-- EXISTS     → checks if subquery returns any rows (faster than IN on large data)

-- --------------------------------------------
-- Exercise 1: Employees earning more than company average salary (Scalar)
-- --------------------------------------------
-- Attempt:
SELECT first_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);
-- Review: ✅ Correct.
-- Optimization: The subquery runs once and returns a single value.
--   This is efficient. No changes needed.

-- --------------------------------------------
-- Exercise 2: Employees in the same department as Alice (Scalar)
-- --------------------------------------------
-- Attempt:
SELECT first_name, dept_id
FROM employees
WHERE dept_id = (SELECT dept_id FROM employees WHERE first_name = 'Alice');
-- Review: ✅ Correct.
-- Note: If multiple employees named Alice existed, this would error.
--       Use LIMIT 1 or be more specific in real-world queries.

-- --------------------------------------------
-- Exercise 3: Departments with at least one project employee (IN)
-- --------------------------------------------
-- Attempt:
SELECT dept_id, dept_name FROM departments
WHERE dept_id IN (
    SELECT DISTINCT dept_id FROM employees e
    WHERE e.emp_id IN (SELECT emp_id FROM emp_projects)
);
-- Review: ✅ Correct — nested IN subquery works.
-- Optimization: Can be simplified with EXISTS (more readable, avoids DISTINCT):
SELECT dept_id, dept_name FROM departments d
WHERE EXISTS (
    SELECT 1 FROM employees e
    JOIN emp_projects ep ON e.emp_id = ep.emp_id
    WHERE e.dept_id = d.dept_id
);

-- --------------------------------------------
-- Exercise 4: Employees NOT working on any project (NOT IN)
-- --------------------------------------------
-- Attempt:
SELECT emp_id, first_name
FROM employees
WHERE emp_id NOT IN (SELECT emp_id FROM emp_projects);
-- Review: ✅ Correct.
-- ⚠️  Important gotcha: NOT IN fails silently if the subquery returns any NULL.
--     NULL in the list makes the whole NOT IN evaluate to NULL (unknown),
--     returning 0 rows. Safer alternative:
SELECT emp_id, first_name FROM employees e
WHERE NOT EXISTS (SELECT 1 FROM emp_projects ep WHERE ep.emp_id = e.emp_id);

-- --------------------------------------------
-- Exercise 5: Each employee's salary and their dept average (Correlated)
-- --------------------------------------------
-- Attempt:
SELECT first_name, salary, dept_id,
       (SELECT AVG(salary) FROM employees GROUP BY dept_id) AS AverageSalary
FROM employees;
-- Review: ❌ Wrong — the subquery returns multiple rows (one per dept),
--   but a scalar position in SELECT expects exactly 1 value.
--
-- Why it fails:
--   (SELECT AVG(salary) FROM employees GROUP BY dept_id)
--   → returns 4 rows (one per department) — not a scalar value.
--
-- Fix — use a CORRELATED subquery that references the outer query's dept_id:
SELECT first_name, salary, dept_id,
       (SELECT AVG(salary) FROM employees e2 WHERE e2.dept_id = e.dept_id) AS dept_avg_salary
FROM employees e;
--
-- How correlated subqueries work:
--   For each row in the outer query, the inner query runs fresh,
--   using that row's dept_id to calculate the average for that dept only.

-- --------------------------------------------
-- Exercise 6: Employees working on the most expensive project (Nested Scalar)
-- --------------------------------------------
-- Attempt:
SELECT emp_id, first_name FROM employees e
WHERE e.emp_id IN (
    SELECT emp_id FROM emp_projects
    WHERE project_id = (
        SELECT project_id FROM projects
        WHERE budget = (SELECT MAX(budget) FROM projects)
    )
);
-- Review: ✅ Correct — 4 levels of nesting, all correct.
-- Optimization: Simplify with ORDER BY + LIMIT instead of nested MAX:
SELECT e.emp_id, e.first_name
FROM employees e
JOIN emp_projects ep ON e.emp_id = ep.emp_id
JOIN projects p ON ep.project_id = p.project_id
ORDER BY p.budget DESC
LIMIT 1;
-- Or using a CTE (cleaner for readability — covered in Day 12):
-- WITH top_project AS (SELECT project_id FROM projects ORDER BY budget DESC LIMIT 1)
-- SELECT e.emp_id, e.first_name FROM employees e
-- JOIN emp_projects ep ON e.emp_id = ep.emp_id
-- JOIN top_project tp ON ep.project_id = tp.project_id;

-- ============================================
-- Key Takeaways
-- ============================================
-- | Type        | Returns       | Used In          | Runs         |
-- |-------------|---------------|------------------|--------------|
-- | Scalar      | 1 value       | WHERE / SELECT   | Once         |
-- | IN/NOT IN   | List          | WHERE            | Once         |
-- | Correlated  | 1 value       | WHERE / SELECT   | Per row      |
-- | EXISTS      | TRUE/FALSE    | WHERE            | Per row      |
--
-- NOT IN vs NOT EXISTS:
--   NOT IN   → unsafe if subquery can return NULL (use with caution)
--   NOT EXISTS → always safe, preferred in production code
