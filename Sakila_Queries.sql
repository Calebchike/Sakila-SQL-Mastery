-- BASIC RETRIVAL AND FILTERING
-- Q1  Film Catalogue Snapshot
-- List every film title, its rating, rental duration, and replacement cost, ordered by title.
SELECT 
	title, 
    rating, 
    rental_duration, 
    replacement_cost 
FROM film
ORDER BY title ASC;

-- Q2  Find Expensive Long Films
-- Retrieve films longer than 2 hours that cost more than $20 to replace.
SELECT title, length, replacement_cost
FROM film
WHERE replacement_cost > 20 AND length > 120;


-- Q3  Customer Email Lookup
-- Find active customers whose last name starts with 'S', returning full name and email.
SELECT CONCAT(first_name, ' ', last_name) AS full_name, email
FROM customer
WHERE LEFT(last_name,1) = 'S';

-- AGGREGATE 
-- Q4  Revenue by Store
-- Total payments collected per store — a core KPI for any retail operation.
SELECT s.store_id, a.district, c.city, SUM(p.amount) AS total_payment
FROM payment p
INNER JOIN staff s
ON p.staff_id = s.staff_id
INNER JOIN store st
ON s.store_id = st.store_id
INNER JOIN address a
ON a.address_id = st.address_id
INNER JOIN city c
ON a.city_id = c.city_id
GROUP BY s.store_id
ORDER BY total_payment DESC;


-- Q5  Top 10 Most Rented Films
-- Which titles drive the most rental activity? Inventory planning depends on this.
SELECT f.title, COUNT(*) AS total_rental
FROM film f
INNER JOIN inventory i
ON f.film_id = i.film_id
INNER JOIN rental r
ON r.inventory_id = i.inventory_id
GROUP BY f.title
ORDER BY total_rental DESC 
LIMIT 10;


-- Q6  Category Revenue Breakdown
-- Which film genres generate the most revenue? Useful for purchasing decisions.
SELECT c.name AS category, COUNT(r.rental_id) AS total_rentals, ROUND(SUM(p.amount), 2) AS total_revenue
FROM category c
INNER JOIN film_category fc
ON c.category_id = fc.category_id
INNER JOIN film f
ON fc.film_id = f.film_id
INNER JOIN inventory i
ON f.film_id = i.film_id
INNER JOIN rental r
ON i.inventory_id = r.inventory_id
INNER JOIN payment p
ON r.rental_id = p.rental_id
GROUP BY c.name
ORDER BY total_revenue DESC
LIMIT 10;


-- Q7  High-Value Customers (HAVING)
-- Customers who have spent more than $100 in total — targets for a loyalty programme.
SELECT 
c.customer_id,
CONCAT(CONCAT(UPPER(SUBSTRING(c.first_name,1,1)),LOWER(SUBSTRING(c.first_name,2))),
' ', 
CONCAT(UPPER(SUBSTRING(c.last_name,1,1)),LOWER(SUBSTRING(c.last_name,2)))) AS full_name,
ROUND(SUM(p.amount),2) AS lifetime_spend
FROM customer c
INNER JOIN payment p
ON c.customer_id = p.customer_id
GROUP BY c.customer_id, full_name
HAVING ROUND(SUM(p.amount),2) > 100
ORDER BY lifetime_spend DESC;


-- JOIN MASTERY
-- Q8  Films Never Rented (LEFT JOIN)
-- Identify inventory that has never generated revenue — candidates for removal.
SELECT i.inventory_id, ROUND(SUM(p.amount),2) AS total_revenue
FROM inventory i
LEFT JOIN rental r
ON i.inventory_id = r.inventory_id
LEFT JOIN payment p 
ON r.rental_id = p.rental_id
GROUP BY i.inventory_id
HAVING total_revenue IS NULL;

SELECT f.title, i.inventory_id
FROM film f
LEFT JOIN inventory i
ON f.film_id = i.film_id
LEFT JOIN rental r
ON i.inventory_id = r.inventory_id
HAVING i.inventory_id IS NULL;


