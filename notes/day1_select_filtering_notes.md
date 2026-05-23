# Day 1 — SELECT & Filtering

## Concepts Covered
`SELECT` `WHERE` `AND` `OR` `NOT` `BETWEEN` `IN` `LIKE` `IS NULL` `IS NOT NULL`

---

## Syntax Reference

```sql
-- Basic SELECT
SELECT col1, col2 FROM table;
SELECT * FROM table;                        -- all columns

-- Filtering
SELECT * FROM table WHERE condition;

-- Multiple conditions
WHERE col = 1 AND col2 = 'x'
WHERE col = 1 OR col = 2
WHERE NOT col = 1

-- Range
WHERE salary BETWEEN 60000 AND 90000       -- inclusive on both ends

-- List
WHERE dept_id IN (1, 2, 3)
WHERE dept_id NOT IN (1, 2)

-- Pattern matching
WHERE last_name LIKE 'S%'                  -- starts with S
WHERE last_name LIKE '%son'                -- ends with son
WHERE last_name LIKE '%mi%'                -- contains mi
WHERE last_name LIKE '_m%'                 -- second character is m

-- NULL checks
WHERE dept_id IS NULL
WHERE dept_id IS NOT NULL
```

---

## NULL — The Most Important Rule

**NULL is the absence of a value — not zero, not empty string.**

| Check | Correct | Wrong |
|-------|---------|-------|
| Is NULL | `IS NULL` | `= NULL` |
| Is not NULL | `IS NOT NULL` | `!= NULL` |
| Value comparison | `= 1` `!= 1` `<>` | `IS 1` `IS NOT 1` |

### NULL with inequality — silent trap
```sql
-- This drops NULL rows silently:
WHERE dept_id != 1

-- NULL != 1 evaluates to NULL (not TRUE) → row is excluded
-- Fix — include NULL rows explicitly:
WHERE dept_id != 1 OR dept_id IS NULL
```

---

## Examples

```sql
-- All employees in Engineering or Marketing
SELECT * FROM employees WHERE dept_id IN (1, 2);

-- Employees earning 60k–90k
SELECT * FROM employees WHERE salary BETWEEN 60000 AND 90000;

-- Employees with no manager
SELECT * FROM employees WHERE manager_id IS NULL;

-- Employees NOT in Engineering, including those with no dept
SELECT * FROM employees WHERE dept_id != 1 OR dept_id IS NULL;
```

---

## LIKE Wildcards

| Pattern | Matches |
|---------|---------|
| `'S%'` | Starts with S |
| `'%s'` | Ends with s |
| `'%mi%'` | Contains mi anywhere |
| `'_m%'` | Any char, then m, then anything |

> Note: LIKE is case-insensitive in SQLite but **case-sensitive** in PostgreSQL. Use `ILIKE` in PostgreSQL for case-insensitive matching.

---

## My Shortcomings

| Exercise | Mistake | Correct Approach |
|----------|---------|-----------------|
| Ex 7 | `WHERE dept_id IS NOT '1'` | `IS NOT` is for NULLs only. Use `!= 1` (no quotes on numbers) |
| Ex 7 | Used string `'1'` for an INT column | Never quote numeric values |
| Ex 7 | `dept_id != 1` drops Hank (NULL dept) | Add `OR dept_id IS NULL` to keep unassigned employees |

---

## Key Takeaways

```
IS / IS NOT    → only for NULL checks
= / != / <>    → for value comparisons
Never quote numeric values: salary > 85000 not salary > '85000'
NULL != anything = NULL (not TRUE) → always handle NULLs explicitly
```
