-- ============================================
-- Day 2: Sorting & Limiting
-- Concepts: ORDER BY, LIMIT, DISTINCT, OFFSET
-- ============================================

-- Exercise 1: List all employees sorted by salary highest to lowest
SELECT * FROM employees ORDER BY salary DESC;

-- Exercise 2: Top 3 highest-paid employees (name + salary)
SELECT first_name, salary FROM employees ORDER BY salary DESC LIMIT 3;

-- Exercise 3: List all unique locations from departments
SELECT DISTINCT location FROM departments;

-- Exercise 4: Show the 2nd and 3rd highest-paid employees
-- OFFSET = rows to skip | LIMIT = rows to return
SELECT first_name, salary FROM employees ORDER BY salary DESC LIMIT 2 OFFSET 1;

-- Exercise 5: Show 5 most recently hired employees (name + hire_date)
SELECT first_name, hire_date FROM employees ORDER BY hire_date DESC LIMIT 5;
