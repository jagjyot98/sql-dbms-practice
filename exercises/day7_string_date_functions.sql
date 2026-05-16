-- ============================================
-- Day 7: String & Date Functions
-- Concepts: UPPER, LOWER, LENGTH, SUBSTR, || (concat), DATE, STRFTIME, JULIANDAY
-- ============================================

-- Function Quick Reference:
-- UPPER(col)                      → uppercase
-- LOWER(col)                      → lowercase
-- col1 || ' ' || col2             → concatenate
-- LENGTH(col)                     → character count
-- SUBSTR(col, start, length)      → extract substring
-- TRIM(col)                       → remove leading/trailing spaces
-- STRFTIME('%Y/%m/%d', date_col)  → extract year/month/day
-- DATE('now')                     → today's date
-- JULIANDAY(date)                 → convert date to number (for date math)

-- --------------------------------------------
-- Exercise 1: Show full name as "SMITH, Alice" (UPPER last, as-is first)
-- --------------------------------------------
-- Attempt:
SELECT UPPER(last_name) || ', ' || first_name FROM employees;
-- Review: ✅ Perfect.
-- Optimization: Alias the column for readable output:
SELECT UPPER(last_name) || ', ' || first_name AS formatted_name FROM employees;

-- --------------------------------------------
-- Exercise 2: How many years has each employee worked? (tenure)
-- --------------------------------------------
-- Attempt:
SELECT first_name, julianday('now') - julianday(hire_date) / 365 AS Tenure_Years FROM employees;
-- Review: ❌ Operator precedence issue.
--   Division runs before subtraction, so this calculates:
--   julianday('now') - (julianday(hire_date) / 365)  ← wrong
--   Wrap the subtraction in parentheses first:
-- Correct Answer:
SELECT first_name, (JULIANDAY('now') - JULIANDAY(hire_date)) / 365 AS tenure_years
FROM employees;
-- Tip: Use CAST to get a clean integer result:
SELECT first_name, CAST((JULIANDAY('now') - JULIANDAY(hire_date)) / 365 AS INT) AS tenure_years
FROM employees;

-- --------------------------------------------
-- Exercise 3: Find employees hired in the month of March (any year)
-- --------------------------------------------
-- Attempt:
SELECT * FROM employees WHERE (SELECT STRFTIME('%m', hire_date) FROM employees) = '03';
-- Review: ❌ Wrong — subquery returns 8 rows (one per employee).
--   The = operator cannot compare against a list of rows.
--   STRFTIME works directly in WHERE on the same row's column — no subquery needed.
-- Correct Answer:
SELECT * FROM employees WHERE STRFTIME('%m', hire_date) = '03';

-- --------------------------------------------
-- Exercise 4: Extract the hire year for each employee
-- --------------------------------------------
-- Attempt:
SELECT STRFTIME('%Y', hire_date) FROM employees;
-- Review: ✅ Correct.
--   Improvement — include name and alias for readable output:
SELECT first_name, STRFTIME('%Y', hire_date) AS hire_year FROM employees;

-- --------------------------------------------
-- Exercise 5: Find employees whose full name (first + last) is longer than 10 characters
-- --------------------------------------------
-- Attempt:
SELECT * FROM employees WHERE 10 < (SELECT LENGTH(first_name || last_name) FROM employees);
-- Review: ❌ Wrong — same mistake as Ex 3. Subquery returns multiple rows.
--   LENGTH works directly in WHERE — no subquery needed.
-- Correct Answer:
SELECT * FROM employees WHERE LENGTH(first_name || last_name) > 10;

-- --------------------------------------------
-- Exercise 6: Which projects are currently active?
-- --------------------------------------------
-- Attempt: (skipped)
-- Correct Answer:
SELECT * FROM projects WHERE DATE('now') BETWEEN start_date AND end_date;

-- ============================================
-- Key Takeaways
-- ============================================
-- Rule of thumb for subqueries vs direct functions:
--
--   If the function runs on the SAME row's column → use it directly in WHERE:
--   WHERE STRFTIME('%m', hire_date) = '03'              ✅
--   WHERE LENGTH(first_name || last_name) > 10          ✅
--
--   Only use a subquery when pulling a value FROM ANOTHER ROW/TABLE:
--   WHERE salary > (SELECT AVG(salary) FROM employees)  ✅
--
-- ============================================
-- Optimization Tips
-- ============================================
-- Applying functions to columns in WHERE makes queries NON-SARGABLE.
-- The DB cannot use an index and must scan every row.
--
-- | Function in WHERE                    | Index used? | Production Fix                        |
-- |--------------------------------------|-------------|---------------------------------------|
-- | STRFTIME('%m', hire_date) = '03'     | ❌ No       | Store hire_month INT as separate col  |
-- | LENGTH(first_name || last_name) > 10 | ❌ No       | Use a computed/generated column       |
-- | JULIANDAY(hire_date)                 | ❌ No       | Compare dates directly where possible |
--
-- Better sargable alternatives:
--   Instead of: WHERE STRFTIME('%Y', hire_date) = '2020'
--   Use:        WHERE hire_date >= '2020-01-01' AND hire_date < '2021-01-01'
--               → This CAN use an index on hire_date ✅
