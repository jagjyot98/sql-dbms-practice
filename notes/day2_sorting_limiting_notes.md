# Day 2 — Sorting & Limiting

## Concepts Covered
`ORDER BY` `ASC` `DESC` `LIMIT` `OFFSET` `DISTINCT`

---

## Syntax Reference

```sql
-- Sorting
SELECT * FROM employees ORDER BY salary;            -- ASC by default
SELECT * FROM employees ORDER BY salary DESC;       -- highest first
SELECT * FROM employees ORDER BY dept_id, salary;  -- multi-column sort

-- Limiting rows
SELECT * FROM employees LIMIT 5;                   -- first 5 rows
SELECT * FROM employees LIMIT 5 OFFSET 2;          -- skip 2, take next 5

-- Remove duplicates
SELECT DISTINCT location FROM departments;
SELECT DISTINCT dept_id, location FROM departments; -- distinct combination
```

---

## LIMIT + OFFSET Mental Model

```
OFFSET = how many rows to SKIP from the top
LIMIT  = how many rows to RETURN after skipping
```

| Goal | LIMIT | OFFSET |
|------|-------|--------|
| Top 3 rows | 3 | 0 (default) |
| 2nd row only | 1 | 1 |
| Rows 2 and 3 | 2 | 1 |
| Rows 5 to 10 | 6 | 4 |
| Page 2 of 10-per-page | 10 | 10 |

**Formula:**
```
LIMIT  = how many rows you want
OFFSET = (page_number - 1) * rows_per_page
```

---

## Examples

```sql
-- Top 3 highest-paid employees
SELECT first_name, salary FROM employees ORDER BY salary DESC LIMIT 3;

-- 2nd and 3rd highest-paid
SELECT first_name, salary FROM employees ORDER BY salary DESC LIMIT 2 OFFSET 1;

-- Most recently hired 5 employees
SELECT first_name, hire_date FROM employees ORDER BY hire_date DESC LIMIT 5;

-- Unique department locations
SELECT DISTINCT location FROM departments;
```

---

## Multi-column ORDER BY

```sql
-- Sort by dept first, then by salary within each dept
SELECT first_name, dept_id, salary
FROM employees
ORDER BY dept_id ASC, salary DESC;
```

---

## My Shortcomings

| Exercise | Mistake | Correct Approach |
|----------|---------|-----------------|
| Ex 1 | `ORDER BY salary` (no DESC) | Add `DESC` when sorting highest to lowest |
| Ex 4 | `LIMIT 3 OFFSET 1` for rows 2 and 3 | `LIMIT 2 OFFSET 1` — OFFSET was right, LIMIT should be 2 not 3 |

---

## Key Takeaways

```
Default sort is ASC — always be explicit with DESC when needed.
OFFSET skips rows. LIMIT controls how many to return after skipping.
DISTINCT removes duplicate rows (based on all selected columns).
```
