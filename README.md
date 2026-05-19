# 🎥 Sakila SQL Mastery: Querying a Real-World DVD Rental Database

> *From film catalogues to overdue rentals — 13 business-driven SQL queries across a fully normalized relational database.*

---

## 📌 Project Overview

This project demonstrates structured query language (SQL) applied to the **Sakila Sample Database** — a richly normalized, real-world schema designed by MySQL to simulate a DVD rental store operation. Working across both **phpMyAdmin** and **MySQL Workbench**, the queries progress from basic retrieval through aggregation, multi-table joins, date arithmetic, and string manipulation.

Every query answers a genuine operational or business intelligence question: revenue by store, overdue rental tracking, loyalty customer identification, inventory dead stock analysis, and more.

---

## 🗄️ The Database

**Sakila** is MySQL's official sample database. It models a DVD rental business with 16 interconnected tables covering films, actors, customers, staff, stores, inventory, rentals, and payments.

### ⬇️ Download Sakila

| Source | Link |
|---|---|
| **Official MySQL Dev Site** | [https://dev.mysql.com/doc/index-other.html](https://dev.mysql.com/doc/index-other.html) |
| **Direct ZIP Download** | [https://downloads.mysql.com/docs/sakila-db.zip](https://downloads.mysql.com/docs/sakila-db.zip) |

**Setup instructions:**
```sql
-- After extracting the ZIP:
SOURCE /path/to/sakila-schema.sql;
SOURCE /path/to/sakila-data.sql;
USE sakila;
```

---

## 🗺️ Entity Relationship Diagram (ERD)

<img width="1200" height="900" alt="Sakila_ERD" src="https://github.com/user-attachments/assets/2ca0feab-17e9-4ce6-a20e-ab7c157cfb96" />



The Sakila schema contains **16 tables** with clearly defined primary keys, foreign key relationships, and junction tables for many-to-many associations (e.g. `film_actor`, `film_category`). The ERD above was generated using **MySQL Workbench's** reverse-engineering tool directly from the live database.

### Key Relationships at a Glance

| Relationship | Tables Involved |
|---|---|
| Film → Inventory → Rental → Payment | Core transaction chain |
| Film ↔ Actor | Many-to-many via `film_actor` |
| Film ↔ Category | Many-to-many via `film_category` |
| Store → Staff → Rental | Operational hierarchy |
| Customer → Rental → Payment | Revenue attribution |

---


> **Note on the database zip:** The `database/` folder contains a local copy for convenience. The canonical and always-up-to-date source is the [official MySQL download](https://downloads.mysql.com/docs/sakila-db.zip).

---

## 🔧 Tools Used

| Tool | Purpose |
|---|---|
| **MySQL Workbench** | Query execution, ERD generation (reverse engineering) |
| **phpMyAdmin** | Web-based query execution and result inspection |
| **MySQL 8.x** | Database engine |

---

## 📋 Query Index

### 🔵 Section 1 — Basic Retrieval & Filtering

| # | Title | Business Question |
|---|---|---|
| Q1 | Film Catalogue Snapshot | List every film with rating, rental duration, and replacement cost |
| Q2 | Expensive Long Films | Which films run over 2 hours AND cost more than $20 to replace? |
| Q3 | Customer Email Lookup | Active customers whose last name starts with 'S' |

---

### 🟡 Section 2 — Aggregation & Grouping

| # | Title | Business Question |
|---|---|---|
| Q4 | Revenue by Store | Total payments collected per store — a core retail KPI |
| Q5 | Top 10 Most Rented Films | Which titles drive the most rental activity? |
| Q6 | Category Revenue Breakdown | Which film genres generate the most revenue? |
| Q7 | High-Value Customers | Customers with lifetime spend > $100 — loyalty programme targets |

---

### 🟠 Section 3 — Join Mastery

| # | Title | Business Question |
|---|---|---|
| Q8 | Films Never Rented | Inventory that has never generated revenue — dead stock candidates |
| Q9 | Actor Filmography with Category | Every film an actor appeared in, enriched with genre |
| Q10 | Staff & Store Directory | Full staff list with store city and contact details |

---

### 🔴 Section 4 — Date & String Operations

| # | Title | Business Question |
|---|---|---|
| Q11 | Currently Overdue Rentals | Rentals past due date not yet returned, with days overdue |
| Q12 | Monthly Rental Count by Year | Rental volume broken down by month across all years |
| Q13 | Masked Email Report | Customer names with partially masked emails for GDPR-compliant export |

---

## 🔍 Query Deep-Dives

### Q4 — Revenue by Store
```sql
SELECT s.store_id, a.district, c.city, SUM(p.amount) AS total_payment
FROM payment p
INNER JOIN staff s      ON p.staff_id = s.staff_id
INNER JOIN store st     ON s.store_id = st.store_id
INNER JOIN address a    ON a.address_id = st.address_id
INNER JOIN city c       ON a.city_id = c.city_id
GROUP BY s.store_id
ORDER BY total_payment DESC;
```
Chains 5 tables to surface per-store revenue enriched with geographic context. A foundational KPI query for any retail operation.

---

### Q7 — High-Value Customers (HAVING)
```sql
SELECT c.customer_id,
       CONCAT(...) AS full_name,
       ROUND(SUM(p.amount), 2) AS lifetime_spend
FROM customer c
INNER JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, full_name
HAVING ROUND(SUM(p.amount), 2) > 100
ORDER BY lifetime_spend DESC;
```
Uses `HAVING` (not `WHERE`) to filter on aggregated values — a critical distinction. Proper-casing of names is handled inline using `UPPER(SUBSTRING(...))`.

---

### Q11 — Overdue Rentals with Days Overdue
```sql
SELECT r.rental_id,
       CONCAT(c.first_name,' ',c.last_name) AS customer,
       f.title,
       DATE_ADD(r.rental_date, INTERVAL f.rental_duration DAY) AS due_date,
       DATEDIFF(NOW(), DATE_ADD(r.rental_date, INTERVAL f.rental_duration DAY)) AS days_overdue
FROM rental r
JOIN customer c  ON r.customer_id  = c.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f      ON i.film_id      = f.film_id
WHERE r.return_date IS NULL
  AND DATE_ADD(r.rental_date, INTERVAL f.rental_duration DAY) < NOW()
ORDER BY days_overdue DESC;
```
Computes the due date dynamically from `rental_date + rental_duration`, then measures elapsed overdue time using `DATEDIFF(NOW(), due_date)` — a real operations-dashboard query.

---

## 💡 Key SQL Concepts Demonstrated

| Concept | Queries |
|---|---|
| `INNER JOIN` across 4–5 tables | Q4, Q6, Q9, Q10 |
| `LEFT JOIN` for unmatched records | Q8 |
| `GROUP BY` + `HAVING` | Q5, Q6, Q7 |
| `DATE_ADD`, `DATEDIFF`, `DATE_FORMAT` | Q11, Q12 |
| `CONCAT`, `UPPER`, `SUBSTRING`, `LEFT` | Q3, Q7, Q9, Q10, Q13 |
| Subquery / multi-pass logic | Q8 |
| `LIMIT` for top-N results | Q5, Q6 |

---

*This project was completed as part of a structured SQL for Data Analysis course, applying relational database querying to a real-world normalized schema.*

---

> *"SQL is not just a query language — it is the vocabulary of every data-driven decision."*
