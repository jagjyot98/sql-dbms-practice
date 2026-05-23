# Day 8 — CASE Expressions

## Concepts Covered
`CASE WHEN` · Cascading conditions · `CASE` with aggregates · `CASE` in ORDER BY

---

## Syntax Reference

```sql
-- Searched CASE (most common — evaluates conditions)
CASE
    WHEN condition1 THEN 'result1'
    WHEN condition2 THEN 'result2'
    ELSE 'default'        -- optional, returns NULL if omitted and no match
END

-- Simple CASE (compare one column to fixed values)
CASE dept_id
    WHEN 1 THEN 'Engineering'
    WHEN 2 THEN 'Marketing'
    ELSE 'Other'
END

-- CASE in SELECT
SELECT first_name,
       CASE WHEN salary >= 85000 THEN 'High' ELSE 'Low' END AS band
FROM employees;

-- CASE in ORDER BY (custom sort priority)
ORDER BY CASE WHEN dept_name = 'Engineering' THEN 0 ELSE 1 END;

-- CASE inside COUNT (pivot pattern)
COUNT(CASE WHEN salary >= 85000 THEN 1 END) AS high_count
```

---

## Cascading Conditions — First Match Wins

CASE evaluates top to bottom and stops at the first TRUE condition.
This means you **don't need upper bounds** in your conditions:

```sql
-- With AND ranges (fragile — boundary gaps, verbose):
CASE
    WHEN salary > 85000                          THEN 'High'
    WHEN salary > 65000 AND salary < 85000       THEN 'Mid'
    WHEN salary < 65000                          THEN 'Low'
END
-- Problem: salary = 85000 matches neither > 85000 nor < 85000 → NULL

-- With cascading (clean — no gaps):
CASE
    WHEN salary >= 85000 THEN 'High'   -- catches 85000+
    WHEN salary >= 65000 THEN 'Mid'    -- only reached if NOT High (so: 65000–84999)
    ELSE 'Low'                         -- everything else (below 65000)
END
```

**Order matters:** Put most specific / highest conditions first.

---

## COUNT(CASE...) — Pivot Pattern

```sql
-- Count rows matching different conditions in a single query
SELECT
    COUNT(CASE WHEN salary >= 85000 THEN 1 END) AS high_count,
    COUNT(CASE WHEN salary >= 65000 AND salary < 85000 THEN 1 END) AS mid_count,
    COUNT(CASE WHEN salary < 65000 THEN 1 END) AS low_count
FROM employees;
```

Why this works: `COUNT` ignores NULL values. When a CASE condition is false and there's no `ELSE`, it returns NULL → not counted.

---

## Examples

```sql
-- Salary classification with cascading
SELECT first_name, salary,
CASE
    WHEN salary >= 85000 THEN 'High'
    WHEN salary >= 65000 THEN 'Mid'
    ELSE 'Low'
END AS salary_band
FROM employees;

-- Tenure label
SELECT first_name,
CASE
    WHEN (JULIANDAY('now') - JULIANDAY(hire_date)) / 365 < 2 THEN 'Junior'
    WHEN (JULIANDAY('now') - JULIANDAY(hire_date)) / 365 < 5 THEN 'Mid'
    ELSE 'Senior'
END AS tenure_label
FROM employees;

-- Project status using direct date comparison
SELECT project_name,
CASE
    WHEN DATE('now') < start_date                    THEN 'Upcoming'
    WHEN DATE('now') BETWEEN start_date AND end_date THEN 'Active'
    ELSE 'Completed'
END AS status
FROM projects;

-- Manager vs Individual Contributor
SELECT first_name,
CASE
    WHEN emp_id IN (SELECT DISTINCT manager_id FROM employees WHERE manager_id IS NOT NULL)
    THEN 'Manager'
    ELSE 'Individual Contributor'
END AS role_type
FROM employees;

-- Bonus rate by department
SELECT first_name, salary,
CASE dept_id
    WHEN 1 THEN salary * 0.15   -- Engineering
    WHEN 4 THEN salary * 0.12   -- Finance
    ELSE       salary * 0.10    -- Everyone else
END AS bonus
FROM employees;
```

---

## My Shortcomings

| Exercise | Mistake | Correct Approach |
|----------|---------|-----------------|
| Ex 1, 3 | `salary > '85000'` — quoted numeric value | Never quote numbers: `salary > 85000` |
| Ex 1 | AND range `> 65000 AND < 85000` creates boundary gap | Use cascading: `>= 85000` then `>= 65000` then `ELSE` |
| Ex 2 | AND range for tenure created gap at exactly 2 and 5 years | Use cascading conditions, not AND ranges |
| Ex 5 | `WHEN location IS 'New York'` | `IS` is for NULL checks only — use `= 'New York'` |

---

## Optimization Tips

- `CASE` in `SELECT` is computed per row — no index can help here.
- If you query by classification frequently, store it as a real column with a `CHECK` constraint.
- Avoid repeating expensive expressions (e.g., JULIANDAY tenure calc) in every WHEN — wrap in a CTE:

```sql
WITH tenure AS (
    SELECT first_name,
           (JULIANDAY('now') - JULIANDAY(hire_date)) / 365 AS years
    FROM employees
)
SELECT first_name,
CASE
    WHEN years < 2 THEN 'Junior'
    WHEN years < 5 THEN 'Mid'
    ELSE 'Senior'
END AS label
FROM tenure;
```

---

## Key Takeaways

```
CASE evaluates top to bottom — first match wins, rest are skipped.
Use cascading conditions, not AND ranges — avoids boundary gaps.
Always add ELSE — without it, unmatched rows return NULL silently.
IS / IS NOT → NULL checks only. = / != → value comparisons.
Never quote numeric values: salary >= 85000, not salary >= '85000'.
COUNT(CASE WHEN ... THEN 1 END) counts only matching rows (NULLs skipped).
CASE works in SELECT, WHERE, ORDER BY, GROUP BY, HAVING.
```
