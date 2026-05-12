# SQL & DBMS Practice Curriculum
> Scratch → Advanced | Daily Practice Plan

---

## Setup (Do This First)

Install a local DB to practice on:
- **SQLite** (zero config, great for beginners) — https://sqliteonline.com (browser-based, no install)
- **PostgreSQL** (recommended for real-world skills) — use pgAdmin or DBeaver
- **MySQL** — alternative, widely used in web dev

Use the sample schema below for all exercises.

---

## Practice Schema (Use Throughout)

```sql
-- Run this once to set up your practice database

CREATE TABLE departments (
    dept_id   INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location  VARCHAR(50)
);

CREATE TABLE employees (
    emp_id     INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name  VARCHAR(50),
    dept_id    INT REFERENCES departments(dept_id),
    salary     DECIMAL(10,2),
    hire_date  DATE,
    manager_id INT REFERENCES employees(emp_id)
);

CREATE TABLE projects (
    project_id   INT PRIMARY KEY,
    project_name VARCHAR(100),
    budget       DECIMAL(12,2),
    start_date   DATE,
    end_date     DATE
);

CREATE TABLE emp_projects (
    emp_id     INT REFERENCES employees(emp_id),
    project_id INT REFERENCES projects(project_id),
    role       VARCHAR(50),
    hours      INT,
    PRIMARY KEY (emp_id, project_id)
);

-- Sample Data
INSERT INTO departments VALUES
(1,'Engineering','New York'),
(2,'Marketing','Chicago'),
(3,'HR','Austin'),
(4,'Finance','New York');

INSERT INTO employees VALUES
(1,'Alice','Smith',1,95000,'2019-03-15',NULL),
(2,'Bob','Jones',1,82000,'2020-07-01',1),
(3,'Carol','White',2,71000,'2018-11-20',NULL),
(4,'Dan','Brown',1,67000,'2021-02-10',1),
(5,'Eve','Davis',3,58000,'2022-05-05',NULL),
(6,'Frank','Miller',2,75000,'2019-09-30',3),
(7,'Grace','Wilson',4,88000,'2017-01-12',NULL),
(8,'Hank','Moore',NULL,45000,'2023-08-01',NULL);

INSERT INTO projects VALUES
(101,'Alpha Launch',500000,'2024-01-01','2024-06-30'),
(102,'Beta Platform',1200000,'2024-03-01','2025-01-01'),
(103,'Data Migration',300000,'2024-02-15','2024-05-30');

INSERT INTO emp_projects VALUES
(1,101,'Lead',200),(2,101,'Dev',150),(4,101,'Dev',120),
(1,102,'Architect',100),(2,102,'Dev',300),(3,102,'PM',80),
(7,103,'Lead',180),(4,103,'Dev',90);
```

---

## PHASE 1 — Foundations (Week 1–2)

### Day 1 — SELECT & Filtering
**Concepts:** SELECT, WHERE, AND/OR/NOT, BETWEEN, IN, LIKE, IS NULL

```sql
-- Exercise 1: List all employees with their full name and salary
-- Exercise 2: Find employees hired after 2020-01-01
-- Exercise 3: Find employees in dept 1 OR dept 2
-- Exercise 4: Find employees with salary between 60000 and 90000
-- Exercise 5: Find employees whose last name starts with 'S'
-- Exercise 6: Find employees with no department assigned
-- Exercise 7: Find employees NOT in Engineering (dept_id=1)
```

### Day 2 — Sorting & Limiting
**Concepts:** ORDER BY, LIMIT/TOP, DISTINCT, OFFSET

```sql
-- Exercise 1: List all employees sorted by salary descending
-- Exercise 2: Top 3 highest-paid employees
-- Exercise 3: List unique locations from departments
-- Exercise 4: 2nd and 3rd highest-paid employees (use OFFSET)
-- Exercise 5: Employees hired most recently, show top 5
```

### Day 3 — Aggregate Functions
**Concepts:** COUNT, SUM, AVG, MIN, MAX, GROUP BY, HAVING

```sql
-- Exercise 1: Total number of employees
-- Exercise 2: Average salary per department
-- Exercise 3: Highest and lowest salary in the company
-- Exercise 4: Number of employees per department
-- Exercise 5: Departments with more than 2 employees
-- Exercise 6: Total hours logged per project
-- Exercise 7: Projects with total hours > 200
```

