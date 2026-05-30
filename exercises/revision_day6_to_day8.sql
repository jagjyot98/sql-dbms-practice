-- ============================================
-- Revision: Days 6–8
-- Topics: Subqueries, String & Date Functions, CASE Expressions
-- ============================================

-- ============================================
-- DAY 6 — Subqueries
-- ============================================

-- Q1: Find all employees who earn more than Bob's salary (Scalar)
-- Attempt:
SELECT * FROM employees
WHERE salary > (SELECT salary FROM employees WHERE first_name = 'Bob');
-- Review: ✅ Correct.

-- Q2: List all projects that have at least one employee assigned (IN)
-- Attempt:
SELECT * FROM projects
WHERE project_id IN (SELECT project_id FROM emp_projects);
-- Review: ✅ Correct.

-- Q3: Find employees in a department located in 'New York' (IN)
-- Attempt:
SELECT * FROM employees
WHERE dept_id IN (SELECT dept_id FROM departments WHERE location = 'New York');
-- Review: ✅ Correct.

-- Q4: Find employees not working on any project (NOT EXISTS)
-- Attempt:
SELECT * FROM employees e
WHERE NOT EXISTS (SELECT 1 FROM emp_projects ep WHERE e.emp_id = ep.emp_id);
-- Review: ✅ Correct.
-- How NOT EXISTS works:
--   For each employee row, the inner query runs with that employee's emp_id fixed.
--   SELECT 1 — value doesn't matter, EXISTS only checks if any row is returned.
--   If emp_projects has NO row for that emp_id → NOT EXISTS = TRUE → employee included.
--   Safer than NOT IN because NULLs in the subquery don't silently break results.

-- Q5: Each employee's name, salary, and highest salary in their department (Correlated)
-- Attempt:
SELECT first_name, salary,
    (SELECT MAX(salary) FROM employees ep
     WHERE ep.dept_id = e.dept_id GROUP BY ep.dept_id) AS DeptMaxSalary
FROM employees e;
-- Review: ⚠️ Correct result but GROUP BY inside correlated subquery is redundant.
--   WHERE ep.dept_id = e.dept_id already isolates one department — only one group exists.
--   GROUP BY adds no value and could confuse the query planner.
-- Correct Answer:
SELECT first_name, salary,
    (SELECT MAX(salary) FROM employees ep WHERE ep.dept_id = e.dept_id) AS dept_max_salary
FROM employees e;

-- Q6: Find employee(s) who logged the most total hours (Nested subquery)
-- Attempt: (needed explanation)
-- Explanation:
--   Step 1 — inner subquery: sum hours per employee
--   Step 2 — middle subquery: find MAX of those totals
--   Step 3 — outer query: return employees whose total matches that max (handles ties)
-- Correct Answer:
SELECT e.first_name, SUM(ep.hours) AS total_hours
FROM employees e
JOIN emp_projects ep ON e.emp_id = ep.emp_id
GROUP BY e.emp_id, e.first_name
HAVING SUM(ep.hours) = (
    SELECT MAX(total)
    FROM (
        SELECT SUM(hours) AS total
        FROM emp_projects
        GROUP BY emp_id
    )
);
-- Simpler if ties don't matter (only one result needed):
-- SELECT e.first_name, SUM(ep.hours) AS total_hours
-- FROM employees e JOIN emp_projects ep ON e.emp_id = ep.emp_id
-- GROUP BY e.emp_id ORDER BY total_hours DESC LIMIT 1;

-- ============================================
-- DAY 7 — String & Date Functions
-- ============================================

-- Q7: Show name as "Alice S." — first name, space, last name initial with dot
-- Attempt:
SELECT first_name || ' ' || SUBSTR(last_name, 1, 1) || '.' AS Name FROM employees;
-- Review: ✅ Correct. Smart use of SUBSTR for initial.

