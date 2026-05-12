-- ============================================
-- Day 5: JOINs Part 2
-- Concepts: Multi-table JOINs, Self JOIN
-- ============================================

-- Exercise 1: For each employee, show their manager's name (Self JOIN)
SELECT e.first_name AS employee, m.first_name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id;

-- Exercise 2: Employee name, dept name, and all projects they work on
SELECT e.first_name AS employee, d.dept_name AS department, ep.project_id AS projects
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
LEFT JOIN emp_projects ep ON e.emp_id = ep.emp_id;

-- Exercise 3: Employees who share the same department (Self JOIN)
SELECT d.dept_id AS department, e.first_name AS employees
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id;

-- Exercise 4: Find all pairs of employees in the same project
SELECT p.project_id AS project, e.first_name AS employees
FROM emp_projects p
LEFT JOIN employees e ON p.emp_id = e.emp_id;

-- Exercise 5: Full employee report — name, dept, project, role, hours
SELECT
    e.first_name   AS employee,
    d.dept_name    AS department,
    p.project_name AS project,
    ep.role        AS role,
    ep.hours
FROM employees e
LEFT JOIN departments d  ON e.dept_id      = d.dept_id
LEFT JOIN emp_projects ep ON e.emp_id      = ep.emp_id
LEFT JOIN projects p      ON ep.project_id = p.project_id;