### Day 4 — JOINs (Part 1)
**Concepts:** INNER JOIN, LEFT JOIN, RIGHT JOIN, FULL OUTER JOIN

```sql
-- Exercise 1: List each employee with their department name
-- Exercise 2: List ALL employees, show dept name if exists (LEFT JOIN)
-- Exercise 3: Which departments have NO employees?
-- Exercise 4: List employees with their project names
-- Exercise 5: Find employees not assigned to any project
```

### Day 5 — JOINs (Part 2)
**Concepts:** Multi-table joins, self-join, cross join

```sql
-- Exercise 1: For each employee, show their manager's name
-- Exercise 2: List employee name, dept name, and all projects they work on
-- Exercise 3: Employees who share the same department (self join)
-- Exercise 4: Find all pairs of employees in the same project
-- Exercise 5: Full employee report: name, dept, project, role, hours
```

### Day 6 — Subqueries
**Concepts:** Scalar subquery, IN/NOT IN subquery, correlated subquery, EXISTS

```sql
-- Exercise 1: Find employees earning more than the average salary
-- Exercise 2: Find employees in the same dept as 'Alice'
-- Exercise 3: Find departments that have at least one project employee
-- Exercise 4: Find employees NOT working on any project (NOT IN)
-- Exercise 5: For each employee, show how their salary compares to dept avg
-- Exercise 6: Find employees working on the most expensive project
```

### Day 7 — Review Day
Re-do exercises from days 1–6 without looking at hints. Time yourself.

---

## PHASE 2 — Intermediate (Week 3–4)

### Day 8 — String & Date Functions
**Concepts:** UPPER, LOWER, CONCAT, LENGTH, SUBSTRING, TRIM, DATE functions

```sql
-- Exercise 1: Full name in format "SMITH, Alice" (upper last, title first)
-- Exercise 2: How many years has each employee worked? (current_date - hire_date)
-- Exercise 3: Employees hired in the month of January (any year)
-- Exercise 4: Extract year of hire for each employee
-- Exercise 5: Find employees whose full name length > 10 characters
-- Exercise 6: Which projects are currently active (today is between start/end)?
```

### Day 9 — CASE Expressions
**Concepts:** CASE WHEN, CASE with aggregates, derived categories

```sql
-- Exercise 1: Classify salary as Low(<65k), Mid(65k-85k), High(>85k)
-- Exercise 2: Label tenure: <2yr=Junior, 2-5yr=Mid, >5yr=Senior
-- Exercise 3: Count employees per salary band (combine CASE + GROUP BY)
-- Exercise 4: Assign project status: Completed/Active/Upcoming based on dates
-- Exercise 5: Show each dept and whether it's in New York or Remote
```

### Day 10 — Window Functions (Part 1)
**Concepts:** ROW_NUMBER, RANK, DENSE_RANK, NTILE, OVER(), PARTITION BY

```sql
-- Exercise 1: Rank employees by salary within each department
-- Exercise 2: Row number of each employee ordered by hire date
-- Exercise 3: Find the top earner per department (use ROW_NUMBER trick)
-- Exercise 4: Divide employees into 4 salary quartiles (NTILE)
-- Exercise 5: Dense rank of projects by budget
```

### Day 11 — Window Functions (Part 2)
**Concepts:** LAG, LEAD, SUM OVER, AVG OVER, running totals

```sql
-- Exercise 1: Running total of salaries ordered by hire_date
-- Exercise 2: Moving average salary (compare each emp to 2 before/after)
-- Exercise 3: Each employee's salary vs the previous hired employee (LAG)
-- Exercise 4: Cumulative hours per project
-- Exercise 5: Salary difference between each employee and the next higher earner in same dept
```

### Day 12 — CTEs & Views
**Concepts:** WITH (CTE), recursive CTE, CREATE VIEW

```sql
-- Exercise 1: CTE to find avg salary per dept, then find employees above it
-- Exercise 2: CTE: list project leaders with their project names
-- Exercise 3: Recursive CTE: build an org chart (employee → manager chain)
-- Exercise 4: Create a VIEW for "active employees" (those in a dept)
-- Exercise 5: Create a VIEW showing full employee summary with dept, projects, hours
```

