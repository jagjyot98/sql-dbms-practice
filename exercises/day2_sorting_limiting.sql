-- ============================================
-- Day 2: Sorting & Limiting
-- Concepts: ORDER BY, LIMIT, DISTINCT, OFFSET
-- ============================================

-- --------------------------------------------
-- Exercise 1: List all employees sorted by salary highest to lowest
-- --------------------------------------------
-- Attempt:
SELECT * FROM employees ORDER BY salary;
-- Review: ✅ Correct — with a note.
--   Default sort is ASC (lowest to highest). The question asked highest to lowest.
--   Always be explicit with DESC when required:
SELECT * FROM employees ORDER BY salary DESC;

-- --------------------------------------------
-- Exercise 2: Top 3 highest-paid employees (name + salary)
-- --------------------------------------------
-- Attempt:
SELECT first_name, salary FROM employees ORDER BY salary DESC LIMIT 3;
-- Review: ✅ Perfect.

-- --------------------------------------------
-- Exercise 3: List all unique locations from departments
-- --------------------------------------------
-- Attempt:
SELECT DISTINCT location FROM departments;
-- Review: ✅ Perfect.
--   Returns: New York, Chicago, Austin (New York appears once despite two depts).

-- --------------------------------------------
-- Exercise 4: Show the 2nd and 3rd highest-paid employees
-- --------------------------------------------
-- Attempt:
SELECT first_name, salary FROM employees ORDER BY salary DESC LIMIT 3 OFFSET 1;
-- Review: ❌ Close, but off by one.
--   OFFSET 1 skips only 1 row → gives you ranks 2nd, 3rd, 4th (3 rows, not 2).
--   You want to skip 1 row and return exactly 2 rows.
-- Correct Answer:
SELECT first_name, salary FROM employees ORDER BY salary DESC LIMIT 2 OFFSET 1;
-- Fix: LIMIT 3 → LIMIT 2 (you only want 2 employees: 2nd and 3rd)
--      OFFSET 1 was already correct (skip the 1st highest)

-- --------------------------------------------
-- Exercise 5: Show 5 most recently hired employees (name + hire_date)
-- --------------------------------------------
-- Attempt:
SELECT first_name, hire_date FROM employees ORDER BY hire_date DESC LIMIT 5;
-- Review: ✅ Perfect.

-- ============================================
-- Key Takeaways
-- ============================================
-- OFFSET = how many rows to skip from the top
-- LIMIT  = how many rows to return after skipping
--
-- Pattern: "rows M through N"
--   LIMIT  = N - M + 1   (how many rows you want)
--   OFFSET = M - 1       (how many to skip)
--
-- Example: rows 2 and 3 → LIMIT 2 OFFSET 1
-- Example: rows 5 to 10 → LIMIT 6 OFFSET 4
