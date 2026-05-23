# Day 7 — String & Date Functions

## Concepts Covered
`UPPER` `LOWER` `||` `LENGTH` `SUBSTR` `TRIM` `REPLACE` `DATE` `STRFTIME` `JULIANDAY`

---

## String Functions

```sql
-- Case
UPPER(first_name)                          -- ALICE
LOWER(last_name)                           -- smith

-- Concatenation (SQLite uses ||, PostgreSQL supports both || and CONCAT())
first_name || ' ' || last_name             -- Alice Smith
UPPER(last_name) || ', ' || first_name     -- SMITH, Alice

-- Length
LENGTH('Alice Smith')                      -- 10
LENGTH(first_name || last_name)            -- combined length

-- Substring
SUBSTR('Alice Smith', 1, 5)               -- Alice  (start pos 1, take 5 chars)
SUBSTR('Alice Smith', 7)                   -- Smith  (start pos 7, take rest)

-- Trim whitespace
TRIM('  Alice ')                           -- Alice

-- Replace
REPLACE('New York', 'York', 'Jersey')      -- New Jersey
```

---

## Date Functions (SQLite)

```sql
-- Today's date
DATE('now')                                -- 2026-05-17

-- Extract parts of a date
STRFTIME('%Y', hire_date)                  -- year:  2019
STRFTIME('%m', hire_date)                  -- month: 03
STRFTIME('%d', hire_date)                  -- day:   15

-- Date arithmetic — convert to Julian Day Number first
JULIANDAY('now') - JULIANDAY(hire_date)    -- days between two dates
(JULIANDAY('now') - JULIANDAY(hire_date)) / 365  -- years (approximate)

-- Cast to integer for clean output
CAST((JULIANDAY('now') - JULIANDAY(hire_date)) / 365 AS INT)

-- Date range comparison
WHERE hire_date BETWEEN '2019-01-01' AND '2020-12-31'
WHERE DATE('now') BETWEEN start_date AND end_date
```

---

## Operator Precedence — JULIANDAY Gotcha

```sql
-- WRONG — division runs before subtraction (standard math precedence):
julianday('now') - julianday(hire_date) / 365
-- Computed as: julianday('now') - (julianday(hire_date) / 365)  ← wrong!

-- CORRECT — parentheses enforce intended order:
(JULIANDAY('now') - JULIANDAY(hire_date)) / 365
```

---

## Subquery vs Direct Function — Know the Difference

```sql
-- Direct function in WHERE (correct — operates on same row's column):
WHERE STRFTIME('%m', hire_date) = '03'              ✅
WHERE LENGTH(first_name || last_name) > 10          ✅

-- Subquery (correct — pulls a value from another row/table):
WHERE salary > (SELECT AVG(salary) FROM employees)  ✅

-- Unnecessary subquery wrapping a direct function (WRONG):
WHERE (SELECT STRFTIME('%m', hire_date) FROM employees) = '03'  ❌
-- Returns 8 rows — = cannot compare against a list
```

**Rule:** If the function runs on the **same row's column** → use it directly in WHERE. No subquery needed.

---

## Non-Sargable Functions (Optimization)

Applying functions to indexed columns in WHERE prevents index usage — the DB must scan every row.

| WHERE Clause | Index Used? |
|---|---|
| `STRFTIME('%m', hire_date) = '03'` | ❌ No |
| `LENGTH(first_name \|\| last_name) > 10` | ❌ No |
| `JULIANDAY(hire_date) > x` | ❌ No |
| `hire_date >= '2020-01-01'` | ✅ Yes |

**Sargable rewrite — compare dates directly:**
```sql
-- Non-sargable (no index):
WHERE STRFTIME('%Y', hire_date) = '2020'

-- Sargable (uses index on hire_date):
WHERE hire_date >= '2020-01-01' AND hire_date < '2021-01-01'
```

---

## Examples

```sql
-- Full name formatted as "SMITH, Alice"
SELECT UPPER(last_name) || ', ' || first_name AS formatted_name FROM employees;

-- Tenure in years (integer)
SELECT first_name,
       CAST((JULIANDAY('now') - JULIANDAY(hire_date)) / 365 AS INT) AS tenure_years
FROM employees;

-- Employees hired in March
SELECT * FROM employees WHERE STRFTIME('%m', hire_date) = '03';

-- Full name longer than 10 characters
SELECT * FROM employees WHERE LENGTH(first_name || last_name) > 10;

-- Currently active projects
SELECT * FROM projects WHERE DATE('now') BETWEEN start_date AND end_date;
```

---

## My Shortcomings

| Exercise | Mistake | Correct Approach |
|----------|---------|-----------------|
| Ex 2 | `julianday('now') - julianday(hire_date) / 365` | Operator precedence — wrap subtraction in parentheses first: `(JULIANDAY('now') - JULIANDAY(hire_date)) / 365` |
| Ex 3 | Wrapped `STRFTIME` in a subquery | STRFTIME runs on the same row's column — use directly in WHERE, no subquery |
| Ex 5 | Wrapped `LENGTH` in a subquery | Same as Ex 3 — direct function, no subquery needed |

---

## Key Takeaways

```
|| concatenates strings in SQLite/PostgreSQL. Use CONCAT() in MySQL.
STRFTIME('%Y/%m/%d', col) extracts year/month/day.
JULIANDAY converts dates to numbers for arithmetic.
Always wrap JULIANDAY subtraction in parentheses — operator precedence.
Direct column functions in WHERE → no subquery needed.
Functions on indexed columns in WHERE = full table scan (non-sargable).
```
