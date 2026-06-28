# Day 9 — Window Functions Part 1

## Concepts Covered
`ROW_NUMBER` · `RANK` · `DENSE_RANK` · `NTILE` · `OVER()` · `PARTITION BY`

---

## Score: 4.5 / 5

| Ex | Status | Note |
|----|--------|------|
| 1 | ✅ | — |
| 2 | ✅ | — |
| 3 | ✅ | Add DESC for conventional salary ranking |
| 4 | ✅ | Perfect top-N per group |
| 5 | ⚠️ | Incomplete CASE — missing quartiles 2, 3, 4 |

---

## Pre-Exercise Deep Dive Notes

> Complete concept guide provided before attempting exercises.

---

### 1. Why Window Functions Exist

Before window functions, per-row comparisons required ugly self-joins or correlated subqueries:

```sql
-- Old way: correlated subquery to get dept avg (slow — runs once per row)
SELECT first_name, salary,
       (SELECT AVG(salary) FROM employees e2 WHERE e2.dept_id = e.dept_id) AS dept_avg
FROM employees e;

-- Window way: clean, single scan
SELECT first_name, salary,
       AVG(salary) OVER (PARTITION BY dept_id) AS dept_avg
FROM employees;
```
Both return the same result — window function is faster and more readable.

---

### 2. OVER() — The Heart of Window Functions

```sql
-- OVER() with nothing = entire table is one window
RANK() OVER ()

-- OVER(ORDER BY) = rank across the whole table in order
RANK() OVER (ORDER BY salary DESC)

-- OVER(PARTITION BY) = separate window per group, keeps all rows
AVG(salary) OVER (PARTITION BY dept_id)

-- OVER(PARTITION BY + ORDER BY) = rank within each group
RANK() OVER (PARTITION BY dept_id ORDER BY salary DESC)
```

---

### 3. ROW_NUMBER() — Full Explanation

Assigns a **unique sequential integer** to every row. No ties — if two rows are equal, one gets a higher number arbitrarily.

```sql
SELECT first_name, salary,
       ROW_NUMBER() OVER (ORDER BY salary DESC) AS rn
FROM employees;
```

| first_name | salary | rn |
|------------|--------|----|
| Alice | 95000 | 1 |
| Grace | 88000 | 2 |
| Bob | 82000 | 3 |
| Frank | 75000 | 4 |
| Carol | 71000 | 5 |
| Dan | 67000 | 6 |
| Eve | 58000 | 7 |
| Hank | 45000 | 8 |

**Top-N per group trick — most important pattern:**
```sql
SELECT * FROM (
    SELECT first_name, dept_id, salary,
           ROW_NUMBER() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS rn
    FROM employees
) WHERE rn = 1;
-- Returns the highest earner from each department
```
Why ROW_NUMBER and not RANK? RANK can return multiple `rn=1` rows on ties. ROW_NUMBER always gives exactly one row per group.

---

### 4. RANK() vs DENSE_RANK() — Full Explanation

The difference shows up when there are **ties**. If Alice and Bob both had 95000:

| first_name | salary | RANK | DENSE_RANK |
|------------|--------|------|------------|
| Alice | 95000 | 1 | 1 |
| Bob | 95000 | 1 | 1 |
| Grace | 88000 | **3** | **2** |
| Frank | 75000 | 4 | 3 |

- `RANK` skips 2 (two people share rank 1 → next is 3)
- `DENSE_RANK` never skips (consecutive numbers always)

| Function | Use case |
|----------|----------|
| `RANK` | Leaderboards where position gap matters ("tied for 1st, next is 3rd") |
| `DENSE_RANK` | Grouping into tiers where you want clean tier numbers |

---

### 5. NTILE(n) — Full Explanation

Divides rows into n equal-sized buckets numbered 1 to n. Used for quartiles, deciles, percentile bands.

```sql
SELECT first_name, salary,
       NTILE(4) OVER (ORDER BY salary DESC) AS quartile
FROM employees;
```

