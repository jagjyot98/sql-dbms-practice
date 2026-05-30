# Revision — Days 6 to 8

## Topics Covered
Subqueries · String & Date Functions · CASE Expressions

---

## Score Summary

| Day | Score | Key Miss |
|-----|-------|----------|
| Day 6 | 4/6 | Redundant GROUP BY in correlated subquery; Q6 skipped |
| Day 7 | 3/5 | CAST missing on STRFTIME modulo; CASE wrapped in subquery again |
| Day 8 | 2/4 | ORDER BY budget DESC vs CASE in ORDER BY; STRFTIME vs integer comparison |

---

## Recurring Mistakes & Fixes

### 1. Wrapping direct CASE expressions inside subqueries

This mistake appeared in the original Day 7 exercises and repeated here in Q11.

```sql
-- ❌ Wrong — subquery returns 8 rows, scalar position needs exactly 1
(SELECT CASE WHEN STRFTIME('%m', hire_date) = '01' THEN 'Jan' ... FROM employees)

-- ✅ Correct — CASE runs directly on the current row's column, no subquery needed
CASE STRFTIME('%m', hire_date)
    WHEN '01' THEN 'Jan'
    WHEN '02' THEN 'Feb'
    ...
END
```

**Rule:** If the expression references the **current row's column** → use it directly.
Only use a subquery when pulling a value from **another row or another table**.

---

### 2. STRFTIME string vs numeric type mismatch

```sql
-- ❌ Unreliable — STRFTIME returns '2019' (string), comparing with 2020 (integer)
WHERE STRFTIME('%Y', hire_date) < 2020
WHERE STRFTIME('%Y', hire_date) % 2 = 0   -- modulo on string

-- ✅ Correct — compare strings with strings
WHERE STRFTIME('%Y', hire_date) < '2020'
WHERE CAST(STRFTIME('%Y', hire_date) AS INT) % 2 = 0

-- ✅ Best — direct date comparison (sargable, uses index if available)
WHERE hire_date < '2020-01-01'
```

**Rule:** `STRFTIME` always returns a **string**. For arithmetic or numeric comparison, `CAST` to INT first.

---

### 3. ORDER BY column vs ORDER BY CASE for custom label ordering

```sql
-- ⚠️ Works for this data but not semantically correct
ORDER BY budget DESC

-- ✅ Correct for custom label ordering (Big → Mid → Low)
ORDER BY
    CASE
        WHEN budget > 800000 THEN 1
        WHEN budget BETWEEN 300000 AND 800000 THEN 2
        ELSE 3
    END
```

**When to use CASE in ORDER BY:**
- When you want labels sorted in a specific order that doesn't align with numeric order
- When two rows could have the same numeric value but different labels

---

### 4. Redundant GROUP BY inside correlated subquery

```sql
-- ⚠️ GROUP BY is redundant — WHERE already isolates one department
(SELECT MAX(salary) FROM employees ep
 WHERE ep.dept_id = e.dept_id GROUP BY ep.dept_id)

-- ✅ Clean and correct
(SELECT MAX(salary) FROM employees ep WHERE ep.dept_id = e.dept_id)
```

**Rule:** In a correlated subquery, the WHERE clause already filters to one group.
GROUP BY adds no value and adds confusion.

---

## Concepts That Were Solid ✅

- Scalar subquery: `WHERE salary > (SELECT salary ... WHERE first_name = 'Bob')`
- IN subquery: `WHERE project_id IN (SELECT project_id FROM emp_projects)`
- NOT EXISTS with correlated condition: `WHERE NOT EXISTS (SELECT 1 FROM ep WHERE ep.emp_id = e.emp_id)`
- JULIANDAY for date differences: `JULIANDAY(end_date) - JULIANDAY(start_date)`
- SUBSTR for string slicing: `SUBSTR(last_name, 1, 1)` for initial
- CASE cascading logic for multi-condition flags (correct structure, wrong type)
- COUNT(CASE WHEN ...) pivot pattern

---

## New Patterns Learned

### NOT EXISTS — How it works step by step

```sql
SELECT * FROM employees e
WHERE NOT EXISTS (SELECT 1 FROM emp_projects ep WHERE e.emp_id = ep.emp_id);
```

1. Outer query fetches first employee row (e.g., Alice, emp_id = 1)
2. Inner query runs: `SELECT 1 FROM emp_projects WHERE emp_id = 1`
3. Alice has projects → inner query returns rows → EXISTS = TRUE → NOT EXISTS = FALSE → Alice excluded
4. Repeat for each employee
5. Employees with no projects → inner query returns nothing → NOT EXISTS = TRUE → included

**Key:** `SELECT 1` is a convention — EXISTS only cares about whether rows exist, not what's selected.

---

### Nested Subquery for "Most Total Hours"

```sql
-- Pattern: find the row(s) matching an aggregate of an aggregate
SELECT e.first_name, SUM(ep.hours) AS total_hours
FROM employees e
JOIN emp_projects ep ON e.emp_id = ep.emp_id
GROUP BY e.emp_id, e.first_name
HAVING SUM(ep.hours) = (
    SELECT MAX(total)
    FROM (
        SELECT SUM(hours) AS total        -- inner: total per employee
        FROM emp_projects
        GROUP BY emp_id
    )                                     -- outer: max of those totals
);
```

Use HAVING (not WHERE) to filter on aggregate results.
This pattern handles **ties** — returns all employees with the max total.

---

### Simple CASE for Month Name Mapping

```sql
-- Use Simple CASE when comparing one expression to fixed values
CASE STRFTIME('%m', hire_date)
    WHEN '01' THEN 'Jan'
    WHEN '02' THEN 'Feb'
    ...
END
```

Cleaner than Searched CASE (`WHEN STRFTIME('%m') = '01' THEN`) when the same expression is compared repeatedly.

---

## Full Rule Reference

| Situation | Rule |
|-----------|------|
| CASE on current row's column | Use directly in SELECT — no subquery needed |
| STRFTIME result | Always a string — CAST to INT for arithmetic |
| Custom sort order | CASE in ORDER BY, not ORDER BY column |
| Correlated subquery | No GROUP BY needed — WHERE already filters to one group |
| NOT IN with possible NULLs | Use NOT EXISTS instead |
| Date comparison | Direct `hire_date < '2020-01-01'` is sargable; `STRFTIME(...)` is not |

---

## Optimization Tips

- `hire_date < '2020-01-01'` is **sargable** — can use an index on `hire_date`
- `STRFTIME('%Y', hire_date) < '2020'` is **non-sargable** — full table scan every time
- For Q6 (max hours), the nested subquery scans `emp_projects` twice — a CTE computes totals once and reuses (covered Day 12):
```sql
WITH totals AS (
    SELECT emp_id, SUM(hours) AS total_hours FROM emp_projects GROUP BY emp_id
)
SELECT e.first_name, t.total_hours
FROM employees e
JOIN totals t ON e.emp_id = t.emp_id
WHERE t.total_hours = (SELECT MAX(total_hours) FROM totals);
```
- CASE in ORDER BY adds negligible cost — evaluated in the same pass as the sort
- Index on `salary` speeds up range filters (`salary > 80000`, `BETWEEN`) significantly
