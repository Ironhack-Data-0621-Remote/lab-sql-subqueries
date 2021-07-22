USE sakila;
-- 1. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT COUNT(inventory_id) as number_of_copies FROM(
SELECT * 
FROM film
WHERE title = 'Hunchback Impossible') as f
JOIN sakila.inventory i
ON f.film_id = i.film_id;

-- 2. List all films whose length is longer than the average of all the films.
SELECT film_id, title 
FROM film
WHERE length > (SELECT AVG(length) FROM film);

-- 3. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT a.actor_id, first_name, last_name FROM( 
SELECT *
FROM film
WHERE title = 'Alone Trip') as f
JOIN film_actor fa
ON f.film_id = fa.film_id
JOIN actor a 
ON fa.actor_id = a.actor_id;
-- how would you do this with multiple subqueries instead of the 1 subquery and joins? i know from class that it
-- can be done and it makes sense, but i cannot seem to get the joins out of my thinking hahah.

-- 4. Sales have been lagging among young families, and you wish to target all family movies for a promotion.
-- Identify all movies categorized as family films.
SELECT f.film_id, f.title FROM( 
SELECT category_id
FROM category
WHERE name = 'Family') as c
JOIN film_category fc
ON c.category_id = fc.category_id
JOIN film f 
ON fc.film_id = f.film_id;

-- 5. Get name and email from customers from Canada using subqueries. Do the same with joins. 
-- Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.
SELECT first_name, last_name, email 
FROM customer
WHERE address_id IN (SELECT address_id FROM address 
WHERE city_id IN (SELECT city_id FROM city
WHERE country_id IN (SELECT country_id FROM country
WHERE country = 'Canada')));
-- Got the multiple queries now hahah, but left the previous answer as is because its prettier
SELECT c.first_name, c.last_name, c.email FROM(
SELECT country_id
FROM country
WHERE country = 'Canada') as co
JOIN city ci
ON co.country_id = ci.country_id
JOIN address a
ON ci.city_id = a.city_id
JOIN customer c
ON a.address_id = c.address_id;

-- 6. Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. 
-- First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.
SELECT f.film_id, f.title FROM(
SELECT film_id, COUNT(actor_id) as counted FROM film_actor
GROUP BY film_id
HAVING counted = MAX(counted)) as fa
JOIN film f
ON fa.film_id = f.film_id; 
-- dont know if this is correct, because it seemed counter-intuitive to group by 'film_id'
  
-- 7. Films rented by most profitable customer. 
-- You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments
SELECT f.film_id, f.title FROM(
SELECT inventory_id, COUNT(customer_id) as counted FROM rental
GROUP BY inventory_id
HAVING counted = MAX(counted)) as r
JOIN inventory i
ON r.inventory_id = i.inventory_id
JOIN film f
ON i.film_id = f.film_id
GROUP BY f.film_id;  

-- 8. Customers who spent more than the average payments.
SELECT c.customer_id, c.first_name, c.last_name FROM(
SELECT customer_id FROM payment
WHERE amount > (SELECT AVG(amount) FROM payment)
GROUP BY customer_id) as p
JOIN customer c
ON p.customer_id = c.customer_id; 
-- is this the right answer? as it is just returning consecutive customer_id's?? 