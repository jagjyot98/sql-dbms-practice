-- ============================================
-- Day 1: SELECT & Filtering
-- Concepts: SELECT, WHERE, AND/OR/NOT, BETWEEN, IN, LIKE, IS NULL
-- ============================================

-- Exercise 1: List all employees with their first name, last name, and salary
SELECT first_name, last_name, salary FROM employees;

-- Exercise 2: Find employees hired after 2020-01-01
SELECT * FROM employees WHERE hire_date > '2020-01-01';

-- Exercise 3: Find employees in department 1 OR department 2
SELECT * FROM employees WHERE dept_id IN (1, 2);

-- Exercise 4: Find employees with salary between 60,000 and 90,000
SELECT * FROM employees WHERE salary BETWEEN 60000 AND 90000;

-- Exercise 5: Find employees whose last name starts with 'S'
SELECT * FROM employees WHERE last_name LIKE 'S%';

-- Exercise 6: Find employees with no department assigned
SELECT * FROM employees WHERE dept_id IS NULL;

-- Exercise 7: Find employees NOT in department 1 (Engineering)
-- NOTE: IS NOT cannot be used for value comparison, only for NULL checks
-- NOTE: Plain != excludes NULL rows too, so add OR IS NULL to keep them
SELECT * FROM employees WHERE dept_id != 1 OR dept_id IS NULL;

-- ============================================
-- Bonus Exercises (from mistakes review)
-- ============================================

-- Exercise A: Find employees not in dept 2, including those with no department
SELECT * FROM employees WHERE dept_id != 2 OR dept_id IS NULL;

-- Exercise B: Find employees who have a manager assigned
SELECT * FROM employees WHERE manager_id IS NOT NULL;
