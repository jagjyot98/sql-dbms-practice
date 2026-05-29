-- ============================================
-- Revision: Days 1–5
-- Topics: SELECT/Filtering, Sorting/Limiting, Aggregates, JOINs Part 1 & 2
-- ============================================

-- ============================================
-- DAY 1 — SELECT & Filtering
-- ============================================

-- Q1: Find all employees whose first name contains the letter 'a' (case-insensitive)
-- Attempt:
SELECT * FROM employees WHERE first_name LIKE '%a%';
-- Review: ✅ Correct.
-- Note: LIKE is case-sensitive in PostgreSQL. For true case-insensitivity:
SELECT * FROM employees WHERE LOWER(first_name) LIKE '%a%';
-- Or in PostgreSQL: WHERE first_name ILIKE '%a%'

-- Q2: Find employees who are either in department 3 or have salary above 80,000
-- Attempt:
SELECT * FROM employees WHERE dept_id = 3 OR salary > 80000;
-- Review: ✅ Correct.

-- Q3: Find employees who have a manager AND belong to department 1
-- Attempt:
SELECT * FROM employees WHERE dept_id = 1 AND manager_id IS NOT NULL;
-- Review: ✅ Correct.

-- Q4: Find employees hired between 2019-01-01 and 2021-12-31 who are NOT in department 2
-- Attempt:
SELECT * FROM employees WHERE dept_id != 2 AND hire_date BETWEEN '2019-01-01' AND '2021-12-31';
-- Review: ✅ Correct — result is accurate for this dataset.
-- ⚠️ NULL trap: dept_id != 2 silently drops employees with no department (Hank).
--    Hank was hired in 2023 so doesn't affect this result, but develop the habit:
SELECT * FROM employees
WHERE (dept_id != 2 OR dept_id IS NULL)
AND hire_date BETWEEN '2019-01-01' AND '2021-12-31';

-- ============================================
-- DAY 2 — Sorting & Limiting
-- ============================================

-- Q5: List all departments sorted alphabetically by name
-- Attempt:
SELECT * FROM departments ORDER BY dept_name;
-- Review: ✅ Correct. ASC is default — fine for alphabetical.

-- Q6: Find the 2 lowest-paid employees — show name and salary only
-- Attempt:
SELECT first_name, salary FROM employees ORDER BY salary LIMIT 2;
-- Review: ✅ Correct. ASC (default) gives lowest first.

-- Q7: Show all unique combinations of dept_id and manager_id
-- Attempt:
SELECT DISTINCT dept_id, manager_id FROM employees;
-- Review: ✅ Correct. DISTINCT on multiple columns = unique combinations.

-- Q8: Show the 3rd and 4th most recently hired employees
-- Attempt:
SELECT * FROM employees ORDER BY hire_date LIMIT 2 OFFSET 2;
-- Review: ❌ Missing DESC. Without it, sorts oldest-first → OFFSET 2 gives
--    3rd and 4th OLDEST, not most recently hired.
-- Correct Answer:
SELECT * FROM employees ORDER BY hire_date DESC LIMIT 2 OFFSET 2;

-- ============================================
-- DAY 3 — Aggregate Functions
-- ============================================

-- Q9: Total salary bill per department
-- Attempt:
SELECT dept_id, SUM(salary) FROM employees GROUP BY dept_id;
-- Review: ✅ Correct.
-- Improvement — alias for readability:
SELECT dept_id, SUM(salary) AS total_salary FROM employees GROUP BY dept_id;

-- Q10: Which manager has the most employees reporting to them?
-- Attempt:
SELECT manager_id, COUNT(*) AS ReportingEmployees
FROM employees
WHERE manager_id IS NOT NULL
GROUP BY manager_id
ORDER BY ReportingEmployees DESC
LIMIT 1;
-- Review: ✅ Excellent. Clean use of WHERE + GROUP BY + ORDER BY + LIMIT.

-- Q11: Find departments where the minimum salary is above 60,000
-- Attempt:
SELECT dept_id, MIN(salary) AS MinSalary
FROM employees
WHERE salary > 60000
GROUP BY dept_id;
-- Review: ❌ WHERE vs HAVING confusion.
--   WHERE filters rows BEFORE grouping — removes employees earning ≤ 60k first,
--   then finds MIN of remaining rows. This gives wrong results.
--
--   Example: Dept with salaries [50k, 80k]:
--   → WHERE removes 50k employee → MIN = 80k → dept incorrectly included.
--   → But the real dept minimum is 50k, which is NOT above 60k.
--
-- Correct Answer — HAVING filters AFTER grouping:
SELECT dept_id, MIN(salary) AS min_salary
FROM employees
GROUP BY dept_id
HAVING MIN(salary) > 60000;

