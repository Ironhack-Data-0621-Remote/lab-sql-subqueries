use sakila;
-- 1- How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT f.film_id, title, COUNT(inventory_id)
FROM film f
JOIN inventory i
ON f.film_id = i.film_id
WHERE title = 'Hunchback Impossible'
GROUP BY f.film_id, title;

-- 2- List all films whose length is longer than the average of all the films.
SELECT avg(length) FROM film;

SELECT film_id, title, length
FROM film
WHERE length > (SELECT avg(length) FROM film);

-- 3- Use subqueries to display all actors who appear in the film Alone Trip.
SELECT *
FROM actor
WHERE actor_id in (select actor_id from film f join film_actor fa on f.film_id = fa.film_id where title = 'Alone Trip');


-- 4- Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT film_id 
FROM film_category
where category_id in (SELECT category_id from category where name = 'family');


-- 5 - Get name and email from customers from Canada using subqueries. Do the same with joins. Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.
SELECT first_name, last_name, email
FROM customer
WHERE address_id IN (SELECT address_id FROM address WHERE city_id IN (SELECT city_id FROM city WHERE country_id IN (SELECT country_id FROM country WHERE country = 'Canada') ) ) ;

SELECT Distinct(c.first_name), c.email, co.country
FROM customer c
LEFT JOIN address a ON c.address_id = c.address_id
LEFT JOIN city ci ON a.city_id = ci.city_id
LEFT JOIN country co ON  co.country_id = ci.country_id
WHERE co.country = 'Canada';

-- 6- Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.

WITH cte1 as (SELECT actor_id, COUNT(film_id)
FROM film_actor
GROUP BY actor_id
ORDER BY 2 DESC
LIMIT 1),
cte2 as (
SELECT actor_id FROM cte1
)
SELECT f.film_id, f.title
FROM film f
JOIN film_actor fa
ON f.film_id = fa.film_id
WHERE fa.actor_id in (SELECT actor_id FROM cte2);

-- 7- Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments
WITH cte1 as (SELECT customer_id, SUM(amount)
FROM payment
GROUP BY customer_id
ORDER BY 2 DESC
LIMIT 1)
SELECT i.film_id
FROM inventory i
JOIN rental r
ON i.inventory_id = r.inventory_id
WHERE r.customer_id IN (SELECT customer_id FROM cte1);

-- 8- Customers who spent more than the average payments.
SELECT customer_id, SUM(amount)
FROM payment
GROUP BY customer_id
HAVING SUM(amount) > (SELECT avg(amount) FROM payment)
ORDER BY 2 DESC;

