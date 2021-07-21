-- 1- How many copies of the film Hunchback Impossible exist in the inventory system?
use sakila;

select count(inventory_id)
from inventory i
join film f
on i.film_id=f.film_id
where title = 'Hunchback Impossible';


-- 2- List all films whose length is longer than the average of all the films.
select *
from film
where length > (select avg(length) from film);


-- 3- Use subqueries to display all actors who appear in the film Alone Trip.
select actor_id
from film_actor
where film_id = (select film_id 
from film
where title='Alone Trip');


-- 4- Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
select film_id
from film_category
where category_id = (select category_id from category where name = 'Family');

-- 5 - Get name and email from customers from Canada using subqueries. Do the same with joins. Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.
select first_name, last_name, email 
from customer
where address_id in (select address_id
from address
where city_id in (select city_id 
from city
where country_id in (select country_id
from country 
where country ='Canada')));

select first_name, last_name, email 
from customer cu
join address a 
on cu.address_id = a.address_id
join city ci
on a.city_id=ci.city_id
join country co
on ci.country_id= co.country_id
where country='Canada';

-- 6- Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. 
-- First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.
select film_id
from film_actor
where actor_id =(select actor_id
from film_actor
group by actor_id
order by count(film_id) desc
limit 1);


-- 7- Films rented by most profitable customer. 
-- You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments
select film_id 
from inventory i
join rental r
on r.inventory_id=i.inventory_id
where r.customer_id =
(select customer_id
from payment
group by customer_id
order by sum(amount) desc
limit 1);

-- 8- Customers who spent more than the average payments.
select customer_id 
from payment
where amount >
(select avg(amount) from payment)
group by customer_id;
