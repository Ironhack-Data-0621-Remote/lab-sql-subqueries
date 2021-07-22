USE sakila; 
-- 1. How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT count(*) as copies_Hunchback_Impossible
FROM inventory i
WHERE film_id = (SELECT film_id FROM film f
WHERE title = "Hunchback Impossible"); 



-- 2. List all films whose length is longer than the average of all the films.

SELECT f.title, f.length
FROM film f 
group by f.title 
HAVING f.length > (SELECT AVG(f.length) FROM film f); 

-- 3. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT first_name, last_name, f.title
FROM actor a
JOIN film_actor fa
ON a.actor_id = fa.actor_id
JOIN film f 
ON fa.film_id = f.film_id
WHERE fa.film_id = (SELECT film_id FROM film
WHERE title = "Alone Trip") ; 

-- 4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.

SELECT f.title as film_title, c.name as film_category
FROM film_category fc
JOIN category c
ON fc.category_id = c.category_id
JOIN film f 
ON f.film_id = fc.film_id
GROUP BY fc.film_id 
HAVING c.name = "Family";


-- 5. Get name and email from customers from Canada using subqueries. 
-- Do the same with joins. Note that to create a join, you will have to identify the correct tables 
-- with their primary keys and foreign keys, that will help you get the relevant information.

-- subsquery
SELECT first_name, last_name, email
FROM customer cu
WHERE address_id IN
(SELECT address_id
FROM address
WHERE city_id IN
(SELECT city_id
FROM city ci
JOIN country co
ON ci.country_id = co.country_id
WHERE co.country = 'Canada')
);
-- join
SELECT cu.first_name, cu.last_name, cu.email
FROM customer cu
JOIN address a
ON cu.address_id = a.address_id
JOIN city ci
ON ci.city_id = a.city_id
JOIN country co
ON ci.country_id = co.country_id
WHERE co.country = "Canada";


-- 6. Which are films starred by the most prolific actor? 
-- Most prolific actor is defined as the actor that has acted in the most number of films.
--  First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.

SELECT f.title AS film, CONCAT(a.first_name, ' ', a.last_name) AS most_prolific_actor
FROM film f
JOIN film_actor fa
ON f.film_id = fa.film_id
JOIN actor a
ON fa.actor_id = a.actor_id
WHERE fa.actor_id in
(SELECT actor_id FROM
(SELECT actor_id, COUNT(film_id) AS count_film, RANK () OVER (ORDER BY count(film_id) DESC) AS ranking
FROM film_actor
GROUP BY actor_id) film_actor
WHERE ranking = 1);


-- 7. Films rented by most profitable customer. 
-- You can use the customer table and payment table to find the most profitable customer ie the customer 
-- that has made the largest sum of payments

SELECT f.title
FROM inventory i
JOIN film f
ON f.film_id = i.film_id
JOIN rental r
ON r.inventory_id = i.inventory_id
WHERE customer_id IN
(SELECT customer_id FROM
(SELECT customer_id, sum(amount) AS sum_amount, RANK () OVER (ORDER BY sum(amount) DESC) AS ranking
FROM payment
GROUP BY customer_id) c1
WHERE ranking = 1);

-- 8. Customers who spent more than the average payments.

SELECT CONCAT(c.first_name, ' ', c.last_name) AS customers_more_than_avg, AVG(p.amount) AS avg_amount
FROM payment p 
JOIN customer c
ON c.customer_id = p.customer_id
GROUP BY p.customer_id
HAVING AVG(amount) > (SELECT AVG(amount) FROM payment);