-- Q8: Find employees with more than 5 years tenure
-- Attempt:
SELECT * FROM employees WHERE 2026 - STRFTIME('%Y', hire_date) > 5;
-- Review: ✅ Correct for this dataset.
--   ⚠️ Hardcoded 2026 makes the query stale next year. Prefer dynamic:
SELECT * FROM employees
WHERE (JULIANDAY('now') - JULIANDAY(hire_date)) / 365 > 5;

-- Q9: Each project's name and scheduled run duration in days
-- Attempt:
SELECT project_name, JULIANDAY(end_date) - JULIANDAY(start_date) AS RunTime FROM projects;
-- Review: ✅ Correct.
-- Improvement — alias is clearer as duration_days:
SELECT project_name,
       JULIANDAY(end_date) - JULIANDAY(start_date) AS duration_days
FROM projects;

-- Q10: Find employees hired in even years (2018, 2020, 2022...)
-- Attempt:
SELECT * FROM employees WHERE STRFTIME('%Y', hire_date) % 2 = 0;
-- Review: ❌ STRFTIME returns a STRING — modulo on a string is unreliable.
--   SQLite implicitly casts it, but PostgreSQL/MySQL will error.
-- Correct Answer:
SELECT * FROM employees WHERE CAST(STRFTIME('%Y', hire_date) AS INT) % 2 = 0;

-- Q11: Show name and hire date formatted as "15-Mar-2019"
-- Attempt:
SELECT first_name,
    STRFTIME('%d', hire_date) || '-' ||
    (SELECT CASE
         WHEN STRFTIME('%m', hire_date) = '01' THEN 'Jan'
         WHEN STRFTIME('%m', hire_date) = '02' THEN 'Feb'
         WHEN STRFTIME('%m', hire_date) = '03' THEN 'Mar'
         WHEN STRFTIME('%m', hire_date) = '04' THEN 'Apr'
         WHEN STRFTIME('%m', hire_date) = '05' THEN 'May'
         WHEN STRFTIME('%m', hire_date) = '06' THEN 'Jun'
         WHEN STRFTIME('%m', hire_date) = '07' THEN 'Jul'
         WHEN STRFTIME('%m', hire_date) = '08' THEN 'Aug'
         WHEN STRFTIME('%m', hire_date) = '09' THEN 'Sep'
         WHEN STRFTIME('%m', hire_date) = '10' THEN 'Oct'
         WHEN STRFTIME('%m', hire_date) = '11' THEN 'Nov'
         WHEN STRFTIME('%m', hire_date) = '12' THEN 'Dec'
     END FROM employees) || '-' ||
    STRFTIME('%Y', hire_date) AS HireDate
FROM employees;
-- Review: ❌ Repeated Day 7 mistake — CASE wrapped inside a subquery.
--   (SELECT CASE ... FROM employees) returns 8 rows — scalar position needs 1 value.
--   CASE works directly in SELECT — no subquery needed.
-- Correct Answer (Simple CASE — comparing one expression to fixed values):
SELECT first_name,
    STRFTIME('%d', hire_date) || '-' ||
    CASE STRFTIME('%m', hire_date)
        WHEN '01' THEN 'Jan'  WHEN '02' THEN 'Feb'  WHEN '03' THEN 'Mar'
        WHEN '04' THEN 'Apr'  WHEN '05' THEN 'May'  WHEN '06' THEN 'Jun'
        WHEN '07' THEN 'Jul'  WHEN '08' THEN 'Aug'  WHEN '09' THEN 'Sep'
        WHEN '10' THEN 'Oct'  WHEN '11' THEN 'Nov'  WHEN '12' THEN 'Dec'
    END || '-' ||
    STRFTIME('%Y', hire_date) AS hire_date_formatted
FROM employees;

-- ============================================
-- DAY 8 — CASE Expressions
-- ============================================

