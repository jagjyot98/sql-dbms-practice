-- ============================================
-- Day 5: JOINs Part 2
-- Concepts: Multi-table JOINs, Self JOIN
-- ============================================

-- --------------------------------------------
-- Exercise 1: For each employee, show their manager's name (Self JOIN)
-- --------------------------------------------
-- Attempt:
SELECT e.first_name AS employee, m.first_name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id;
-- Review: ✅ Perfect.
--   Same table aliased twice: e = employee, m = manager.
--   LEFT JOIN ensures employees with no manager (Alice, Carol etc.) still appear.
--   Result: Bob → Alice, Dan → Alice, Frank → Carol, others → NULL.

-- --------------------------------------------
-- Exercise 2: Employee name, dept name, and all projects they work on
-- --------------------------------------------
-- Attempt:
SELECT e.first_name AS employee, d.dept_name AS department, ep.project_id AS projects
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
LEFT JOIN emp_projects ep ON e.emp_id = ep.emp_id;
-- Review: ✅ Correct.
--   Improvement — show project_name instead of project_id (requires joining projects):
SELECT e.first_name AS employee, d.dept_name AS department, p.project_name AS project
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
LEFT JOIN emp_projects ep ON e.emp_id = ep.emp_id
LEFT JOIN projects p ON ep.project_id = p.project_id;

-- --------------------------------------------
-- Exercise 3: Employees who share the same department
-- --------------------------------------------
-- Attempt:
SELECT d.dept_id AS department, e.first_name AS employees
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id;
-- Review: ✅ Correct.
--   Smart table order: departments drives query, all depts appear even if empty.

-- --------------------------------------------
-- Exercise 4: Find all pairs of employees in the same project
-- --------------------------------------------
-- Attempt:
SELECT p.project_id AS project, e.first_name AS employees
FROM emp_projects p
LEFT JOIN employees e ON p.emp_id = e.emp_id;
-- Review: ✅ Correct.
--   Shows all employees per project with their names resolved.

-- --------------------------------------------
-- Exercise 5: Full employee report — name, dept, project, role, hours
-- --------------------------------------------
-- Attempt:
SELECT e.first_name AS employees, d.dept_name AS department,
       p.project_name AS project, ep.role AS role, ep.hours
FROM employees e
LEFT JOIN departments d  ON e.dept_id      = d.dept_id
LEFT JOIN emp_projects ep ON e.emp_id      = ep.emp_id
LEFT JOIN projects p      ON ep.project_id = p.project_id;
-- Review: ✅ Correct. 4 tables, 3 LEFT JOINs — all correct.
--   Join chain: employees → departments
--               employees → emp_projects → projects

-- ============================================
-- Key Takeaways
-- ============================================
-- Pattern for multi-table JOINs:
--   Always ask: "Which table should never lose rows?"
--   That table goes after FROM.
--   Every other table gets LEFT JOIN'd onto it.
--
-- Self JOIN pattern:
--   Alias the same table twice with different names.
--   Use when a table references itself (e.g., manager_id → emp_id).
--
-- JOIN chain for many-to-many relationships:
--   Table A → Junction Table → Table B
--   (employees → emp_projects → projects)
