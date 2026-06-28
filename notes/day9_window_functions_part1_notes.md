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
