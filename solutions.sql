use sakila;
-- 1- How many copies of the film Hunchback Impossible exist in the inventory system?
select f.title, count(i.inventory_id) exists_in_i
from inventory i
join film f
	on i.film_id = f.film_id
group by f.title
having f.title = 'Hunchback Impossible';

-- 2- List all films whose length is longer than the average of all the films.
select title from film
where length > (
	select avg(length) from film
);

-- 3- Use subqueries to display all actors who appear in the film Alone Trip.
select a.first_name, a.last_name
from film_actor fa
join actor a
	on fa.actor_id = a.actor_id
where fa.film_id = (
	select film_id
	from film
	where title = 'Alone Trip'
);

-- 4- Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
select f.title
from film f
join film_category fc
on f.film_id = fc.film_id
where fc.category_id = (
	select category_id 
	from category
	where name = 'Family'
);

-- 5 - Get name and email from customers from Canada using subqueries. Do the same with joins. Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.

-- subquerie version
select email
from customer
where address_id in (
	select address_id
	from address
	where city_id in ( 
		select city_id
		from city
		join country c
			on city.country_id = c.country_id
		where c.country = 'Canada'
	)
);

-- join version
select c.email
from customer c
join address a
	on c.address_id = a.address_id
join city ci
	on a.city_id = ci.city_id
join country co
	on ci.country_id = co.country_id
where co.country = 'Canada';
 
-- 6- Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.
select f.title 
from film f
join film_actor fa
	on f.film_id = fa.film_id 
where fa.actor_id in (
	select actor_id from(
		select actor_id, rank() over (order by films) ranks
		from(
			select actor_id, count(film_id) as films
			from film_actor
			group by actor_id) t1
		) t2
	where ranks = 1
);

-- 7- Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments
select f.title
from film f
join inventory i
	on f.film_id = i.film_id
join rental r
	on i.inventory_id = r.inventory_id
where r.customer_id = (
	select customer_id from(
		select customer_id, rank() over(order by pay desc) ranking
		from (
			select customer_id, sum(amount) pay
			from payment
			group by customer_id) t1
		) t2
	where ranking = 1
); 

-- 8- Customers who spent more than the average payments.
select first_name, last_name
from customer
where customer_id in (
	select customer_id
	from(
		select customer_id, sum(amount) as sum_pay
		from payment
		group by customer_id) t1
	where sum_pay > (
		select avg(sum_pay) 
		from(
			select customer_id, sum(amount) as sum_pay
			from payment
			group by customer_id
		) t1
	)
);