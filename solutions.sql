USE sakila;

-- 1- How many copies of the film Hunchback Impossible exist in the inventory system?

-- usinh subquery
SELECT film_id, COUNT(inventory_id) AS count_copies
FROM inventory
GROUP BY film_id
HAVING film_id = (
	SELECT film_id
	FROM film
	WHERE title = 'Hunchback Impossible');

-- using join
SELECT COUNT(film_id) AS count_copies
FROM inventory i
JOIN film f
USING(film_id)
WHERE f.title = 'Hunchback Impossible';

-- 2- List all films whose length is longer than the average of all the films.
SELECT AVG(length) FROM film;

SELECT film_id, title, length
FROM film
HAVING length > (SELECT AVG(length) FROM film)
ORDER BY length;

-- 3- Use subqueries to display all actors who appear in the film Alone Trip.
SELECT fa.actor_id, a.first_name, a.last_name 
FROM film_actor fa
JOIN actor a
USING(actor_id)
WHERE film_id = (
	SELECT film_id
	FROM film
	WHERE title = 'Alone Trip');

-- 4- Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.

SELECT * FROM category;

-- using subquery
SELECT fc.film_id, f.title
FROM film_category fc
JOIN film f
USING(film_id)
WHERE category_id = (
	SELECT category_id
	FROM category
	WHERE name = 'Family');

-- using join
SELECT fc.film_id, f.title
FROM film_category fc
JOIN film f
USING(film_id)
JOIN category c
ON c.category_id = fc.category_id
WHERE c.name = 'Family';

-- 5 - Get name and email from customers from Canada using subqueries. Do the same with joins. 
-- Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, 
-- that will help you get the relevant information.

-- using subqueries
SELECT first_name, last_name, email
FROM customer
WHERE address_id IN (
	SELECT address_id
	FROM address
	WHERE city_id IN (
		SELECT city_id
		FROM city
		WHERE country_id = (
			SELECT country_id
			FROM country
			WHERE country = 'Canada')
	)
);

-- using joins
SELECT cu.first_name, cu.last_name, cu.email
FROM customer cu
JOIN address a
USING(address_id)
JOIN city ci
USING(city_id)
JOIN country cou
USING(country_id)
WHERE cou.country = 'Canada';

-- 6- Which are films starred by the most prolific actor? 
-- Most prolific actor is defined as the actor that has acted in the most number of films. 
-- First you will have to find the most prolific actor and then use that actor_id to find the different films 
-- that he/she starred.

-- testing sub query to find out actor that acted in the most number of films
SELECT actor_id, COUNT(film_id) AS count_films, RANK() OVER(ORDER BY COUNT(film_id) DESC) AS rank_count
FROM film_actor
GROUP BY actor_id
ORDER BY count_films DESC;

SELECT fa.film_id, f.title
FROM film_actor fa
JOIN film f
USING(film_id)
WHERE actor_id = (
	SELECT actor_id
	FROM (
		SELECT actor_id, COUNT(film_id) AS count_films, RANK() OVER(ORDER BY COUNT(film_id) DESC) AS rank_count
		FROM film_actor
		GROUP BY actor_id
		ORDER BY count_films DESC) t1
	WHERE rank_count = 1);

-- 7- Films rented by most profitable customer. 
-- You can use the customer table and payment table to find the most profitable customer 
-- ie the customer that has made the largest sum of payments

SELECT i.film_id, f.title
FROM inventory i
JOIN film f
USING(film_id)
WHERE inventory_id IN (
	SELECT inventory_id
	FROM rental
	WHERE customer_id = (
		SELECT customer_id
		FROM (
			SELECT customer_id, SUM(amount), RANK() OVER(ORDER BY SUM(amount) DESC) AS rank_sum
			FROM payment
			GROUP BY customer_id) t1
		WHERE rank_sum = 1)
);

-- 8- Customers who spent more than the average payments.

SELECT SUM(amount) FROM payment; -- total payment amount
SELECT COUNT(customer_id) FROM customer; -- number of customers
SELECT SUM(amount)/(SELECT COUNT(customer_id) FROM customer) FROM payment; -- average payment amount per customer

SELECT customer_id, SUM(amount) AS avg_amount_cmr
FROM payment
GROUP BY customer_id
HAVING avg_amount_cmr > (SELECT SUM(amount)/(SELECT COUNT(customer_id) FROM customer) FROM payment)
ORDER BY 2 DESC;