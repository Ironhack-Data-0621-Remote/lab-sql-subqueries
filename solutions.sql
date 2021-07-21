-- 1- How many copies of the film Hunchback Impossible exist in the inventory system?
use sakila;
select * from film
where title regexp '^Hunch'; -- id 439

-- Version 1: 0.0017
SELECT count(film_id)
FROM inventory
WHERE film_id IN 
(SELECT film_id 
FROM film 
WHERE title regexp '^Hunch');

-- Version 2: 0.045 sec
SELECT count(inventory_id)
FROM inventory 
WHERE film_id IN
(
SELECT film_id from 
(SELECT film_id 
FROM film 
WHERE title regexp '^Hunch'
) sub1
);

-- Version 3: 0.0016
SELECT count(inventory_id) 
FROM inventory i
JOIN film f
on i.film_id = f.film_id
WHERE title regexp '^Hunch';





-- 2- List all films whose length is longer than the average of all the films.

SELECT * FROM film;

-- How to get the avg leng (115)--> sub query
SELECT avg(length) as avg_len
FROM film;

SELECT title, length
FROM film
WHERE length > 
(SELECT avg(length)
FROM film);

-- 3- Use subqueries to display all actors who appear in the film Alone Trip.
SELECT film_id
FROM film
WHERE title regexp '^Alone'; -- film_id 17

-- alittle slower
SELECT actor_id, film_id
FROM film_actor
WHERE film_id IN
(SELECT film_id 
FROM film
WHERE title regexp 'Alone') 
;



-- faster 
SELECT actor_id, film_id
FROM film_actor
WHERE film_id IN
(SELECT film_id FROM(
(SELECT film_id 
FROM film
WHERE title regexp 'Alone') 
)as t1
);


-- 4- Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
SELECT * FROM category;
SELECT * FROM film_category;

-- find the category -- get the category_id 8
SELECT *
FROM category
WHERE name='Family';


-- first join film_category and film and bring the sub query
SELECT fc.film_id, fc.category_id, f.title
FROM film_category fc
LEFT JOIN film f
ON fc.film_id = f.film_id
WHERE fc.category_id IN (
SELECT category_id
FROM category
WHERE name='Family')
;


-- 5 - Get name and email from customers from Canada using subqueries. 
SELECT * FROM customer;
SELECT * FROM address;
SELECT * FROM city;
SELECT * FROM country;

-- get the country ID - 20
SELECT country_id, country
FROM country
WHERE country like '%anada';

-- get the city_id from country_id 20
SELECT city_id
FROM city
WHERE country_id IN
(SELECT country_id 
FROM country 
WHERE country LIKE '%anada');

-- get the address_id from the city_id
SELECT address_id
FROM address
WHERE city_id IN
(SELECT city_id
FROM city
WHERE country_id IN
(SELECT country_id 
FROM country 
WHERE country LIKE '%anada'));

-- get the customer name and email from the adress_id!
SELECT first_name, last_name, email, address_id
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
WHERE country LIKE '%anada'))
) ;


-- Do the same with joins. Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, 
-- that will help you get the relevant information.
SELECT * FROM customer;
SELECT * FROM address;
SELECT * FROM city;
SELECT * FROM country;

SELECT first_name, last_name, email, country FROM 
(SELECT c.first_name, c.last_name, c.email, a.address_id, ci.city_id, coun.country_id, coun.country
FROM customer c
LEFT JOIN address a
ON c.address_id = a.address_id
LEFT JOIN city ci
ON a.city_id = ci.city_id
LEFT JOIN country coun
ON ci.country_id = coun.country_id) sub
WHERE country = 'Canada'
;

-- 6- Which are films starred by the most prolific actor? 
-- Most prolific actor is defined as the actor that has acted in the most number of films. 
-- First you will have to find the most prolific actor and then use that actor_id 
-- to find the different films that he/she starred.

-- First get the most present actor
use sakila;
select * from film_actor;


Select actor_id
from (
SELECT actor_id, count(film_id), rank() over (order by count(film_id) desc) as ranking 
FROM film_actor
GROUP BY actor_id) t1
Where ranking =1
;

-- Now join the film_actor and film table and use sub query to filter out the prolific actor
SELECT fa.actor_id, title
FROM film_actor fa
JOIN film f
ON fa.film_id = f.film_id
WHERE actor_id IN
(Select actor_id
from (
SELECT actor_id, count(film_id), rank() over (order by count(film_id) desc) as ranking 
FROM film_actor
GROUP BY actor_id)t1
Where ranking =1);


-- 7- Films rented by most profitable customer. 
-- You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments

-- First find out the most profitable custoemr (highest payment)

SELECT * FROM customer;
SELECT * FROM payment;
-- Customer_ID (526)
SELECT customer_id
FROM (
SELECT customer_id, sum(amount), rank() over (order by sum(amount) DESC) AS ranking
FROM payment
GROUP BY customer_id) t1
WHERE ranking =1;


SELECT * FROM rental; -- inventory_id
SELECT * FROM inventory; -- inventory_id, film_id
SELECT * FROM film; -- film_id and title

-- Join two tables inventory and customer and filter it out to most profitable customer
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

-- Average payment
SELECT avg(amount)
FROM payment;

-- Rows of customers whos payment is over average

SELECT customer_id , avg(amount) average
FROM payment
GROUP BY customer_id
HAVING avg(amount) > (SELECT avg(amount)
FROM payment);

-- USE the customer table to get the names based on the customer_id whose payment is over average
SELECT customer_id, first_name, last_name
FROM customer
WHERE customer_id IN
(SELECT customer_id FROM
(SELECT customer_id , avg(amount) average
FROM payment
GROUP BY customer_id
HAVING avg(amount) > (SELECT avg(amount)
FROM payment) 
)t1
);

