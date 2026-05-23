# SQL & DBMS Practice

Daily SQL practice — scratch to advanced level.
Each exercise file contains: question → my attempt → ✅/❌ review → correct answer → optimization tips.

---

## Progress

| Day | Topic | Status |
|-----|-------|--------|
| Day 1 | SELECT & Filtering | ✅ |
| Day 2 | Sorting & Limiting | ✅ |
| Day 3 | Aggregate Functions | ✅ |
| Day 4 | JOINs Part 1 | ✅ |
| Day 5 | JOINs Part 2 (Self JOIN, Multi-table) | ✅ |
| Day 6 | Subqueries | ✅ |
| Day 7 | String & Date Functions | ✅ |
| Day 8 | CASE Expressions | ✅ |
| Day 9 | Window Functions Part 1 | ⏳ |
| Day 10 | Window Functions Part 1 | ⏳ |
| Day 11 | Window Functions Part 2 | ⏳ |
| Day 12 | CTEs & Views | ⏳ |
| Day 13 | DDL & Constraints | ⏳ |
| Day 14 | DML & Transactions | ⏳ |

---

## Structure

```
exercises/                    — Daily SQL exercise files
SQL_DBMS_Curriculum.md        — Full curriculum with schema setup
README.md                     — This file
```

---

## Setup

See `SQL_DBMS_Curriculum.md` for the full practice schema.
Quick start: paste the schema into https://sqliteonline.com

---

## Day-by-Day Concept Notes

---

### Day 1 — SELECT & Filtering

**Key lesson: `IS` / `IS NOT` vs `=` / `!=`**

| Situation | Correct Operator |
|-----------|-----------------|
| Compare a value | `=` `!=` `<>` |
| Check for NULL | `IS NULL` |
| Check for not NULL | `IS NOT NULL` |
| Exclude a value + keep NULLs | `!= x OR col IS NULL` |

**NULL gotcha:** `NULL != 1` evaluates to `NULL` (not TRUE).
So `WHERE dept_id != 1` silently drops rows where dept_id is NULL.
Fix: `WHERE dept_id != 1 OR dept_id IS NULL`

**Mistake made:** Used `IS NOT '1'` instead of `!= 1`.
- `IS NOT` is only valid for NULL checks
- `'1'` is a string — always match types (dept_id is INT)

---

### Day 2 — Sorting & Limiting

**Key lesson: LIMIT + OFFSET mental model**

```
OFFSET = how many rows to skip from the top
LIMIT  = how many rows to return after skipping
```

| Goal | LIMIT | OFFSET |
|------|-------|--------|
| Top 3 rows | 3 | 0 (default) |
| Rows 2 and 3 | 2 | 1 |
| Rows 5 to 10 | 6 | 4 |

**Mistake made:** Used `LIMIT 3 OFFSET 1` for "2nd and 3rd" rows.
- `OFFSET 1` was correct (skip 1 row)
- `LIMIT 3` was wrong — returns 3 rows, not 2. Should be `LIMIT 2`

**Note:** `ORDER BY` default is `ASC`. Always be explicit with `DESC` when needed.

---

### Day 3 — Aggregate Functions

**Key lesson: SQL logical execution order**

```
FROM       → which table(s)
JOIN       → combine tables
WHERE      → filter rows BEFORE grouping
GROUP BY   → group rows
HAVING     → filter AFTER grouping
SELECT     → pick columns
ORDER BY   → sort
LIMIT      → restrict output
```

**WHERE vs HAVING:**
- `WHERE salary > 50000` → filters individual rows (before GROUP BY)
- `HAVING COUNT(*) > 2` → filters groups (after GROUP BY, uses aggregates)

**Best practice:** Always alias aggregate columns:
```sql
COUNT(*) AS employee_count
AVG(salary) AS avg_salary
```

---

### Day 4 — JOINs Part 1

**JOIN type reference:**

| JOIN Type | Keeps unmatched LEFT | Keeps unmatched RIGHT |
|-----------|----------------------|-----------------------|
| INNER JOIN | ❌ | ❌ |
| LEFT JOIN | ✅ | ❌ |
| RIGHT JOIN | ❌ | ✅ |
| FULL OUTER JOIN | ✅ | ✅ |

**Rule:** The table after `FROM` is the "left" table. In a LEFT JOIN it never loses rows.

**Golden rule for finding unmatched rows:**
Always check `IS NULL` on the JOIN table (right side), NEVER on the base table.

```sql
-- Find employees with no project
FROM employees e
LEFT JOIN emp_projects ep ON e.emp_id = ep.emp_id
WHERE ep.emp_id IS NULL   ✅ (JOIN table — can be NULL when no match)
-- NOT: WHERE e.emp_id IS NULL  ❌ (PRIMARY KEY — never NULL)
```

**Mistake made:** Used `WHERE e.emp_id IS NULL` instead of `WHERE ep.emp_id IS NULL`.

**3-table JOIN pattern (junction table):**
```
employees → emp_projects → projects
```
`employees` and `projects` have no direct link — always go through the junction table.

---

### Day 5 — JOINs Part 2

**Key lesson: Self JOIN**

Use when a table references itself (e.g., `manager_id` → `emp_id` in the same table).
Alias the same table twice with different names:

