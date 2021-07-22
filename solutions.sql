-- 1- How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT DISTINCT title, COUNT(*) OVER (PARTITION BY f.film_id, i.film_id) AS counts
FROM film f
JOIN inventory i ON f.film_id = i.film_id
WHERE title = 'HUNCHBACK IMPOSSIBLE';

-- 2- List all films whose length is longer than the average of all the films.
SELECT title
FROM film
GROUP BY title
HAVING AVG(length) > (SELECT AVG(length) FROM film);

-- 3- Use subqueries to display all actors who appear in the film Alone Trip.
SELECT *
FROM (	SELECT first_name, last_name 
		FROM actor a
		JOIN film_actor fa ON a.actor_id = fa.actor_id
		JOIN film f ON fa.film_id = f.film_id
		WHERE title = 'ALONE TRIP') AS t;

-- 4- Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT f.title, c.name
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id 
WHERE c.name = 'Family';

-- 5 - Get name and email from customers from Canada using subqueries. Do the same with joins. Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.
SELECT *
FROM (	SELECT c.first_name, c.last_name, c.email, co.country_id
		FROM customer c
        JOIN address a ON c.address_id = a.address_id
        JOIN city ci ON a.city_id = ci.city_id
        JOIN country co ON ci.country_id = co.country_id
        WHERE co.country_id = 'Canada') AS t;

-- 6- Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.
SELECT t.first_name, t.last_name
FROM (	SELECT a.first_name, a.last_name, COUNT(*) OVER(PARTITION BY fa.actor_id ORDER BY COUNT(fa.actor_id))
		FROM actor a
        JOIN film_actor fa ON a.actor_id = fa.actor_id
        JOIN film f ON fa.film_id = f.film_id
        GROUP BY a.first_name, a.last_name, fa.actor_id) AS t;

-- 7- Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments
SELECT c.last_name, SUM(p.amount), RANK() OVER(ORDER BY MAX(p.amount) DESC)
FROM customer c
JOIN payment p ON c.customer_id = c.customer_id
GROUP BY c.last_name
LIMIT 1;

-- 8- Customers who spent more than the average payments.
SELECT c.last_name
FROM customer c
JOIN payment p ON c.customer_id = c.customer_id
GROUP BY c.last_name
HAVING AVG(amount) > (SELECT AVG(amount) FROM payment);