-- Q12: Label salary growth potential as Capped / Growth / Entry
-- Attempt:
SELECT first_name,
CASE
    WHEN salary > 85000 THEN 'Capped'
    WHEN salary BETWEEN 65000 AND 85000 THEN 'Growth'
    WHEN salary < 65000 THEN 'Entry'
END AS Label
FROM employees;
-- Review: ✅ Correct. BETWEEN handles boundary (85000 → Growth, not Capped).

-- Q13: Per department — count of senior (hired before 2020) and junior (2020+) employees
-- Attempt:
SELECT
    (SELECT dept_name FROM departments d WHERE d.dept_id = e.dept_id),
    COUNT(CASE WHEN STRFTIME('%Y', hire_date) < '2020' THEN 1 END) AS senior_count,
    COUNT(CASE WHEN STRFTIME('%Y', hire_date) >= '2020' THEN 1 END) AS junior_count
FROM employees e
GROUP BY e.dept_id;
-- Review: ✅ Correct logic. Correlated subquery for dept_name works.
-- Cleaner with a JOIN instead of correlated subquery:
SELECT d.dept_name,
    COUNT(CASE WHEN STRFTIME('%Y', e.hire_date) < '2020' THEN 1 END) AS senior_count,
    COUNT(CASE WHEN STRFTIME('%Y', e.hire_date) >= '2020' THEN 1 END) AS junior_count
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
GROUP BY e.dept_id, d.dept_name;

-- Q14: Label projects by budget, show Big Budget first
-- Attempt:
SELECT *,
CASE
    WHEN budget > 800000 THEN 'Big Budget'
    WHEN budget BETWEEN 300000 AND 800000 THEN 'Mid Budget'
    WHEN budget < 300000 THEN 'Low Budget'
END AS Label
FROM projects
ORDER BY budget DESC;
-- Review: ⚠️ ORDER BY budget DESC gives the right result for this data but is
--   not semantically correct. If two projects had same budget but different labels,
--   order would be wrong. Use CASE in ORDER BY for custom label ordering:
SELECT *,
CASE
    WHEN budget > 800000 THEN 'Big Budget'
    WHEN budget BETWEEN 300000 AND 800000 THEN 'Mid Budget'
    WHEN budget < 300000 THEN 'Low Budget'
END AS label
FROM projects
ORDER BY
    CASE
        WHEN budget > 800000 THEN 1
        WHEN budget BETWEEN 300000 AND 800000 THEN 2
        ELSE 3
    END;

-- Q15: Multi-condition flag: High Earner + Senior / High Earner / Senior / Standard
-- Attempt:
SELECT first_name,
CASE
    WHEN STRFTIME('%Y', hire_date) < 2020 AND salary > 80000 THEN 'High Earner + Senior'
    WHEN salary > 80000 THEN 'High Earner'
    WHEN STRFTIME('%Y', hire_date) < 2020 THEN 'Senior'
    ELSE 'Standard'
END AS Flag
FROM employees;
-- Review: ❌ Type mismatch — STRFTIME returns a STRING, comparing with integer 2020.
--   Works in SQLite by accident (implicit cast) but fails in PostgreSQL/MySQL.
-- Explanation of the fix:
--   STRFTIME('%Y', hire_date) returns '2019' (a string).
--   Comparing '2019' < 2020 (string vs integer) is unreliable across databases.
--   Fix 1 — compare strings: STRFTIME('%Y', hire_date) < '2020'
--   Fix 2 — direct date comparison (best — sargable, index-friendly):
--            hire_date < '2020-01-01'
-- Correct Answer:
SELECT first_name,
CASE
    WHEN hire_date < '2020-01-01' AND salary > 80000 THEN 'High Earner + Senior'
    WHEN salary > 80000                               THEN 'High Earner'
    WHEN hire_date < '2020-01-01'                     THEN 'Senior'
    ELSE 'Standard'
END AS flag
FROM employees;
-- CASE logic and cascading structure were correct — only the comparison type needed fixing.
