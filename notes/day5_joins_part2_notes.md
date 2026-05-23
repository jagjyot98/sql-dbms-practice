# Day 5 — JOINs Part 2

## Concepts Covered
Self JOIN · Multi-table JOINs · JOIN chain pattern

---

## Self JOIN

A self JOIN joins a table to itself. Used when a table has a column referencing its own primary key.

Classic use case: **employee → manager** (both are rows in the same `employees` table).

```sql
-- Alias the same table twice with different names
SELECT e.first_name AS employee, m.first_name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id;
```

Why `LEFT JOIN`? Employees with no manager (like Alice) would be dropped by INNER JOIN. LEFT JOIN keeps them with `manager = NULL`.

---

## Multi-Table JOIN Pattern

```
Ask: Which table should NEVER lose rows?
→ That table goes after FROM.
→ Every other table gets LEFT JOIN'd onto it.
```

```sql
-- employees is the anchor — we want all employees regardless of dept or project
SELECT e.first_name, d.dept_name, p.project_name, ep.role, ep.hours
FROM employees e
LEFT JOIN departments d  ON e.dept_id      = d.dept_id
LEFT JOIN emp_projects ep ON e.emp_id      = ep.emp_id
LEFT JOIN projects p      ON ep.project_id = p.project_id;
```

---

## Many-to-Many JOIN Chain

When two tables have a many-to-many relationship, they connect through a junction table:

```
employees ──→ emp_projects ──→ projects
  e.emp_id = ep.emp_id    ep.project_id = p.project_id
```

One employee can work on many projects. One project can have many employees.
The junction table `emp_projects` holds the pairs.

---

## Examples

```sql
-- Self JOIN: each employee with their manager's name
SELECT e.first_name AS employee, m.first_name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id;

-- Multi-table: employee, their dept, and their projects
SELECT e.first_name, d.dept_name, p.project_name
FROM employees e
LEFT JOIN departments d   ON e.dept_id      = d.dept_id
LEFT JOIN emp_projects ep ON e.emp_id       = ep.emp_id
LEFT JOIN projects p      ON ep.project_id  = p.project_id;

-- Self JOIN: find pairs of employees in the same department
SELECT a.first_name AS employee1, b.first_name AS employee2, a.dept_id
FROM employees a
JOIN employees b ON a.dept_id = b.dept_id AND a.emp_id < b.emp_id;
-- a.emp_id < b.emp_id avoids duplicates (Alice+Bob and Bob+Alice)
```

---

## My Shortcomings

No major mistakes on Day 5. All 5 exercises correct.

**One improvement noted:**
- Ex 2: Showed `project_id` instead of `project_name`. To show project name, join the `projects` table as well.

---

## Key Takeaways

```
Self JOIN: alias the same table twice — one for each "role" (employee, manager).
Always LEFT JOIN in a self join when some rows may have no match (e.g., no manager).
Anchor table (the one you never want to lose) goes after FROM.
Many-to-many: always go through the junction table.
a.emp_id < b.emp_id trick: avoids duplicate pairs in self joins.
```