| first_name | salary | quartile |
|------------|--------|----------|
| Alice | 95000 | 1 |
| Grace | 88000 | 1 |
| Bob | 82000 | 2 |
| Frank | 75000 | 2 |
| Carol | 71000 | 3 |
| Dan | 67000 | 3 |
| Eve | 58000 | 4 |
| Hank | 45000 | 4 |

> `ORDER BY salary DESC` → quartile 1 = highest paid.
> `ORDER BY salary ASC` → quartile 1 = lowest paid.

**Combine NTILE with CASE for labels — compute once, label in outer query:**
```sql
SELECT first_name, salary, quartile,
    CASE quartile
        WHEN 1 THEN 'Top 25%'
        WHEN 2 THEN 'Upper Mid'
        WHEN 3 THEN 'Lower Mid'
        WHEN 4 THEN 'Bottom 25%'
    END AS salary_band
FROM (
    SELECT first_name, salary,
           NTILE(4) OVER (ORDER BY salary DESC) AS quartile
    FROM employees
);
```
NTILE runs once in the inner query → CASE reads the already-computed value. No duplication.

---

### 6. PARTITION BY with JOIN

When you need a column from another table (e.g., dept_name), JOIN first then apply the window:

```sql
SELECT e.first_name, d.dept_name, e.salary,
       DENSE_RANK() OVER (PARTITION BY e.dept_id ORDER BY e.salary DESC) AS dept_rank
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;
```

---

### 7. Window Functions vs GROUP BY — Key Difference

```sql
-- GROUP BY — collapses rows, individual employees are lost
SELECT dept_id, MAX(salary) FROM employees GROUP BY dept_id;
-- Output: 4 rows (one per dept)

-- Window — keeps all rows, adds the max alongside each
SELECT first_name, dept_id, salary,
       MAX(salary) OVER (PARTITION BY dept_id) AS dept_max
FROM employees;
-- Output: 8 rows (all employees, each with their dept's max)
```

---

### 8. Important Rule — Cannot Use Window Functions in WHERE

```sql
-- ❌ Wrong
SELECT * FROM employees WHERE RANK() OVER (ORDER BY salary DESC) = 1;

-- ✅ Correct — wrap in subquery first
SELECT * FROM (
    SELECT *, RANK() OVER (ORDER BY salary DESC) AS rnk FROM employees
) WHERE rnk = 1;
```

---

## Core Concept — Why Window Functions Exist

A regular aggregate collapses rows. A window function computes across rows but **keeps every row**.

```sql
-- GROUP BY — collapses 8 employees into 4 dept rows
SELECT dept_id, AVG(salary) FROM employees GROUP BY dept_id;

-- Window — keeps all 8 rows, adds dept avg alongside each
SELECT first_name, dept_id, salary,
       AVG(salary) OVER (PARTITION BY dept_id) AS dept_avg
FROM employees;
```

---

## Syntax Reference

```sql
function_name() OVER (
    PARTITION BY col    -- divide rows into groups (optional)
    ORDER BY col DESC   -- order within each group (required for ranking)
)
```

| Clause | Meaning |
|--------|---------|
| `OVER()` | Empty = entire table is one window |
| `PARTITION BY dept_id` | Separate window per department |
| `ORDER BY salary DESC` | Order rows within each window |

---

## Ranking Functions Compared

```sql
SELECT first_name, salary,
       ROW_NUMBER()  OVER (ORDER BY salary DESC) AS rn,
       RANK()        OVER (ORDER BY salary DESC) AS rnk,
       DENSE_RANK()  OVER (ORDER BY salary DESC) AS dense_rnk
FROM employees;
```

If Alice and Bob both earned 95000:

| first_name | salary | ROW_NUMBER | RANK | DENSE_RANK |
|------------|--------|-----------|------|------------|
| Alice | 95000 | 1 | 1 | 1 |
| Bob | 95000 | 2 | 1 | 1 |
| Grace | 88000 | 3 | **3** | **2** |
| Frank | 75000 | 4 | 4 | 3 |

- `ROW_NUMBER` — always unique, no ties
- `RANK` — ties share rank, **skips** next number (1,1,3,4)
- `DENSE_RANK` — ties share rank, **no skip** (1,1,2,3)

**When to use which:**