```sql
FROM employees e          -- the employee
LEFT JOIN employees m     -- the manager
ON e.manager_id = m.emp_id
```

**Multi-table JOIN pattern:**
- Ask: *"Which table should never lose rows?"*
- That table goes after `FROM`
- Every other table gets `LEFT JOIN`'d onto it

**JOIN chain for many-to-many:**
```
employees → emp_projects → projects
  e.emp_id = ep.emp_id
               ep.project_id = p.project_id
```

---

### Day 8 — CASE Expressions

**Key lesson: Cascading conditions — first match wins**

```sql
-- Instead of AND ranges (fragile, boundary gaps):
WHEN salary > 65000 AND salary < 85000 THEN 'Mid'

-- Use cascading (clean, no gaps):
WHEN salary >= 85000 THEN 'High'
WHEN salary >= 65000 THEN 'Mid'   -- only reached if not already High
ELSE 'Low'
```

**`COUNT(CASE...)` pattern — pivot rows into columns:**
```sql
COUNT(CASE WHEN salary >= 85000 THEN 1 END) AS high_count
-- COUNT skips NULLs → when CASE is false with no ELSE, returns NULL → not counted
```

**Mistakes made:**
- Ex 1, 3: Quoted numeric values `'85000'` — never quote numbers, breaks in PostgreSQL/MySQL
- Ex 2: AND range conditions created boundary gap (exactly 2 or 5 years → NULL)
- Ex 5: Used `IS` for equality — `IS`/`IS NOT` is for NULL checks only, use `=`

**Optimization:**
- `CASE` in `SELECT` is computed per row — no index can help
- Avoid repeating long expressions (e.g., JULIANDAY tenure calc) in every WHEN — wrap in a CTE to compute once (covered Day 12)

---

### Day 7 — String & Date Functions

**Key lesson: Don't wrap direct functions in unnecessary subqueries**

```sql
-- If the function runs on the SAME row's column → use directly in WHERE:
WHERE STRFTIME('%m', hire_date) = '03'          ✅
WHERE LENGTH(first_name || last_name) > 10      ✅

-- Only subquery when pulling a value FROM ANOTHER ROW/TABLE:
WHERE salary > (SELECT AVG(salary) FROM employees)  ✅
```

**Operator precedence gotcha with JULIANDAY:**
```sql
-- Wrong (division runs before subtraction):
julianday('now') - julianday(hire_date) / 365

-- Correct (parentheses enforce order):
(JULIANDAY('now') - JULIANDAY(hire_date)) / 365
```

**Mistakes made:**
- Ex 2: Missing parentheses → wrong operator precedence
- Ex 3 & 5: Wrapped direct column functions in subqueries → subquery returns multiple rows, `=` fails

**Optimization — Non-sargable functions in WHERE:**

| Function in WHERE | Index used? | Production Fix |
|------------------|-------------|----------------|
| `STRFTIME('%m', hire_date)` | ❌ No | Store `hire_month INT` as separate column |
| `LENGTH(first_name \|\| last_name) > 10` | ❌ No | Use a computed/generated column |
| `JULIANDAY(hire_date)` | ❌ No | Compare dates directly |

Sargable alternative:
```sql
-- Instead of (non-sargable):
WHERE STRFTIME('%Y', hire_date) = '2020'

-- Use (sargable — can use index on hire_date):
WHERE hire_date >= '2020-01-01' AND hire_date < '2021-01-01'
```

---

### Day 6 — Subqueries

**Subquery type reference:**

| Type | Returns | Used In | Runs |
|------|---------|---------|------|
| Scalar | 1 value | WHERE / SELECT | Once |
| IN / NOT IN | List of values | WHERE | Once |
| Correlated | 1 value | WHERE / SELECT | Per outer row |
| EXISTS | TRUE / FALSE | WHERE | Per outer row |

**Correlated subquery — how it works:**
```sql
SELECT first_name,
       (SELECT AVG(salary) FROM employees e2 WHERE e2.dept_id = e.dept_id) AS dept_avg
FROM employees e;
```
For each row in the outer query, the inner query runs fresh using that row's `dept_id`.
The key: inner query references `e.dept_id` from the outer query.

**Mistake made:** Used `GROUP BY` inside a scalar subquery in SELECT:
```sql
-- ❌ Wrong — returns multiple rows, not a single value
(SELECT AVG(salary) FROM employees GROUP BY dept_id)

-- ✅ Correct — correlated, returns 1 value per outer row
(SELECT AVG(salary) FROM employees e2 WHERE e2.dept_id = e.dept_id)
```

**NOT IN vs NOT EXISTS:**
- `NOT IN` is unsafe if subquery can return NULL → entire result becomes NULL → 0 rows
- `NOT EXISTS` is always safe — preferred in production code

```sql
-- Safer alternative to NOT IN:
WHERE NOT EXISTS (SELECT 1 FROM emp_projects ep WHERE ep.emp_id = e.emp_id)
```

---

## Resources

- **Practice online:** https://sqliteonline.com | https://pgexercises.com
- **Reference:** https://postgresql.org/docs
- **Book:** "Learning SQL" by Alan Beaulieu (beginner → intermediate)
- **Book:** "SQL Performance Explained" by Markus Winand (intermediate → advanced)
