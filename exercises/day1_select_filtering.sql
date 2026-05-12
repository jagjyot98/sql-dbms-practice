-- ============================================
-- Day 1: SELECT & Filtering
-- Concepts: SELECT, WHERE, AND/OR/NOT, BETWEEN, IN, LIKE, IS NULL
-- ============================================

-- --------------------------------------------
-- Exercise 1: List all employees with their first name, last name, and salary
-- --------------------------------------------
-- Attempt:
SELECT first_name, last_name, salary FROM employees;
-- Review: ✅ Correct

-- --------------------------------------------
-- Exercise 2: Find employees hired after 2020-01-01
-- --------------------------------------------
-- Attempt:
SELECT * FROM employees WHERE hire_date > '2020-01-01';
-- Review: ✅ Correct. > is right since the question says "after".

-- --------------------------------------------
-- Exercise 3: Find employees in department 1 OR department 2
-- --------------------------------------------
-- Attempt:
SELECT * FROM employees WHERE dept_id IN (1, 2);
-- Review: ✅ Correct.
-- Optimization: Using IN is cleaner and more scalable than writing:
--   WHERE dept_id = 1 OR dept_id = 2
-- IN performs the same but easier to read and extend.

-- --------------------------------------------
-- Exercise 4: Find employees with salary between 60,000 and 90,000
-- --------------------------------------------
-- Attempt:
SELECT * FROM employees WHERE salary BETWEEN 60000 AND 90000;
-- Review: ✅ Correct. BETWEEN is inclusive on both ends.

-- --------------------------------------------
-- Exercise 5: Find employees whose last name starts with 'S'
-- --------------------------------------------
-- Attempt:
SELECT * FROM employees WHERE last_name LIKE 'S%';
-- Review: ✅ Correct. % means "anything after S".
-- Note: LIKE is case-insensitive in SQLite but case-sensitive in PostgreSQL.
--       Use ILIKE in PostgreSQL for case-insensitive matching.

-- --------------------------------------------
-- Exercise 6: Find employees with no department assigned
-- --------------------------------------------
-- Attempt:
SELECT * FROM employees WHERE dept_id IS NULL;
-- Review: ✅ Correct. Always use IS NULL, never = NULL.

-- --------------------------------------------
-- Exercise 7: Find employees NOT in department 1 (Engineering)
-- --------------------------------------------
-- Attempt:
SELECT * FROM employees WHERE dept_id IS NOT '1';
-- Review: ❌ Wrong — two issues:
--   1. IS NOT is only for NULL checks (IS NOT NULL). For value comparison use != or <>
--   2. '1' is a string — dept_id is INT, use 1 without quotes.
-- Correct Answer:
SELECT * FROM employees WHERE dept_id != 1;
-- ⚠️  Gotcha: This returns 6 rows, not 7. Hank (dept_id IS NULL) is silently
--     excluded because NULL != 1 evaluates to NULL (not TRUE).
--     To include employees with no department:
SELECT * FROM employees WHERE dept_id != 1 OR dept_id IS NULL;

-- ============================================
-- Bonus Exercises (NULL & IS NOT NULL review)
-- ============================================

-- Exercise A: Find employees not in dept 2, including those with no department
-- Attempt:
SELECT * FROM employees WHERE dept_id != 2 OR dept_id IS NULL;
-- Review: ✅ Correct. Explicitly handles the NULL case.

-- Exercise B: Find employees who have a manager assigned
-- Attempt:
SELECT * FROM employees WHERE manager_id IS NOT NULL;
-- Review: ✅ Correct. IS NOT NULL is the right operator — not != NULL.

-- ============================================
-- Key Takeaways
-- ============================================
-- | Situation                        | Correct Operator         |
-- |----------------------------------|--------------------------|
-- | Compare a value                  | =  !=  <>                |
-- | Check for NULL                   | IS NULL                  |
-- | Check for not NULL               | IS NOT NULL              |
-- | Exclude a value + keep NULLs     | != x OR col IS NULL      |