### Day 13 — DDL & Constraints
**Concepts:** CREATE, ALTER, DROP, PRIMARY KEY, FOREIGN KEY, UNIQUE, CHECK, DEFAULT, NOT NULL

```sql
-- Exercise 1: Add a column `email` (UNIQUE, NOT NULL) to employees
-- Exercise 2: Add CHECK constraint: salary must be > 0
-- Exercise 3: Add a DEFAULT value of 'Entry Level' for a new `job_level` column
-- Exercise 4: Create a new table `skills` with a many-to-many relationship to employees
-- Exercise 5: Drop the skills table; add salary_history table tracking salary changes over time
```

### Day 14 — DML & Transactions
**Concepts:** INSERT, UPDATE, DELETE, TRUNCATE, BEGIN/COMMIT/ROLLBACK

```sql
-- Exercise 1: Insert 2 new employees into Engineering
-- Exercise 2: Give all Engineering employees a 10% raise
-- Exercise 3: Delete employees with no department (handle FK constraints)
-- Exercise 4: Use a transaction to transfer an employee between departments safely
-- Exercise 5: Update project end_date for any project that's over budget
```

---

## PHASE 3 — Advanced (Week 5–7)

### Day 15 — Indexes & Query Performance
**Concepts:** CREATE INDEX, EXPLAIN/EXPLAIN ANALYZE, covering index, composite index

```sql
-- Exercise 1: Create an index on employees.dept_id — explain why it helps JOINs
-- Exercise 2: Create a composite index on (dept_id, salary) — when is it used?
-- Exercise 3: Run EXPLAIN on a query with and without an index — compare plans
-- Exercise 4: Identify which queries in your practice would benefit from indexes
-- Exercise 5: Understand index trade-offs: when do indexes HURT performance?
```

### Day 16 — Query Optimization
**Concepts:** Execution plans, avoiding SELECT *, sargable predicates, EXISTS vs IN vs JOIN

```sql
-- Bad query: rewrite using EXISTS instead of NOT IN (handles NULLs correctly)
SELECT * FROM employees WHERE emp_id NOT IN (SELECT emp_id FROM emp_projects);

-- Exercise 1: Rewrite above using NOT EXISTS and LEFT JOIN — compare plans
-- Exercise 2: Identify and fix a non-sargable WHERE clause (e.g., WHERE YEAR(hire_date) = 2020)
-- Exercise 3: Replace SELECT * with explicit columns in a view
-- Exercise 4: Rewrite a correlated subquery as a JOIN for better performance
-- Exercise 5: Use EXPLAIN ANALYZE to identify the most expensive node in a query
```

### Day 17 — Normalization & Schema Design
**Concepts:** 1NF, 2NF, 3NF, BCNF, denormalization trade-offs

```
Theory + Design Exercises:

Exercise 1: Given this unnormalized table — normalize to 3NF:
  OrderData(order_id, customer_name, customer_email, product_name, product_price, qty)

Exercise 2: Design a schema for a library system:
  - Books, Authors, Members, Loans, Fines
  - Apply 3NF. Identify all primary and foreign keys.

Exercise 3: When would you intentionally DENORMALIZE? Give 3 real scenarios.

Exercise 4: What anomalies exist in a table that is in 1NF but not 2NF?

Exercise 5: Convert the employees/departments schema into BCNF — is it already there?
```

### Day 18 — Stored Procedures & Functions
**Concepts:** CREATE PROCEDURE, CREATE FUNCTION, parameters, IN/OUT, control flow

```sql
-- Exercise 1: Write a function get_dept_avg_salary(dept_id) → returns avg salary
-- Exercise 2: Write a procedure give_raise(dept_id, pct) that updates salaries
-- Exercise 3: Write a function that returns employee count for a given dept name
-- Exercise 4: Procedure: hire_employee(...) that inserts and returns the new emp_id
-- Exercise 5: Function to return tenure in years for a given emp_id
```

### Day 19 — Triggers
**Concepts:** BEFORE/AFTER INSERT/UPDATE/DELETE triggers, audit logs

