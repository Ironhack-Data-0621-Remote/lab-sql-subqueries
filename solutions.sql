-- 1- How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT count(*) FROM inventory
WHERE film_id = (SELECT film_id FROM film
WHERE title = "Hunchback Impossible");

-- 2- List all films whose length is longer than the average of all the films.

SELECT film_id, title, length FROM film
WHERE length > (SELECT avg(length) FROM film);

-- 3- Use subqueries to display all actors who appear in the film Alone Trip.

SELECT fa.actor_id, concat(a.first_name, ' ', a.last_name) as actor_name
FROM film_actor fa
JOIN actor a
ON fa.actor_id = a.actor_id
WHERE film_id = (SELECT film_id FROM film
WHERE title = "Alone Trip")
;

-- 4- Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

SELECT f.title
FROM film f
JOIN film_category fc
ON f.film_id = fc.film_id
WHERE fc.category_id = (SELECT category_id FROM category
WHERE name = "Family");

-- 5 - Get name and email from customers from Canada using subqueries. Do the same with joins. Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.

SELECT concat(first_name, ' ', last_name) AS name, email
FROM customer
WHERE address_id = (SELECT address_id FROM address
WHERE district = "Canada");

-- There is no address_id relativev to Canada
SELECT address_id FROM address
WHERE district = "Canada";

SELECT * FROM country
WHERE country = "Canada";

-- 6- Which are films starred by the most prolific actor?

SELECT f.title
FROM film_actor fa
JOIN film f
ON fa.film_id = f.film_id
WHERE fa.actor_id = (SELECT actor_id
FROM film_actor
GROUP BY actor_id
ORDER BY count(*) DESC
LIMIT 1);

-- Most prolific actor is defined as the actor that has acted in the most number of films.
-- First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.

-- Most prolific actor
SELECT actor_id, count(*)
FROM film_actor
GROUP BY actor_id
ORDER BY count(*) DESC
LIMIT 1;

-- Name of the most prolific actor
SELECT concat(first_name, ' ', last_name) AS name FROM actor
WHERE actor_id = (SELECT actor_id
FROM film_actor
GROUP BY actor_id
ORDER BY count(*) DESC
LIMIT 1);

-- 7- Films rented by most profitable customer. 
-- You can use the customer table and payment table to find the most profitable customer ie 
-- the customer that has made the largest sum of payments

SELECT f.title
FROM rental r
JOIN inventory i
ON r.inventory_id = i.inventory_id
JOIN film f
ON i.film_id = f.film_id
WHERE r.customer_id = (SELECT p.customer_id
FROM payment p
JOIN customer c
ON p.customer_id = c.customer_id
GROUP BY p.customer_id
ORDER BY sum(p.amount) DESC
LIMIT 1);

-- Data from the most profitable customer
SELECT p.customer_id, sum(p.amount) AS tot_amount, concat(c.first_name, ' ', c.last_name) AS name
FROM payment p
JOIN customer c
ON p.customer_id = c.customer_id
GROUP BY p.customer_id
ORDER BY sum(p.amount) DESC
LIMIT 1;

-- 8- Customers who spent more than the average payments.

SELECT * FROM (
SELECT p.customer_id, sum(p.amount) AS tot_amount, concat(c.first_name, ' ', c.last_name) AS name
FROM payment p
JOIN customer c
ON p.customer_id = c.customer_id
GROUP BY p.customer_id
ORDER BY sum(p.amount) DESC
) customers
WHERE tot_amount > (SELECT avg(amount) FROM payment)
;