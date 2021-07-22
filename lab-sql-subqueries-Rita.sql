use sakila;

-- 1- How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT f.title, count(i.film_id) as n_copies
FROM inventory i 
JOIN film f
ON i.film_id = f.film_id
WHERE f.title = 'Hunchback Impossible'
GROUP BY f.title;


-- 2- List all films whose length is longer than the average of all the films.

SELECT title, avg(length)
FROM film
GROUP BY title
HAVING avg(length) > (SELECT avg(length) from film);

-- 3- Use subqueries to display all actors who appear in the film Alone Trip.

SELECT first_name, last_name, title
FROM actor a
JOIN film_actor f
on a.actor_id = f.actor_id
JOIN film f1
on f1.film_id = f.film_id
WHERE title = 'Alone Trip';

-- I don't really understand what's the added value of a subquery here

SELECT first_name, last_name
FROM actor
WHERE actor_id in (
	SELECT actor_id
	FROM film_actor 
	WHERE film_id in (
		SELECT film_id
		FROM film
		WHERE title = 'Alone Trip'));


-- 4- Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

SELECT film_id, title
FROM film
WHERE film_id in (
	SELECT film_id
	FROM film_category 
	WHERE category_id in (
		SELECT category_id
		FROM category
		WHERE category.name = 'Family'));

-- with subquery I cannot get the title of the movie so I tried with join

SELECT f.film_id, f.title, c.name
FROM film f
JOIN film_category f1
ON f.film_id = f1.film_id
JOIN category c
ON c.category_id = f1.category_id
WHERE name = 'Family';
        
-- 5 - Get name and email from customers from Canada using subqueries. Do the same with joins. 
-- Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, 
-- that will help you get the relevant information.


SELECT email, country
FROM customer c
JOIN address a
ON c.address_id = a.address_id
JOIN city c1
ON c1.city_id = a.city_id
JOIN country c2
ON c1.country_id = c2.country_id
WHERE country = 'Canada';

-- sub query: 

SELECT email 
FROM customer 
WHERE address_id in (
	SELECT address_id
	FROM address WHERE city_id in (
		SELECT city_id
		FROM city WHERE country_id in
			(SELECT country_id
			FROM country WHERE country = 'CANADA')));

-- 6- Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. 
-- First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.

-- tried different queries but none worked :(

SELECT title
FROM film
WHERE film_id in (
	SELECT film_id
    FROM film_actor
    WHERE actor_id in
		(SELECT actor_id, rank () over(order by count(film_id) DESC) as rank1
		FROM film_actor
		GROUP BY actor_id
		WHERE rank1 = 1));

SELECT title
FROM film f
JOIN film_actor a
ON f.film_id = a.film_id
WHERE a.film_id IN (SELECT actor_id, rank () over(order by count(film_id) DESC) as rank1
		FROM film_actor
		GROUP BY actor_id
		WHERE rank1 = 1);

SELECT title
FROM film
WHERE film_id in (SELECT actor_id, rank() over(order by count(a.film_id) DESC) as rank_a
FROM film_actor a
JOIN film f
ON a.film_id = a.film_id 
GROUP by actor_id) as t
WHERE rank_a = 1;


-- 7- Films rented by most profitable customer. 
-- You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments

-- DID NOT HAVE TIME

-- 8- Customers who spent more than the average payments.

-- DID NOT HAVE TIME