USE sakila;

-- 1- How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT f.title, count(i.inventory_id)
FROM inventory i
JOIN film f
ON i.film_id = f.film_id
GROUP BY f.title
HAVING f.title = 'Hunchback Impossible';

-- 2- List all films whose length is longer than the average of all the films.
SELECT * FROM film
WHERE length > 
(SELECT AVG(length) FROM film);

-- 3- Use subqueries to display all actors who appear in the film Alone Trip.
SELECT a.first_name, a.last_name
FROM film_actor fa
JOIN actor a
ON fa.actor_id = a.actor_id
WHERE fa.film_id = 
(SELECT film_id FROM film WHERE title = 'Alone Trip');

-- 4- Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT f.title
FROM film f
JOIN film_category fc
ON f.film_id = fc.film_id
WHERE fc.category_id = (SELECT category_id FROM category WHERE name = 'Family');

-- 5 - Get name and email from customers from Canada using subqueries. Do the same with joins. Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.
SELECT c.first_name, c.last_name, c.email
FROM customer c
JOIN address a
ON c.address_id = a.address_id
JOIN city ci
ON a.city_id = ci.city_id
JOIN country co
ON ci.country_id = co.country_id
WHERE co.country = 'Canada';

-- 6- Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.
SELECT fa.actor_id, title
FROM film_actor fa
JOIN film f
ON fa.film_id = f.film_id
WHERE actor_id IN
(SELECT actor_id
FROM (
SELECT actor_id, count(film_id), RANK() OVER (ORDER BY count(film_id) DESC) AS ranking 
FROM film_actor
GROUP BY actor_id)t1
WHERE ranking =1);

-- 7- Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments
SELECT customer_id, title
FROM (
SELECT r.inventory_id, r.customer_id, i.film_id, title
FROM rental r
JOIN inventory i
ON r.inventory_id = i.inventory_id
JOIN film f
ON i.film_id = f.film_id) t1
WHERE customer_id IN
(SELECT customer_id
FROM (
SELECT customer_id, sum(amount), rank() over (order by sum(amount) DESC) AS ranking
FROM payment
GROUP BY customer_id) t2
WHERE ranking =1);

-- 8- Customers who spent more than the average payments.
SELECT customer_id, first_name, last_name
FROM customer
WHERE customer_id IN
(SELECT customer_id FROM
(SELECT customer_id , avg(amount) average
FROM payment
GROUP BY customer_id
HAVING avg(amount) > (SELECT avg(amount) 
FROM payment))t1);