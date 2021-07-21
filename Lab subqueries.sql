use sakila;

-- 1- How many copies of the film Hunchback Impossible exist in the inventory system?
select film_id, count(inventory_id) as copies
from inventory
where film_id = 439;

-- 2- List all films whose length is longer than the average of all the films.
select film_id, new_length
from film
having new_length > (select avg(new_length) from film);

-- 3- Use subqueries to display all actors who appear in the film Alone Trip.
select actor_id from film_actor
where film_id in (select film_id from film
where title = 'Alone Trip');

-- 4- Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
select film_id from film_category
where category_id in (select category_id from category
where new_name = 'Family');

-- 5 - Get name and email from customers from Canada using subqueries. Do the same with joins. Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.
select first_name, last_name, email
from customer c
join address a
on c.address_id = a.address_id
where a.city_id in (
select ci.city_id
from city ci
join country co
on ci.country_id = co.country_id
where country = 'Canada');

-- 6- Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. 
-- First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.
select a.title
from film a
join film_actor f
on a.film_id = f.film_id
where f.actor_id in (select actor_id from (
select actor_id, count(film_id) as nb_film, rank () over (order by count(film_id) desc) as ranking
from film_actor
group by actor_id) tf1
where ranking = 1);

-- 7- Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments
select f.title
from inventory i
join film f
on f.film_id = i.film_id
join rental r
on r.inventory_id = i.inventory_id
where customer_id in (
select customer_id from (
select customer_id, sum(amount) as amount, rank () over (order by sum(amount) desc) as ranking
from payment
group by customer_id) t1
where ranking = 1);

-- 8- Customers who spent more than the average payments.
select customer_id from payment
group by customer_id
having avg(amount) > (select avg(amount) from payment);

