use sakila;
-- 1- How many copies of the film Hunchback Impossible exist in the inventory system?
select f.title, count(i.film_id)
from inventory i
left join film f
on i.film_id = f.film_id
where f.title = 'Hunchback Impossible'
;

-- 2- List all films whose length is longer than the average of all the films.
with cte1 as(select avg(length) as avg_length
from film)
select film_id
from film
where film.length>(select * from cte1);

-- 3- Use subqueries to display all actors who appear in the film Alone Trip.
select actor_id 
from film_actor
where film_id in (select film_id 
from film
where title = 'Alone Trip');

-- 4-  Identify all movies categorized as family films.
select *
from film_category
where category_id = (select category_id 
from category
where name ='Family');

-- 5 - Get name and email from customers from Canada using subqueries. 
select c.first_name, c.last_name, c.email, c.address_id, a.city_id, cc.country_id
from customer c
left join address a
on c.address_id = a.address_id
left join city cc
on a.city_id = cc.city_id
where cc.country_id = (select country_id
from country
where country = 'Canada');
-- I used both, is it ok? or should i answer it in two different ways?

-- 6- Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.
select actor_id, film_id
from film_actor
where actor_id = (select p.actor_id
from(
select actor_id, count(actor_id), rank() over(order by count(actor_id) desc) as ranking
from film_actor
group by actor_id) p
where p.ranking = 1);

-- 7- Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments
-- most profitable customer
select cp.customer_id
from(
select c.customer_id, sum(p.amount), rank() over (order by sum(p.amount) desc) ranking
from customer c
left join payment p
on c.customer_id = p.customer_id
group by c.customer_id) cp
where cp.ranking = 1;
-- inventory id from the rentals of the most profitable customer
select inventory_id 
from rental
where customer_id = (select cp.customer_id
from(
select c.customer_id, sum(p.amount), rank() over (order by sum(p.amount) desc) ranking
from customer c
left join payment p
on c.customer_id = p.customer_id
group by c.customer_id) cp
where cp.ranking = 1)
;
-- films corresponding to each inventory_id
select distinct i.film_id 
from inventory i
where i.inventory_id in (select inventory_id 
from rental
where customer_id = (select cp.customer_id
from(
select c.customer_id, sum(p.amount), rank() over (order by sum(p.amount) desc) ranking
from customer c
left join payment p
on c.customer_id = p.customer_id
group by c.customer_id) cp
where cp.ranking = 1));

-- 8- Customers who spent more than the average payments.
select avg(cp.cust_spend)
from(
select c.customer_id, sum(p.amount) as cust_spend
from customer c
left join payment p
on c.customer_id = p.customer_id
group by c.customer_id) cp
;
select pp.customer_id, sum(pp.amount) as cust_spend
from payment pp 
group by pp.customer_id
having cust_spend > (select avg(cp.cust_spend)
from(
select c.customer_id, sum(p.amount) as cust_spend
from customer c
left join payment p
on c.customer_id = p.customer_id
group by c.customer_id) cp)