USE sakila;

-- 1- How many copies of the film Hunchback Impossible exist in the inventory system?
-- count of inventory_id from inventory table and title from film table
-- join on film_id
SELECT COUNT(i.inventory_id) as copies
FROM film f
JOIN inventory i
ON f.film_id = i.film_id
WHERE f.title = "Hunchback Impossible";

-- 2- List all films whose length is longer than the average of all the films.
-- length and average length from film table
SELECT film_id, title, film.length
FROM film
WHERE film.length > (SELECT AVG(film.length) FROM film);

-- 3- Use subqueries to display all actors who appear in the film Alone Trip.
-- actors from film_actor table and title from film table
SELECT actor_id
FROM film_actor
WHERE film_id = (SELECT film_id FROM film WHERE title = "Alone Trip");

-- 4- Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
-- category name and id from category table, category_id and film_id from film_category, film name and id from film.
-- JOIN on film_id and category_id
SELECT f.film_id, f.title, c.name
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
WHERE c.name = "Family";

-- 5 - Get name and email from customers from Canada using subqueries. Do the same with joins. 
-- Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, 
-- that will help you get the relevant information.

-- error says subqueries show more than one row as result, the issue is the final subquery having more than one result for country canada (I guess?)
-- is this why it's not working?

SELECT first_name, last_name, email FROM customer
WHERE store_id = (SELECT store_id FROM store
WHERE address_id = (SELECT address_id FROM address
WHERE city_id = (SELECT city_id FROM city
WHERE country_id = (SELECT RANK() over (order by country_id) FROM country LIMIT 1
WHERE country = "Canada"
))));

-- JOINS
SELECT c.first_name, c.last_name, c.email, cou.country
FROM customer c
JOIN store s ON s.store_id = c.store_id
JOIN address a ON s.address_id = a.address_id
JOIN city ci ON ci.city_id = a.city_id
JOIN country cou ON cou.country_id = ci.country_id
WHERE cou.country = "Canada";

-- 6- Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. 
-- First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.
SELECT fa.actor_id, a.first_name, a.last_name,
RANK() over (order by count(fa.film_id) desc) as profilic_rank
FROM film_actor fa
JOIN actor a on fa.actor_id = a.actor_id
GROUP BY fa.actor_id
LIMIT 1;

-- most profilic actor_id 107
SELECT f.film_id, f.title, fa.actor_id
FROM film f
JOIN film_actor fa ON f.film_id = fa.film_id
WHERE fa.actor_id = 107;

-- 7- Films rented by most profitable customer. 
-- You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments
SELECT *
FROM film
WHERE customer_id = (SELECT r.customer_id,
RANK() over (order by count(p.payment_id) desc) as profitable
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id);

SELECT *
FROM customer;

-- customer_id per count of payements
SELECT customer_id, 
RANK() over (order by count(payment_id) desc) as payments
FROM payment
GROUP BY customer_id;

-- to get from customer_id to films
SELECT *
FROM customer c
JOIN payment

-- 8- Customers who spent more than the average payments.
-- customer table : first name, last name, customer id
-- rental table : customer id, rental id
-- payment table : customer id, rental id, amount

CREATE temporary table rental_payment
SELECT c.customer_id, c.first_name, c.last_name, count(r.rental_id) as rentals, (count(r.rental_id) * p.amount) as total_paid
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id;

SELECT *
FROM rental_payment
WHERE total_paid > (SELECT AVG(total_paid) FROM rental_payment);