-- Q9  Actor Filmography with Category
-- List every film an actor has appeared in, together with its genre.
SELECT
a.actor_id,
CONCAT(CONCAT(UPPER(SUBSTRING(a.first_name,1,1)),LOWER(SUBSTRING(a.first_name,2))),
' ', 
CONCAT(UPPER(SUBSTRING(a.last_name,1,1)),LOWER(SUBSTRING(a.last_name,2)))) AS actor_full_name,
f.title, c.name AS genre
FROM actor a
INNER JOIN film_actor fa
ON a.actor_id = fa.actor_id
INNER JOIN film f
ON fa.film_id = f.film_id
INNER JOIN film_category fc
ON f.film_id = fc.film_id
INNER JOIN category c
ON fc.category_id = c.category_id
WHERE a.actor_id = 5
ORDER BY f.title ASC;

-- List every movie with at least one actor from the actor list and their genre.
SELECT DISTINCT(f.film_id), f.title, c.name AS genre
FROM film f
LEFT JOIN film_actor fa
ON f.film_id = fa.film_id
LEFT JOIN film_category fc
ON f.film_id = fc.film_id
LEFT JOIN category c
ON fc.category_id = c.category_id
WHERE fa.actor_id IS NOT NULL;


-- Q10  Staff & Their Store Details
-- Full staff directory enriched with store city.
SELECT 
s.staff_id,
CONCAT(CONCAT(UPPER(SUBSTRING(s.first_name,1,1)),LOWER(SUBSTRING(s.first_name,2))),
' ', 
CONCAT(UPPER(SUBSTRING(s.last_name,1,1)),LOWER(SUBSTRING(s.last_name,2)))) AS staff_full_name, 
s.email, a.address_id, a.address, a.phone,
c.city,
co.country
FROM staff s
INNER JOIN store st
ON s.store_id = st.store_id
INNER JOIN address a
ON s.address_id = a.address_id
INNER JOIN city c
ON a.city_id = c.city_id
INNER JOIN country co
ON c.country_id = co.country_id;



-- DATE & STRING OPERATIONS
-- Q11  Currently Overdue Rentals
-- Flag rentals past their return date that have not been returned — operations dashboard.
SELECT r.rental_id, f.title, CONCAT(c.first_name, ' ', c.last_name) AS customer_name, r.rental_date, 
DATE_ADD(r.rental_date, INTERVAL f.rental_duration DAY) AS due_date
FROM rental r
INNER JOIN customer c
ON r.customer_id=c.customer_id
INNER JOIN inventory i 
ON r.inventory_id = i.inventory_id
INNER JOIN film f 
ON i.film_id = f.film_id
WHERE r.return_date IS NULL
;

-- Same as the previous code but Flag rentals past their return date that have not been returned with the number of days overdue.
SELECT  r.rental_id,
        CONCAT(c.first_name,' ',c.last_name) AS customer,
        f.title,
        r.rental_date,
        DATE_ADD(r.rental_date,
            INTERVAL f.rental_duration DAY) AS due_date,
        DATEDIFF(NOW(),
            DATE_ADD(r.rental_date,
                INTERVAL f.rental_duration DAY)) AS days_overdue
FROM    rental    r
JOIN    customer  c  ON r.customer_id  = c.customer_id
JOIN    inventory i  ON r.inventory_id = i.inventory_id
JOIN    film      f  ON i.film_id      = f.film_id
WHERE   r.return_date IS NULL
  AND   DATE_ADD(r.rental_date,
            INTERVAL f.rental_duration DAY) < NOW()
ORDER BY days_overdue DESC;


-- Q12  Monthly Rental Count by Year
-- Break down how many rentals occurred each month.
SELECT YEAR(r.rental_date) AS year, 
EXTRACT(MONTH FROM r.rental_date) AS month, 
DATE_FORMAT(rental_date, '%b') AS period,
COUNT(r.rental_date) AS rented_movie
FROM rental r
GROUP BY year, month, period 
ORDER BY year, month, rented_movie DESC;

-- Slightly different but Same result as the previous code Breaks down how many rentals occurred each month.
SELECT  YEAR(rental_date)  AS yr,
        MONTH(rental_date) AS mo,
        DATE_FORMAT(rental_date, '%b %Y') AS period,
        COUNT(*) AS total_rentals
FROM    rental
GROUP BY yr, mo,period 
ORDER BY yr, mo;

