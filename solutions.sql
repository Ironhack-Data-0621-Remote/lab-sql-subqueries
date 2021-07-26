use sakila;

-- 1- How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT film.film_id, film.title, count(inventory_id)
FROM film
JOIN inventory
on inventory.film_id = film.film_id
WHERE film.title = "Hunchback Impossible";

-- 2- List all films whose length is longer than the average of all the films.
SELECT title, length
FROM film
WHERE length > (SELECT ROUND(AVG(length),2) 
FROM film);

-- 3- Use subqueries to display all actors who appear in the film Alone Trip.
-- with subquery
SELECT actor_id, film_id
FROM film_actor
WHERE film_id IN
(SELECT film_id FROM(
(SELECT film_id 
FROM film
WHERE title regexp 'Alone') 
)as newtable);

-- with join
SELECT title, film.film_id, film_actor.actor_id, last_name, first_name
FROM film 
JOIN film_actor 
on film.film_id = film_actor.film_id
JOIN actor
ON actor.actor_id = film_actor.actor_id
WHERE title = "Alone Trip";

-- 4- Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
SELECT *
FROM film_category
WHERE category_id = 8;

-- with subqueries in the WHERE statement
SELECT title
FROM film
WHERE film_id IN 
(SELECT film_id
FROM film_category
WHERE category_id IN 
(SELECT category_id
FROM category
WHERE name = "family"));

-- with joins
SELECT name, title
FROM film
JOIN film_category
ON film_category.film_id = film.film_id
JOIN category
ON category.category_id = film_category.category_id
WHERE name = "family";

-- 5 - Get name and email from customers from Canada using subqueries.
SELECT first_name, last_name, email
FROM customer
WHERE address_id IN
(SELECT address_id
FROM address
WHERE city_id IN
(SELECT city_id
FROM city
WHERE country_id IN
(SELECT country_id 
FROM country 
WHERE country = 'Canada'))
) ;

--  Do the same with joins. Note that to create a join, you will have to identify the correct tables with their primary keys
-- and foreign keys, that will help you get the relevant information.

-- JOINS
SELECT last_name, first_name, email, country
FROM customer 
JOIN address
ON customer.address_id = address.address_id
JOIN city
ON city.city_id = address.city_id
JOIN country
ON city.country_id = country.country_id
WHERE country = "Canada";

-- 6- Which are films starred by the most prolific actor? Most prolific actor is defined as the actor
-- that has acted in the most number of films. First you will have to find the most prolific actor 
-- and then use that actor_id to find the different films that he/she starred.
SELECT actor.actor_id, last_name, first_name, title,
COUNT(*) OVER (PARTITION BY actor_id)bankable
FROM film_actor
JOIN actor
ON actor.actor_id = film_actor.actor_id
JOIN film
ON film_actor.film_id = film.film_id
ORDER BY bankable desc;

-- 7- Films rented by most profitable customer. You can use the customer table and payment table to find 
-- the most profitable customer ie the customer that has made the largest sum of payments
-- STEP 1
SELECT payment.customer_id, sum(amount),
RANK () OVER (ORDER BY sum(amount) DESC) AS topclient
FROM payment
GROUP BY customer_id;

-- STEP 2
SELECT payment.customer_id, sum(amount), customer.last_name, customer.first_name, film.title,
RANK () OVER ( ORDER BY sum(amount) DESC) AS topclient
FROM payment
JOIN customer
on payment.customer_id = customer.customer_id
JOIN rental 
ON rental.rental_id = payment.rental_id
JOIN inventory
ON rental.inventory_id = inventory.inventory_id
JOIN film
ON inventory.film_id = film.film_id
GROUP BY customer_id;

-- 8- Customers who spent more than the average payments.
-- step 1
SELECT ROUND(AVG(amount),2)
FROM payment;

-- query
SELECT customer_id, ROUND(AVG(amount),2)
FROM payment
GROUP BY customer_id
HAVING AVG(amount) > (SELECT ROUND(AVG(amount),2)
FROM payment)
ORDER BY AVG(amount);

