-- 1- How many copies of the film Hunchback Impossible exist in the inventory system?
-- select count(inventory_id)
-- from inventory i
-- join film f
-- on i.film_id = f.film_id
-- where f.title = 'Hunchback impossible';

-- 2- List all films whose length is longer than the average of all the films.
-- select film_id, title
-- from film
-- group by film_id
-- having avg(length) > (select avg(length) from film)
-- order by 1 desc;

-- 3- Use subqueries to display all actors who appear in the film Alone Trip.
-- select f.title, a.first_name, a.last_name  
-- from film f
-- join film_actor fa 
-- on f.film_id = fa.film_id
-- join actor a
-- on fa.actor_id = a.actor_id
-- where f.title = 'Alone Trip';

-- 4- Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
-- select f.title, c.name
-- from film f
-- join film_category fc
-- on f.film_id = fc.film_id
-- join category c 
-- on fc.category_id = c.category_id
-- where c.name = 'family';

-- 5 - Get name and email from customers from Canada using subqueries. Do the same with joins. Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.
-- select co.country, c.first_name, c.last_name , c.email
-- from customer c
-- join address a
-- on c.address_id = a.address_id
-- join city ci
-- on a.city_id = ci.city_id
-- join country co
-- on ci.country_id = co.country_id
-- where co.country = 'Canada'; 


-- 6- Which are films starred by the most prolific actor? Most prolific actor is defined as the actor
-- that has acted in the most number of films. First you will have to find the most prolific actor and then use that actor_id 
-- to find the different films that he/she starred.

select * from (
select actor_id, count(film_id), rank() over(partition by actor_id order by count(film_id) desc) as soph
from film_actor
group by actor_id) fa
join actor a
on fa.actor_id = a.actor_id
where soph = 1;


-- 7- Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable 
-- customer ie the customer that has made the largest sum of payments

-- select * from (
-- select customer_id, sum(amount), rank() over(partition by customer_id order by sum(amount) desc) as soph
-- from payment
-- group by customer_id) p
-- join customer c
-- on p.customer_id = c.customer_id
-- join inventory i
-- on c.store_id = i.inventory_id
-- join film f
-- on i.film_id = f.film_id
-- where soph = 1;


-- 8- Customers who spent more than the average payments.
-- select customer_id
-- from payment
-- group by customer_id
-- having avg(amount) > (select avg(amount) from payment)
-- order by 1 desc;