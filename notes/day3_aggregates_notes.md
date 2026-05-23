# Day 3 — Aggregate Functions

## Concepts Covered
`COUNT` `SUM` `AVG` `MIN` `MAX` `GROUP BY` `HAVING`

---

## Syntax Reference

```sql
-- Aggregate functions
SELECT COUNT(*) FROM employees;                    -- total rows
SELECT COUNT(dept_id) FROM employees;              -- excludes NULLs
SELECT SUM(salary) FROM employees;
SELECT AVG(salary) FROM employees;
SELECT MIN(salary), MAX(salary) FROM employees;

-- Grouping
SELECT dept_id, COUNT(*) AS employee_count
FROM employees
GROUP BY dept_id;

-- Filtering groups
SELECT dept_id, COUNT(*) AS employee_count
FROM employees
GROUP BY dept_id
HAVING COUNT(*) > 2;

-- WHERE + GROUP BY + HAVING together
SELECT dept_id, AVG(salary) AS avg_salary
FROM employees
WHERE hire_date > '2018-01-01'         -- filter rows first
GROUP BY dept_id
HAVING AVG(salary) > 70000;            -- filter groups after
```

---

## SQL Logical Execution Order

This is the order SQL actually processes a query — not the order you write it:

```
1. FROM        → which table(s)
2. JOIN        → combine tables
3. WHERE       → filter rows BEFORE grouping
4. GROUP BY    → group the filtered rows
5. HAVING      → filter groups AFTER grouping
6. SELECT      → pick which columns to return
7. ORDER BY    → sort the results
8. LIMIT       → restrict output rows
```

> This explains why you **cannot** use a SELECT alias in WHERE — WHERE runs before SELECT.

---

## WHERE vs HAVING

| | WHERE | HAVING |
|--|-------|--------|
| Runs | Before GROUP BY | After GROUP BY |
| Filters | Individual rows | Groups |
| Can use aggregates? | ❌ No | ✅ Yes |
| Example | `WHERE salary > 50000` | `HAVING COUNT(*) > 2` |

---

## COUNT(*) vs COUNT(col)

```sql
COUNT(*)        -- counts ALL rows including NULLs
COUNT(dept_id)  -- counts only non-NULL values in dept_id
COUNT(DISTINCT dept_id) -- counts unique non-NULL values
```

---

## Examples

```sql
-- Employees per department (including NULL dept)
SELECT dept_id, COUNT(*) AS employee_count
FROM employees
GROUP BY dept_id;

-- Average salary per department, only depts with avg > 70k
SELECT dept_id, AVG(salary) AS avg_salary
FROM employees
GROUP BY dept_id
HAVING AVG(salary) > 70000;

-- Total hours per project, only projects with > 200 hours
SELECT project_id, SUM(hours) AS total_hours
FROM emp_projects
GROUP BY project_id
HAVING SUM(hours) > 200;
```

---

## My Shortcomings

| Exercise | Mistake | Correct Approach |
|----------|---------|-----------------|
| Ex 2 | `SELECT AVG(salary) ... GROUP BY dept_id` — no dept_id in SELECT | Always include the GROUP BY column in SELECT for meaningful output |
| Ex 4, 6, 7 | No column aliases on aggregates | Alias aggregate columns: `COUNT(*) AS employee_count` |
| Ex 5 | Did not filter out NULL dept_id group | Add `WHERE dept_id IS NOT NULL` before GROUP BY if NULL groups are noise |

---

## Key Takeaways

```
WHERE filters rows — runs before GROUP BY.
HAVING filters groups — runs after GROUP BY, can use aggregates.
Always include GROUP BY columns in SELECT.
Always alias aggregate columns for readable output.
COUNT(*) includes NULLs. COUNT(col) excludes NULLs.
```
