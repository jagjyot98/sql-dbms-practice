# Revision — Days 1 to 5

## Topics Covered
SELECT & Filtering · Sorting & Limiting · Aggregate Functions · JOINs Part 1 & 2

---

## Score Summary

| Day | Score | Key Miss |
|-----|-------|----------|
| Day 1 | 4/4 ✅ | — |
| Day 2 | 3/4 | Missing DESC in ORDER BY |
| Day 3 | 2/4 | WHERE instead of HAVING; STRFTIME grouping |
| Day 4 | 1/3 | INNER vs LEFT JOIN; wrong self-join for dept count |
| Day 5 | 1/3 | GROUP BY on JOIN table column; missing HAVING; COUNT(*) on LEFT JOIN |

---

## Recurring Mistakes & Fixes

### 1. WHERE instead of HAVING for aggregate filtering

```sql
-- ❌ Wrong — filters rows before grouping, not groups after
SELECT dept_id, MIN(salary) FROM employees
WHERE salary > 60000
GROUP BY dept_id;

-- ✅ Correct — filters groups after aggregation
SELECT dept_id, MIN(salary) FROM employees
GROUP BY dept_id
HAVING MIN(salary) > 60000;
```

**Why it matters:** WHERE on `salary > 60000` removes individual employees first.
A dept with salaries [50k, 80k] loses the 50k employee → MIN becomes 80k → dept incorrectly included.
HAVING checks the actual group minimum after all rows are considered.

---

### 2. Missing DESC in ORDER BY

```sql
-- ❌ Wrong — sorts oldest first, OFFSET skips oldest not newest
SELECT * FROM employees ORDER BY hire_date LIMIT 2 OFFSET 2;

-- ✅ Correct — sorts newest first, OFFSET skips the 2 most recent
SELECT * FROM employees ORDER BY hire_date DESC LIMIT 2 OFFSET 2;
```

**Rule:** Always be explicit with `DESC` when you want highest/latest/largest first.

---

### 3. INNER JOIN when question says "include all"

```sql
-- ❌ Wrong — INNER JOIN drops Hank (no department)
SELECT e.first_name, d.location
FROM employees e JOIN departments d ON e.dept_id = d.dept_id;

-- ✅ Correct — LEFT JOIN keeps all employees
SELECT e.first_name, d.location
FROM employees e LEFT JOIN departments d ON e.dept_id = d.dept_id;
```

**Rule:** Default to LEFT JOIN when the question says "include all [left table] rows".

---

### 4. Wrong table order for "include depts with zero employees"

```sql
-- ❌ Wrong — employees drives query, departments with no employees never appear
SELECT e.dept_id, COUNT(*)
FROM employees e LEFT JOIN employees ep ON e.emp_id = ep.emp_id
GROUP BY e.dept_id;

-- ✅ Correct — departments drives query, all departments appear
SELECT d.dept_id, d.dept_name, COUNT(e.emp_id) AS employee_count
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;
```

**Rule:** The table you never want to lose rows from goes after `FROM`.

---

### 5. GROUP BY on JOIN table column instead of base table

```sql
-- ❌ Wrong — NULL employees (no project) all collapse into one NULL group
GROUP BY ep.emp_id

-- ✅ Correct — each employee gets their own group
GROUP BY e.emp_id, e.first_name
```

**Rule:** Always GROUP BY the **base table** column (the one after FROM), not the JOIN table.

---

### 6. COUNT(*) vs COUNT(col) on LEFT JOINs

```sql
-- ❌ COUNT(*) — returns 1 for unmatched rows (counts the NULL row)
COUNT(*)

-- ✅ COUNT(e.emp_id) — returns 0 for unmatched rows (skips NULLs)
COUNT(e.emp_id)

-- ✅ COUNT(ep.project_id) — counts only actual project assignments
COUNT(ep.project_id)
```

**Rule:** On LEFT JOINs, always `COUNT(col)` where `col` is from the JOIN table.
`COUNT(*)` gives phantom counts of 1 for rows with no match.

---

### 7. Missing HAVING filter

```sql
-- ❌ Wrong — returns ALL employees with project count, not just those with > 1
SELECT e.first_name, COUNT(ep.project_id) AS project_count
FROM employees e
LEFT JOIN emp_projects ep ON e.emp_id = ep.emp_id
GROUP BY e.emp_id;

-- ✅ Correct — filters to only employees with more than 1 project
SELECT e.first_name, COUNT(ep.project_id) AS project_count
FROM employees e
LEFT JOIN emp_projects ep ON e.emp_id = ep.emp_id
GROUP BY e.emp_id, e.first_name
HAVING COUNT(ep.project_id) > 1;
```

---

## Concepts That Were Solid ✅

- NULL handling with `IS NULL` / `IS NOT NULL` / `OR dept_id IS NULL`
- Anti-JOIN pattern: `LEFT JOIN ... WHERE join_table.col IS NULL`
- Self JOIN for employee → manager relationship
- Multi-table LEFT JOIN chain
- `WHERE manager_id IS NOT NULL` before GROUP BY to clean input
- DISTINCT on multiple columns for unique combinations

---

## New Pattern Learned — Extracting Year for GROUP BY

```sql
SELECT STRFTIME('%Y', hire_date) AS hire_year, COUNT(*) AS employee_count
FROM employees
GROUP BY STRFTIME('%Y', hire_date)
ORDER BY hire_year;
```

Key: GROUP BY must use the **same expression** as SELECT, not the alias.
`GROUP BY hire_year` would fail in most DBs — use `GROUP BY STRFTIME('%Y', hire_date)`.

---

## Full Rule Reference

| Situation | Rule |
|-----------|------|
| Filter individual rows | `WHERE` |
| Filter after grouping | `HAVING` with aggregate |
| Want all rows from one table | Put it after `FROM`, use `LEFT JOIN` |
| Count with LEFT JOIN | `COUNT(col)` not `COUNT(*)` |
| GROUP BY with JOIN | GROUP BY base table column, not JOIN table |
| Sort highest/latest first | Explicit `DESC` |
| Exclude a value + keep NULLs | `!= x OR col IS NULL` |

---

## Optimization Tips

- **Index on `dept_id`, `manager_id`** — speeds up GROUP BY and JOIN operations on these columns significantly
- **`COUNT(e.emp_id)` on LEFT JOINs** — more efficient than `COUNT(*)` and semantically correct
- **Index on `hire_date`** — helps ORDER BY and range filters; STRFTIME on hire_date is non-sargable (full scan), so for large tables store `hire_year` as a separate column
- **Q10 (top manager)**: Index on `manager_id` makes the GROUP BY an index-only scan — no heap access needed