| Function | Use case |
|----------|----------|
| `ROW_NUMBER` | Top-N per group (need exactly one row) |
| `RANK` | Leaderboards where gap matters ("tied 1st, next is 3rd") |
| `DENSE_RANK` | Tier grouping where consecutive numbers are needed |

---

## NTILE(n) — Bucket Distribution

Divides rows into n equal buckets numbered 1 to n.

```sql
SELECT first_name, salary,
       NTILE(4) OVER (ORDER BY salary DESC) AS quartile
FROM employees;
```

| first_name | salary | quartile |
|------------|--------|----------|
| Alice | 95000 | 1 |
| Grace | 88000 | 1 |
| Bob | 82000 | 2 |
| Frank | 75000 | 2 |
| Carol | 71000 | 3 |
| Dan | 67000 | 3 |
| Eve | 58000 | 4 |
| Hank | 45000 | 4 |

> `ORDER BY salary DESC` → quartile 1 = highest paid.
> `ORDER BY salary ASC` → quartile 1 = lowest paid.

**NTILE + CASE — compute once, label in outer query:**
```sql
SELECT first_name, salary, quartile,
    CASE quartile
        WHEN 1 THEN 'Top 25%'
        WHEN 2 THEN 'Upper Mid'
        WHEN 3 THEN 'Lower Mid'
        WHEN 4 THEN 'Bottom 25%'
    END AS salary_band
FROM (
    SELECT first_name, salary,
           NTILE(4) OVER (ORDER BY salary DESC) AS quartile
    FROM employees
);
```
Compute NTILE once in the subquery → CASE reads the result. No duplication.

---

## Top-N Per Group Pattern

Most important window function pattern — find the best/worst row per group:

```sql
-- Step 1: assign ROW_NUMBER within each department
-- Step 2: wrap in subquery, filter where rn = 1
SELECT * FROM (
    SELECT first_name, dept_id, salary,
           ROW_NUMBER() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS rn
    FROM employees
) WHERE rn = 1;
```

**Why ROW_NUMBER, not RANK?**
- `RANK` can return multiple `rn = 1` rows on ties → more than one "top" per group
- `ROW_NUMBER` always returns exactly one row per group → safe for top-1 queries

**For top-3 per group:** just change `WHERE rn = 1` to `WHERE rn <= 3`.

---

## Critical Rule — Window Functions in WHERE

Window functions **cannot** be used directly in WHERE or HAVING.
Always wrap in a subquery first:

```sql
-- ❌ Wrong — cannot filter on window function directly
SELECT * FROM employees WHERE RANK() OVER (ORDER BY salary DESC) = 1;

-- ✅ Correct — compute in subquery, filter in outer query
SELECT * FROM (
    SELECT *, RANK() OVER (ORDER BY salary DESC) AS rnk FROM employees
) WHERE rnk = 1;
```

---

## Window vs GROUP BY — Side by Side

```sql
-- GROUP BY — 4 rows output (one per dept), individual employees lost
SELECT dept_id, MAX(salary) FROM employees GROUP BY dept_id;

-- Window — 8 rows output (all employees), each with their dept's max
SELECT first_name, dept_id, salary,
       MAX(salary) OVER (PARTITION BY dept_id) AS dept_max
FROM employees;
```

---

## My Shortcomings

| Exercise | Mistake | Correct Approach |
|----------|---------|-----------------|
| Ex 3 | `ORDER BY salary` (ASC) | Salary ranking convention is DESC — highest earner = rank 1 |
| Ex 5 | CASE only had `WHEN 1` — quartiles 2, 3, 4 returned NULL | All WHEN branches must be covered, or add ELSE |

---

## Optimization Tips

| Scenario | Tip |
|----------|-----|
| Window with `ORDER BY salary` | Index on `salary` eliminates internal sort step |
| `ROW_NUMBER` vs `RANK` | ROW_NUMBER is cheaper — no tie comparison needed |
| Top-N subquery | Single table scan + filter — much better than correlated subquery |
| `NTILE` on large tables | Pre-store quartile buckets in a computed column to avoid re-sorting |
| Multiple window functions | If they share same OVER() clause, DB can reuse the sort pass |