-- Q12: How many employees were hired each year? Show year and count, sorted by year.
-- Attempt: (needed explanation)
-- Explanation:
--   STRFTIME('%Y', hire_date) extracts the year from hire_date.
--   GROUP BY that expression groups all employees hired in the same year.
--   COUNT(*) counts employees per group. ORDER BY sorts chronologically.
-- Correct Answer:
SELECT STRFTIME('%Y', hire_date) AS hire_year, COUNT(*) AS employee_count
FROM employees
GROUP BY STRFTIME('%Y', hire_date)
ORDER BY hire_year;

-- ============================================
-- DAY 4 — JOINs Part 1
-- ============================================

-- Q13: Each employee's full name and department location. Include employees with no dept.
-- Attempt:
SELECT first_name, last_name, location FROM employees e JOIN departments d ON e.dept_id = d.dept_id;
-- Review: ❌ Used INNER JOIN — Hank (no dept) is excluded.
--   Question says "include employees with no department" → LEFT JOIN required.
-- Correct Answer:
SELECT e.first_name, e.last_name, d.location
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;

-- Q14: Employees NOT assigned to any project — use LEFT JOIN
-- Attempt:
SELECT * FROM employees e
LEFT JOIN emp_projects ep ON e.emp_id = ep.emp_id
WHERE ep.emp_id IS NULL;
-- Review: ✅ Correct. Anti-join pattern applied perfectly.

-- Q15: All departments with count of employees. Include departments with zero employees.
-- Attempt:
SELECT e.dept_id, COUNT(*) FROM employees e LEFT JOIN employees ep ON e.emp_id = ep.emp_id GROUP BY e.dept_id;
-- Review: ❌ Two mistakes:
--   1. Joined employees to employees (self join) — should join departments to employees.
--   2. Departments with zero employees won't appear (they're not in the employees table).
--   3. COUNT(*) returns 1 for unmatched rows — use COUNT(e.emp_id) for accurate 0 counts.
--
-- Correct Answer — departments drives the query:
SELECT d.dept_id, d.dept_name, COUNT(e.emp_id) AS employee_count
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;
-- COUNT(e.emp_id) returns 0 for departments with no employees.
-- COUNT(*) would return 1 (counts the NULL row from unmatched LEFT JOIN).

-- ============================================
-- DAY 5 — JOINs Part 2
-- ============================================

-- Q16: Each employee with their manager's full name. Employees with no manager still appear.
-- Attempt:
SELECT e.first_name AS Employee, m.first_name || ' ' || m.last_name AS Manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id;
-- Review: ✅ Excellent. Smart use of || for full manager name concatenation.

-- Q17: Each employee with dept name and total hours logged across all projects
-- Attempt:
SELECT e.first_name, d.dept_name, SUM(p.hours)
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
LEFT JOIN emp_projects p ON e.emp_id = p.emp_id
GROUP BY e.emp_id;
-- Review: ✅ Correct. Clean 3-table join with aggregation.
-- Improvement — alias SUM and add GROUP BY columns to SELECT:
SELECT e.first_name, d.dept_name, SUM(p.hours) AS total_hours
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
LEFT JOIN emp_projects p ON e.emp_id = p.emp_id
GROUP BY e.emp_id, e.first_name, d.dept_name;

-- Q18: Employees assigned to more than one project — show name and project count
-- Attempt:
SELECT e.first_name, COUNT(*) AS ProjectsCount
FROM employees e
LEFT JOIN emp_projects ep ON e.emp_id = ep.emp_id
GROUP BY ep.emp_id;
-- Review: ❌ Three issues:
--   1. GROUP BY ep.emp_id — grouping on JOIN table column puts all unmatched
--      employees (ep.emp_id = NULL) into one NULL group. Always GROUP BY base table column.
--   2. Missing HAVING COUNT > 1 — question asks for MORE THAN ONE project.
--   3. COUNT(*) counts NULL rows — use COUNT(ep.project_id) for accurate project count.
--
-- Correct Answer:
SELECT e.first_name, COUNT(ep.project_id) AS project_count
FROM employees e
LEFT JOIN emp_projects ep ON e.emp_id = ep.emp_id
GROUP BY e.emp_id, e.first_name
HAVING COUNT(ep.project_id) > 1;
