-- ============================================
-- Day 8: CASE Expressions
-- Concepts: CASE WHEN, CASE with aggregates, derived categories
-- ============================================

-- CASE Syntax:
-- Searched CASE (most common):
--   CASE
--       WHEN condition1 THEN 'result1'
--       WHEN condition2 THEN 'result2'
--       ELSE 'default'
--   END
--
-- Simple CASE (compare one column to fixed values):
--   CASE col
--       WHEN value1 THEN 'result1'
--       WHEN value2 THEN 'result2'
--       ELSE 'default'
--   END

-- --------------------------------------------
-- Exercise 1: Classify salary as Low / Mid / High
-- --------------------------------------------
-- Attempt:
SELECT first_name, salary,
CASE
    WHEN salary > '85000' THEN 'High'
    WHEN salary > '65000' AND salary < '85000' THEN 'Mid'
    WHEN salary < '65000' THEN 'Low'
END AS Classification
FROM employees;
-- Review: ❌ Two issues:
--   1. Salary compared against string literals ('85000') — salary is numeric, never quote numbers.
--      SQLite silently casts it, but PostgreSQL/MySQL will break.
--   2. Boundary gap — salary = 85000 matches neither > 85000 nor < 85000 → returns NULL.
--      Use cascading conditions instead of AND ranges.
-- Correct Answer:
SELECT first_name, salary,
CASE
    WHEN salary >= 85000 THEN 'High'
    WHEN salary >= 65000 THEN 'Mid'   -- cascading: >= 65000 and not already caught by High
    ELSE 'Low'
END AS classification
FROM employees;

-- --------------------------------------------
-- Exercise 2: Label tenure as Junior / Mid / Senior
-- --------------------------------------------
-- Attempt:
SELECT first_name, hire_date,
CASE
    WHEN (JULIANDAY('now') - JULIANDAY(hire_date)) / 365 < 2  THEN 'Junior'
    WHEN (JULIANDAY('now') - JULIANDAY(hire_date)) / 365 > 2
     AND (JULIANDAY('now') - JULIANDAY(hire_date)) / 365 < 5  THEN 'Mid'
    WHEN (JULIANDAY('now') - JULIANDAY(hire_date)) / 365 > 5  THEN 'Senior'
END AS Label
FROM employees;
-- Review: ⚠️ Boundary gap — exactly 2 or 5 years returns NULL.
--   Also unnecessarily verbose with AND ranges. Use cascading conditions.
-- Correct Answer:
SELECT first_name, hire_date,
CASE
    WHEN (JULIANDAY('now') - JULIANDAY(hire_date)) / 365 < 2 THEN 'Junior'
    WHEN (JULIANDAY('now') - JULIANDAY(hire_date)) / 365 < 5 THEN 'Mid'
    ELSE 'Senior'
END AS label
FROM employees;
-- Why cascading works:
--   If < 2 is false, the row has tenure >= 2. Next check < 5 catches 2–4.99. ELSE catches 5+.

-- --------------------------------------------
-- Exercise 3: Count employees per salary band
-- --------------------------------------------
-- Attempt:
SELECT
    COUNT(CASE WHEN salary > '85000' THEN 1 END) AS High,
    COUNT(CASE WHEN salary > '65000' AND salary < '85000' THEN 1 END) AS Mid,
    COUNT(CASE WHEN salary < '65000' THEN 1 END) AS Low
FROM employees;
-- Review: ⚠️ Same string comparison issue as Ex 1 — replace '85000' with 85000.
--   Structure and COUNT(CASE...) pattern are correct.
-- Correct Answer:
SELECT
    COUNT(CASE WHEN salary >= 85000 THEN 1 END) AS high_count,
    COUNT(CASE WHEN salary >= 65000 AND salary < 85000 THEN 1 END) AS mid_count,
    COUNT(CASE WHEN salary < 65000 THEN 1 END) AS low_count
FROM employees;
-- Why COUNT(CASE...) works:
--   COUNT only counts non-NULL values.
--   When CASE condition is false and no ELSE is set, it returns NULL → skipped by COUNT.

-- --------------------------------------------
-- Exercise 4: Label each project as Upcoming / Active / Completed
-- --------------------------------------------
-- Attempt:
SELECT project_name, start_date, end_date,
CASE
    WHEN JULIANDAY('now') - JULIANDAY(start_date) < 0 THEN 'Upcoming'
    WHEN JULIANDAY('now') - JULIANDAY(start_date) > 0
     AND JULIANDAY('now') - JULIANDAY(end_date)   < 0 THEN 'Active'
    WHEN JULIANDAY('now') - JULIANDAY(end_date)   > 0 THEN 'Completed'
END AS status
FROM projects;
-- Review: ✅ Correct. JULIANDAY math logic is solid.
-- Simpler alternative using direct date comparison (more readable):
SELECT project_name, start_date, end_date,
CASE
    WHEN DATE('now') < start_date                    THEN 'Upcoming'
    WHEN DATE('now') BETWEEN start_date AND end_date THEN 'Active'
    ELSE 'Completed'
END AS status
FROM projects;

-- --------------------------------------------
-- Exercise 5: Label each department location as HQ or Remote
-- --------------------------------------------
-- Attempt:
SELECT dept_name,
CASE
    WHEN location IS 'New York' THEN 'HQ'
    ELSE 'Remote'
END AS Label
FROM departments;
-- Review: ❌ IS is for NULL checks only — not for value comparison.
--   SQLite allows IS as equality (a quirk), but PostgreSQL/MySQL will error.
-- Correct Answer:
SELECT dept_name,
CASE
    WHEN location = 'New York' THEN 'HQ'
    ELSE 'Remote'
END AS label
FROM departments;

-- ============================================
-- Key Takeaways
-- ============================================
-- | Mistake                  | Rule                                          |
-- |--------------------------|-----------------------------------------------|
-- | Quoting numbers '85000'  | Never quote numeric values                    |
-- | IS for equality          | IS / IS NOT → NULL only. = / != → values      |
-- | AND range conditions     | Use cascading CASE — first match wins          |
--
-- CASE evaluates top to bottom — first match wins, rest are skipped.
-- Always order conditions from most specific to least specific.
-- ELSE catches everything not matched — avoids unexpected NULLs.
--
-- ============================================
-- Optimization Tips
-- ============================================
-- CASE in SELECT is computed per row — no index can help.
-- If you filter on a classification frequently:
--   → Store it as a real column with a CHECK constraint
--   → Or use a computed/generated column (supported in PostgreSQL, MySQL 5.7+)
--
-- Avoid repeating long expressions (like JULIANDAY tenure calc) in every WHEN.
-- Wrap in a CTE or subquery to compute once (covered Day 12):
--   WITH tenure AS (
--       SELECT first_name, (JULIANDAY('now') - JULIANDAY(hire_date)) / 365 AS years
--       FROM employees
--   )
--   SELECT first_name, CASE WHEN years < 2 THEN 'Junior' ... END FROM tenure;
