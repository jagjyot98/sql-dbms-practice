-- ============================================
-- Day 4: JOINs Part 1
-- Concepts: INNER JOIN, LEFT JOIN, RIGHT JOIN, FULL OUTER JOIN
-- ============================================

-- JOIN Quick Reference:
-- | JOIN Type       | Keeps unmatched LEFT | Keeps unmatched RIGHT |
-- |-----------------|----------------------|----------------------|
-- | INNER JOIN      | ❌                   | ❌                   |
-- | LEFT JOIN       | ✅                   | ❌                   |
-- | RIGHT JOIN      | ❌                   | ✅                   |
-- | FULL OUTER JOIN | ✅                   | ✅                   |

-- --------------------------------------------
-- Exercise 1: List each employee with their department name (INNER JOIN)
-- --------------------------------------------
-- Attempt:
SELECT first_name, dept_name FROM employees e INNER JOIN departments d ON e.dept_id = d.dept_id;
-- Review: ✅ Correct.
--   Result: Hank excluded — no dept_id (NULL), so no match exists.

-- --------------------------------------------
-- Exercise 2: List ALL employees, show dept name if exists (LEFT JOIN)
-- --------------------------------------------
-- Attempt:
SELECT first_name, dept_name FROM employees e LEFT JOIN departments d ON e.dept_id = d.dept_id;
-- Review: ✅ Correct.
--   Result: All 8 employees shown. Hank appears with dept_name = NULL.
--   Rule: Left table (after FROM) never loses rows in LEFT JOIN.

-- --------------------------------------------
-- Exercise 3: Which departments have NO employees?
-- --------------------------------------------
-- Attempt: (skipped)
-- Correct Answer:
SELECT d.dept_name
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
WHERE e.emp_id IS NULL;
-- Explanation: Swap table order — departments drives the query so all depts appear.
--   WHERE e.emp_id IS NULL filters to only depts with no matching employee.

-- --------------------------------------------
-- Exercise 4: List employees with their project names (3-table JOIN)
-- --------------------------------------------
-- Attempt:
SELECT e.first_name AS employee, d.dept_name AS department, p.project_id AS projects
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
LEFT JOIN emp_projects p ON e.emp_id = p.emp_id;
-- Review: ✅ Correct join logic.
--   Note: Shows project_id — to show project_name, also join the projects table:
SELECT e.first_name, p.project_name
FROM employees e
LEFT JOIN emp_projects ep ON e.emp_id = ep.emp_id
LEFT JOIN projects p ON ep.project_id = p.project_id;
-- Why 3 tables? employees and projects have no direct relationship.
--   emp_projects is the junction table: employees → emp_projects → projects

-- --------------------------------------------
-- Exercise 5: Find employees not assigned to any project
-- --------------------------------------------
-- Attempt:
SELECT first_name FROM employees e
LEFT JOIN emp_projects ep ON e.emp_id = ep.emp_id
WHERE e.emp_id IS NULL;
-- Review: ❌ Wrong column in WHERE clause.
--   e.emp_id is the PRIMARY KEY of employees → it is NEVER NULL.
--   You must check ep.emp_id IS NULL (the JOIN table's column).
-- Correct Answer:
SELECT e.first_name
FROM employees e
LEFT JOIN emp_projects ep ON e.emp_id = ep.emp_id
WHERE ep.emp_id IS NULL;

-- ============================================
-- Key Takeaways
-- ============================================
-- Golden rule for "find unmatched rows" pattern:
--   Always check IS NULL on the JOIN table (right side),
--   NEVER on the base table (left side).
--
-- | Table           | emp_id can be NULL?                      |
-- |-----------------|------------------------------------------|
-- | employees e     | ❌ It's a PRIMARY KEY — never NULL        |
-- | emp_projects ep | ✅ Yes — NULL when no match found         |
