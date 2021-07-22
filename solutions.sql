Use sakila;

-- 1- How many copies of the film Hunchback Impossible exist in the inventory system?
select count(film_id) as nb_copies
from (
select i.inventory_id, i.film_id, f.title from inventory i
left join film f
on i.film_id = f.film_id
where title = 'Hunchback Impossible') as d;

-- 2- List all films whose length is longer than the average of all the films.
select film_id, title, length
from film
where length > (select avg(length) from film);

-- 3- Use subqueries to display all actors who appear in the film Alone Trip.
select actor_id, title
from (
select a.actor_id, a.film_id, f.title
from film_actor a
left join film f 
on a.film_id = f.film_id) z
where title = 'Alone Trip';

-- 4- Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
select film_id, name
from (
select fc.film_id, c.name
from film_category fc
join category c
on fc.category_id = c.category_id) b
where name = 'Family';

-- 5 - Get name and email from customers from Canada using subqueries. Do the same with joins. Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.
select last_name, email
from customer
where address_id in(
	select address_id 
	from address
	where city_id in(
		select city_id 
		from city
		where country_id = (
			select country_id
			from country
			where country = 'canada')
));
select actor_id, rk
	from (
		select actor_id, count(film_id), rank() over(order by count(film_id) desc) as rk
		from film_actor
		group by actor_id) a
		where rk = 1;

-- 6- Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.
select actor_id, film_id
from film_actor
where aactor_id = (
	select actor_id, rk
	from (
		select actor_id, count(film_id), rank() over(order by count(film_id) desc) as rk
		from film_actor
		group by actor_id) a
		where rk = 1);

-- 7- Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments

-- 8- Customers who spent more than the average payments.