```sql
-- Exercise 1: Trigger to prevent salary decrease (BEFORE UPDATE on employees)
-- Exercise 2: Create salary_audit table; trigger to log every salary change
-- Exercise 3: Trigger to auto-set hire_date to today if not provided
-- Exercise 4: Trigger to enforce: if dept deleted, reassign employees to dept_id=NULL
-- Exercise 5: Trigger to update a dept_headcount column whenever employees change
```

### Day 20 — Transactions & Isolation Levels
**Concepts:** ACID, READ UNCOMMITTED/COMMITTED, REPEATABLE READ, SERIALIZABLE, deadlocks

```
Theory + Scenario Exercises:

Exercise 1: Explain dirty read, non-repeatable read, phantom read with examples.

Exercise 2: Simulate a bank transfer — write it correctly with transactions:
  - Debit account A, credit account B
  - What happens if debit succeeds but credit fails?

Exercise 3: What isolation level would you use for:
  a) A report dashboard (reads only, performance matters)
  b) A banking debit/credit operation
  c) Inventory reservation in an e-commerce checkout

Exercise 4: What causes a deadlock? Write pseudocode showing two transactions deadlocking.

Exercise 5: How does MVCC (Multi-Version Concurrency Control) help PostgreSQL avoid locks?
```

### Day 21 — Advanced Window Functions & Analytics
```sql
-- Exercise 1: Median salary per department (no built-in MEDIAN — simulate it)
-- Exercise 2: Month-over-month growth in hire count (assume more hire_date data)
-- Exercise 3: Percentile rank of each employee's salary company-wide
-- Exercise 4: Gap and island problem: find consecutive project date ranges
-- Exercise 5: Running distinct count of departments as we scan employees by hire_date
```

---

## PHASE 4 — Expert Level (Week 8+)

### Day 22 — JSON in SQL (PostgreSQL focus)
```sql
-- Exercise 1: Store and query JSON metadata column on employees
-- Exercise 2: Extract nested JSON fields, filter on JSON values
-- Exercise 3: Aggregate rows into a JSON array
-- Exercise 4: Update a specific key inside a JSONB column
```

### Day 23 — Full-Text Search
```sql
-- Exercise 1: Create a tsvector index on project_name
-- Exercise 2: Full text search for projects matching a keyword
-- Exercise 3: Rank search results by relevance
```

### Day 24 — Partitioning
```sql
-- Exercise 1: Partition employees table by hire year (RANGE partitioning)
-- Exercise 2: Query a specific partition directly
-- Exercise 3: Explain why partitioning improves query performance on large tables
```

### Day 25 — Real-World Scenario
**Build a complete query suite for an e-commerce system:**
```
Schema: customers, orders, order_items, products, categories, reviews

Tasks:
1. Monthly revenue report with MoM growth
2. Top 10 customers by lifetime value
3. Products with declining sales (last 3 months vs prior 3 months)
4. Cohort analysis: retention by signup month
5. Inventory alert: products below reorder threshold
6. Write the full DDL for the schema
```

---

## Daily Practice Routine (15–30 min)

| Time | Activity |
|------|----------|
| 5 min | Review yesterday's solution — any better way? |
| 15 min | Solve today's exercises |
| 5 min | Read one concept (execution plan, isolation levels, etc.) |
| 5 min | Try to break your query or find an edge case |

---

## Key DBMS Concepts to Study (Alongside SQL)

- [ ] Storage engines (InnoDB vs MyISAM vs PostgreSQL heap)
- [ ] B-tree vs Hash indexes
- [ ] Buffer pool / page cache
- [ ] WAL (Write-Ahead Logging)
- [ ] MVCC (Multi-Version Concurrency Control)
- [ ] Query planner / cost-based optimizer
- [ ] Connection pooling
- [ ] Replication (primary/replica)
- [ ] Sharding vs partitioning

---

## Resources

- **Practice online:** https://sqliteonline.com | https://pgexercises.com
- **Reference:** https://postgresql.org/docs (best SQL reference)
- **Book:** "Learning SQL" by Alan Beaulieu (beginner → intermediate)
- **Book:** "SQL Performance Explained" by Markus Winand (intermediate → advanced)
