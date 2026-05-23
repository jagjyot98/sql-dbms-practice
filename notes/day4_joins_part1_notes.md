# Day 4 — JOINs Part 1

## Concepts Covered
`INNER JOIN` `LEFT JOIN` `RIGHT JOIN` `FULL OUTER JOIN`

---

## Syntax Reference

```sql
-- INNER JOIN — only matching rows from both sides
SELECT e.first_name, d.dept_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;

-- LEFT JOIN — all rows from left + matches from right (NULL if no match)
SELECT e.first_name, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;

-- RIGHT JOIN — all rows from right + matches from left (NULL if no match)
SELECT e.first_name, d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;

-- FULL OUTER JOIN — all rows from both sides (not supported in SQLite)
SELECT e.first_name, d.dept_name
FROM employees e
FULL OUTER JOIN departments d ON e.dept_id = d.dept_id;
```

---

## JOIN Type Reference

| JOIN Type | Keeps unmatched LEFT | Keeps unmatched RIGHT |
|-----------|----------------------|-----------------------|
| INNER JOIN | ❌ | ❌ |
| LEFT JOIN | ✅ | ❌ |
| RIGHT JOIN | ❌ | ✅ |
| FULL OUTER JOIN | ✅ | ✅ |

> **"Left" table** = the one after `FROM`. **"Right" table** = the one after `JOIN`.

---

## Finding Unmatched Rows (Anti-JOIN Pattern)

The most common use of LEFT JOIN + NULL check:

```sql
-- Employees NOT assigned to any project
SELECT e.first_name
FROM employees e
LEFT JOIN emp_projects ep ON e.emp_id = ep.emp_id
WHERE ep.emp_id IS NULL;     -- NULL on right side = no match found
```

**Golden rule:** Always check `IS NULL` on the **JOIN table** (right side), never on the base table.

| Table | emp_id can be NULL? | Why |
|-------|---------------------|-----|
| `employees e` | ❌ Never | It's a PRIMARY KEY |
| `emp_projects ep` | ✅ Yes | NULL when LEFT JOIN finds no match |

---

## 3-Table JOIN (Junction Table Pattern)

When two tables have no direct relationship, connect through a junction table:

```sql
-- employees → emp_projects → projects
SELECT e.first_name, p.project_name
FROM employees e
LEFT JOIN emp_projects ep ON e.emp_id = ep.emp_id
LEFT JOIN projects p ON ep.project_id = p.project_id;
```

---

## Examples

```sql
-- All employees with department (INNER — excludes Hank who has no dept)
SELECT e.first_name, d.dept_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;

-- All employees with department (LEFT — includes Hank with dept_name = NULL)
SELECT e.first_name, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;

-- Departments with no employees
SELECT d.dept_name
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
WHERE e.emp_id IS NULL;
```

---

## My Shortcomings

| Exercise | Mistake | Correct Approach |
|----------|---------|-----------------|
| Ex 5 | `WHERE e.emp_id IS NULL` | Should be `WHERE ep.emp_id IS NULL` — check IS NULL on the JOIN table, not the base table |
| Ex 4 | Skipped 3-table join | Use junction table: `employees → emp_projects → projects` |

---

## Key Takeaways

```
Table after FROM = left table (never loses rows in LEFT JOIN).
Table after JOIN = right table.
Anti-JOIN pattern: LEFT JOIN + WHERE right_table.col IS NULL → unmatched rows.
Always check IS NULL on the JOIN table (right), not the base table (left).
FULL OUTER JOIN not supported in SQLite — simulate with LEFT JOIN UNION RIGHT JOIN.
```
