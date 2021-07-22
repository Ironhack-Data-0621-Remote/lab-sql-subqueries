-- 1- How many copies of the film Hunchback Impossible exist in the inventory system?
use sakila;
-- with joins & subquery:
select * from(select i.film_id, f.title, count(i.film_id) 
from inventory i
join film f
on i.film_id = f.film_id
group by i.film_id) a
where a.title like '%HUNCHBACK%';

-- 2- List all films whose length is longer than the average of all the films.

select title, length 
from film
where film.length > (select avg(film.length) from film);

-- 3- Use subqueries to display all actors who appear in the film Alone Trip.

select * from(select a.first_name, a.last_name, t.title
from film_actor i
join actor a
on i.actor_id = a.actor_id
join film t
on i.film_id = t.film_id) h
where h.title like '%ALONE%';

-- 4- Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.

-- only subquery:
select a.name as catgory, c.title
from category a
join film_category b
on a.category_id = b.category_id 
join film c
on b.film_id = c.film_id;

-- only titles in category family:
select * from(select a.name as category, c.title
from category a
join film_category b
on a.category_id = b.category_id 
join film c
on b.film_id = c.film_id) d
where category like '%F%';

-- 5 - Get name and email from customers from Canada using subqueries. Do the same with joins. Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.

select first_name, last_name, email
from customer a
where address_id in (select address_id
from address
where city_id in
(select city_id
from city b
join country c
on b.country_id = c.country_id
where c.country = 'Canada')
);

-- with joins:
select a.first_name, a.last_name, a.email
from customer a
join address b
on a.address_id = b.address_id
join city c
on c.city_id = b.city_id
join country d
on c.country_id = d.country_id
where d.country = "Canada";
-- 6- Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.

-- most profitable customer:
select actor_id, count(film_id) as nofilms, rank () over (order by count(film_id) desc) as ranka
from film_actor
group by actor_id;

select first_name, last_name, title
from film_actor fa
join film f
on f. film_id = fa.film_id
join actor a
on a.actor_id = fa.actor_id
where fa.actor_id in (select actor_id from(select actor_id, count(film_id) as nofilms, rank () over (order by count(film_id) desc) as ranka
from film_actor
group by actor_id) s
where ranka < 10);

-- 7- Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments
-- most profitable customer:
select customer_id, sum(amount) as sum_amount, rank () over (order by sum(amount) desc) as rankb
from payment
group by customer_id;

select f.title
from film f 
join inventory i
on f.film_id = i.film_id
join rental r
on r.inventory_id = i.inventory_id
where customer_id in
(select customer_id from
(select customer_id, sum(amount) as sum_amount, rank () over (order by sum(amount) desc) as rankb
from payment
group by customer_id) c
where rankb < 10);

-- 8- Customers who spent more than the average payments.
select c.first_name, c.last_name, avg(a.amount) as amount_avg
from payment a 
join customer c
on a.customer_id = c.customer_id
group by a.customer_id
having amount_avg > (select avg(amount) from payment);