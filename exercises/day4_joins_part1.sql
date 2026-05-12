-- ============================================
-- Day 4: JOINs Part 1
-- Concepts: INNER JOIN, LEFT JOIN, RIGHT JOIN, FULL OUTER JOIN
-- ============================================

-- Exercise 1: List each employee with their department name (INNER JOIN)
-- Hank excluded — no dept_id
SELECT e.first_name, d.dept_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;

-- Exercise 2: List ALL employees, show dept name if exists (LEFT JOIN)
-- Hank included with dept_name = NULL
SELECT e.first_name, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;

-- Exercise 3: Which departments have NO employees?
-- Swap table order — departments drives the query
SELECT d.dept_name
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
WHERE e.emp_id IS NULL;

-- Exercise 4: List employees with their project names (3-table JOIN)
-- employees → emp_projects → projects
SELECT e.first_name, p.project_name
FROM employees e
LEFT JOIN emp_projects ep ON e.emp_id = ep.emp_id
LEFT JOIN projects p ON ep.project_id = p.project_id;

-- Exercise 5: Find employees not assigned to any project
-- Golden rule: check IS NULL on the JOIN table (right side)
SELECT e.first_name
FROM employees e
LEFT JOIN emp_projects ep ON e.emp_id = ep.emp_id
WHERE ep.emp_id IS NULL;
