use sakila;

-- 1- How many copies of the film Hunchback Impossible exist in the inventory system?

select count(f.film_id), f.title
from film f
join inventory i
on f.film_id = i.film_id
where f.title = 'Hunchback Impossible'
group by f.title;

-- is this cheating? :)

-- 2- List all films whose length is longer than the average of all the films.

select * from film
where length > 
(select avg(length) from film)
order by length desc;

-- 3- Use subqueries to display all actors who appear in the film Alone Trip.

select a.first_name, a.last_name
from actor a
join
(select *
from film_actor
where film_id in
(select film_id
from film 
where title = 'Alone Trip')) as temp
on a.actor_id = temp.actor_id;


-- 4- Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

select *
from film_category
where category_id in
(select category_id
from category
where name = 'Family');

-- this way shows just the film_ids with the category_ids (8 = Family)

select f.title
from film f
join
(select *
from film_category
where category_id in
(select category_id
from category
where name = 'Family')) as temp
on f.film_id = temp.film_id;

-- this way shows just the film names. Is this the correct answer to the question?

-- 5 - Get name and email from customers from Canada using subqueries. Do the same with joins. Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.

select cust.first_name, cust.last_name, cust.email
from customer cust
join
(select c.country, ci.city, a.address_id
from country c
join city ci
on c.country_id = ci.country_id
join address a
on ci.city_id = a.city_id
where country = 'Canada') as temp
on cust.address_id = temp.address_id;

-- with a subquery

select c.first_name, c.last_name, c.email
from customer c
join address a
on c.address_id = a.address_id
join city ci
on a.city_id = ci.city_id
join country cu
on ci.country_id = cu.country_id
where cu.country = 'Canada';

-- Now with joins. The results are the same but for me it makes much more sense and took me much less time with the joins than with the sub query :)

-- 6- Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.

select title
from film
where film_id in
(select film_id 
from film_actor
where actor_id in
(select actor_id
from
(select actor_id, count(film_id), 
rank() over (order by count(film_id) desc) as ranking
from film_actor 
group by actor_id) as temp
where ranking = 1))
;


-- 7- Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments



select first_name, last_name, customer_id
from customer
where customer_id in
(select customer_id
from
(select customer_id, sum(amount), 
rank() over (order by sum(amount) desc) as ranking
from payment 
group by customer_id) as temp
where ranking = 1);

-- this tells us the most profitable customer and his customer_id

select title, film_id 
from film
where film_id in(
select film_id
from inventory where
inventory_id in(
select inventory_id
from rental
where customer_id in
(select customer_id from
(select first_name, last_name, customer_id
from customer
where customer_id in
(select customer_id
from
(select customer_id, sum(amount), 
rank() over (order by sum(amount) desc) as ranking
from payment 
group by customer_id) as temp
where ranking = 1)) as sub
)));

-- this returns all the films rented by the most profitable customer. Seems like an inefficient way of doing it. Is there a better way (apart from a join)?

SELECT title
FROM rental
join inventory
on rental.inventory_id = inventory.inventory_id
join film
on inventory.film_id = film.film_id
where customer_id = 526
order by title;

-- this is the way to do it with a join I think. I did cheat a bit and find his customer_id before :)

-- 8- Customers who spent more than the average payments.

select *
from customer c
join
(select *
from payment
where amount >
(select avg(amount)
from payment)
order by amount desc) as temp
on temp.customer_id = c.customer_id;

-- I think this does return the customers who spent more than the avg payment but would be nicer if it was just a list of their names. How would I do that?


