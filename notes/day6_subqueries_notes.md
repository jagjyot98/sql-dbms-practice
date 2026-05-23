# Day 6 — Subqueries

## Concepts Covered
Scalar subquery · IN / NOT IN · Correlated subquery · EXISTS / NOT EXISTS

---

## Subquery Type Reference

| Type | Returns | Used In | Runs |
|------|---------|---------|------|
| Scalar | 1 value | WHERE / SELECT | Once |
| IN / NOT IN | List of values | WHERE | Once |
| Correlated | 1 value | WHERE / SELECT | Once per outer row |
| EXISTS | TRUE / FALSE | WHERE | Once per outer row |

---

## Syntax Reference

```sql
-- Scalar: compare against a single computed value
SELECT * FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-- IN: compare against a list
SELECT * FROM employees
WHERE dept_id IN (SELECT dept_id FROM departments WHERE location = 'New York');

-- NOT IN: exclude a list
SELECT * FROM employees
WHERE emp_id NOT IN (SELECT emp_id FROM emp_projects);

-- Correlated: inner query references outer query's column
SELECT first_name,
       (SELECT AVG(salary) FROM employees e2 WHERE e2.dept_id = e.dept_id) AS dept_avg
FROM employees e;

-- EXISTS: check if any matching rows exist
SELECT * FROM departments d
WHERE EXISTS (SELECT 1 FROM employees e WHERE e.dept_id = d.dept_id);

-- NOT EXISTS: check if no matching rows exist (safer than NOT IN)
SELECT * FROM employees e
WHERE NOT EXISTS (SELECT 1 FROM emp_projects ep WHERE ep.emp_id = e.emp_id);
```

---

## How Correlated Subqueries Work

```sql
SELECT first_name,
       (SELECT AVG(salary) FROM employees e2 WHERE e2.dept_id = e.dept_id) AS dept_avg
FROM employees e;
--                                                          ↑
--                                           references outer query's row
```

For each row in the outer query, the inner query runs fresh — using that row's `dept_id`.
This is what "correlated" means: the inner query depends on the outer row.

---

## NOT IN vs NOT EXISTS — Critical Difference

```sql
-- NOT IN is UNSAFE if subquery can return NULL:
WHERE emp_id NOT IN (SELECT emp_id FROM emp_projects)
-- If emp_projects has even one NULL emp_id → entire result is 0 rows (silent bug)

-- NOT EXISTS is ALWAYS SAFE:
WHERE NOT EXISTS (SELECT 1 FROM emp_projects ep WHERE ep.emp_id = e.emp_id)
-- Evaluates per row, NULL-safe
```

**Rule:** Prefer `NOT EXISTS` over `NOT IN` in production code.

---

## Examples

```sql
-- Employees above company average salary
SELECT first_name, salary FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-- Employees in same dept as Alice
SELECT first_name FROM employees
WHERE dept_id = (SELECT dept_id FROM employees WHERE first_name = 'Alice');

-- Departments with at least one project employee (EXISTS)
SELECT dept_name FROM departments d
WHERE EXISTS (
    SELECT 1 FROM employees e
    JOIN emp_projects ep ON e.emp_id = ep.emp_id
    WHERE e.dept_id = d.dept_id
);

-- Employees not on any project (NOT EXISTS — safe)
SELECT first_name FROM employees e
WHERE NOT EXISTS (SELECT 1 FROM emp_projects ep WHERE ep.emp_id = e.emp_id);

-- Each employee's salary vs their dept average (correlated in SELECT)
SELECT first_name, salary,
       (SELECT AVG(salary) FROM employees e2 WHERE e2.dept_id = e.dept_id) AS dept_avg
FROM employees e;
```

---

## My Shortcomings

| Exercise | Mistake | Correct Approach |
|----------|---------|-----------------|
| Ex 5 | `(SELECT AVG(salary) FROM employees GROUP BY dept_id)` in SELECT | Returns multiple rows — scalar position needs exactly 1 value. Use correlated subquery with `WHERE e2.dept_id = e.dept_id` |

---

## Key Takeaways

```
Scalar subquery → must return exactly 1 row, 1 column.
GROUP BY inside a scalar subquery = multiple rows = error.
Correlated subquery: inner references outer row's column — runs once per row.
NOT IN fails silently when subquery contains NULL — use NOT EXISTS instead.
EXISTS is faster than IN on large datasets — stops at first match.
```
