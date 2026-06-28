-- ============================================
-- Day 9: Window Functions Part 1
-- Concepts: ROW_NUMBER, RANK, DENSE_RANK, NTILE, OVER(), PARTITION BY
-- ============================================

-- Window Function Syntax:
--   function_name() OVER (
--       PARTITION BY col   -- split into groups (keeps all rows unlike GROUP BY)
--       ORDER BY col DESC  -- order within each group
--   )
--
-- | Function      | Behaviour                          | Example output  |
-- |---------------|------------------------------------|-----------------|
-- | ROW_NUMBER()  | Unique sequential number, no ties  | 1, 2, 3, 4      |
-- | RANK()        | Ties share rank, next rank skips   | 1, 2, 2, 4      |
-- | DENSE_RANK()  | Ties share rank, no skip           | 1, 2, 2, 3      |
-- | NTILE(n)      | Splits rows into n equal buckets   | 1, 1, 2, 2, 3   |

-- --------------------------------------------
-- Exercise 1: Rank all employees by salary highest to lowest using RANK()
-- --------------------------------------------
-- Attempt:
SELECT first_name, salary,
       RANK() OVER (ORDER BY salary DESC) AS rank
FROM employees;
-- Review: ✅ Perfect.

-- --------------------------------------------
-- Exercise 2: Assign ROW_NUMBER ordered by hire date (oldest = 1)
-- --------------------------------------------
-- Attempt:
SELECT *, ROW_NUMBER() OVER (ORDER BY hire_date) AS row_number
FROM employees;
-- Review: ✅ Correct. Oldest hire gets row 1 (ASC is default).

-- --------------------------------------------
-- Exercise 3: Within each department, rank employees by salary using DENSE_RANK()
-- --------------------------------------------
-- Attempt:
SELECT e.first_name, e.salary, d.dept_name,
       DENSE_RANK() OVER (PARTITION BY e.dept_id ORDER BY salary) AS rank
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;
-- Review: ✅ Correct join + PARTITION BY.
-- Note: ORDER BY salary sorts ASC (lowest = rank 1).
--   Conventionally salary ranking is DESC (highest = rank 1). Be explicit:
SELECT e.first_name, e.salary, d.dept_name,
       DENSE_RANK() OVER (PARTITION BY e.dept_id ORDER BY salary DESC) AS dept_rank
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;

-- --------------------------------------------
-- Exercise 4: Find the highest earner per department using ROW_NUMBER() top-N trick
-- --------------------------------------------
-- Attempt:
SELECT * FROM (
    SELECT emp_id, first_name, salary, dept_id,
           ROW_NUMBER() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS rn
    FROM employees
) WHERE rn = 1;
-- Review: ✅ Perfect top-N per group pattern.
-- Why ROW_NUMBER not RANK?
--   RANK can return multiple rn=1 rows on ties — ROW_NUMBER always gives exactly one row per group.

-- --------------------------------------------
-- Exercise 5: Divide employees into 4 salary quartiles using NTILE(4)
-- Show name, salary, quartile number and label. Quartile 1 = highest paid.
-- --------------------------------------------
-- Attempt:
SELECT first_name, salary, quartile,
    CASE quartile
        WHEN 1 THEN 'Highest Paid'
    END AS salary_band
FROM (
    SELECT first_name, salary,
           NTILE(4) OVER (ORDER BY salary DESC) AS quartile
    FROM employees
);
-- Review: ⚠️ Subquery structure and NTILE usage are correct.
--   CASE is incomplete — quartiles 2, 3, 4 return NULL (missing WHEN clauses).
-- Correct Answer:
SELECT first_name, salary, quartile,
    CASE quartile
        WHEN 1 THEN 'Top 25%'
        WHEN 2 THEN 'Upper Mid'
        WHEN 3 THEN 'Lower Mid'
        WHEN 4 THEN 'Bottom 25%'
    END AS salary_band
FROM (
    SELECT first_name, salary,
           NTILE(4) OVER (ORDER BY salary DESC) AS quartile
    FROM employees
);
-- Why subquery pattern?
--   NTILE runs once in the inner query, CASE reads the already-computed quartile column.
--   Avoids calling NTILE(4) twice — cleaner and more efficient.

-- ============================================
-- Key Takeaways
-- ============================================
-- Window functions keep all rows — unlike GROUP BY which collapses them.
-- PARTITION BY = "apply this window per group" (like GROUP BY but non-destructive).
-- ORDER BY inside OVER() = ordering within each window, not the final result.
--
-- Top-N per group pattern:
--   Step 1: ROW_NUMBER() OVER (PARTITION BY group_col ORDER BY rank_col DESC) AS rn
--   Step 2: Wrap in subquery → WHERE rn = 1
--
-- Window functions CANNOT be used in WHERE or HAVING directly:
--   ❌ WHERE RANK() OVER (...) = 1
--   ✅ Wrap in subquery → WHERE rn = 1
--
-- ============================================
-- Optimization Tips
-- ============================================
-- Index on ORDER BY column (salary, hire_date) eliminates the internal sort step.
-- ROW_NUMBER() is cheaper than RANK()/DENSE_RANK() — no tie comparison needed.
-- Top-N subquery (Ex 4) scans employees once — far better than correlated subquery.
-- NTILE requires a full sort pass — for large tables, pre-store quartile buckets
--   in a materialized column to avoid re-sorting on every query.
