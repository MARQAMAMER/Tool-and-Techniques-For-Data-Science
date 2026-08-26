SELECT * FROM sakila.film;

-- Write a query to display all films that have a rating of PG and a rental duration greater than 5 days
SELECT film_id, title, rating, rental_duration
FROM sakila.film
WHERE rating = 'PG'
  AND rental_duration > 5;
  
-- Write a query to find the total number of films released in the year 2006.
SELECT COUNT(*) AS total_films_2006
FROM sakila.film
WHERE release_year = 2006;

-- Write a query to display the average rental rate of films, grouped by their rating.
SELECT rating, 
       AVG(rental_rate) AS avg_rental_rate
FROM sakila.film
GROUP BY rating;

-- Write a query to list the top 5 longest films (based on length) sorted in descending order.
SELECT film_id, title, length
FROM sakila.film
ORDER BY length DESC
LIMIT 5;


-- Write a query to count the total number of films in each language.
SELECT l.name AS language,
       COUNT(f.film_id) AS total_films
FROM sakila.film f
JOIN sakila.language l 
     ON f.language_id = l.language_id
GROUP BY l.name
ORDER BY total_films DESC;

----------------------------------------------------------------------------------
-- Write a query to assign a row number to each film ordered by its rental rate in descending order.
SELECT film_id, title, rental_rate,
       ROW_NUMBER() OVER (ORDER BY rental_rate DESC) AS row_num
FROM sakila.film;

-- Write a query to rank actors based on the total number of films they acted in.
SELECT a.actor_id, a.first_name, a.last_name,
       COUNT(fa.film_id) AS total_films,
       RANK() OVER (ORDER BY COUNT(fa.film_id) DESC) AS actor_rank
FROM sakila.actor a
JOIN sakila.film_actor fa ON a.actor_id = fa.actor_id
GROUP BY a.actor_id, a.first_name, a.last_name;

-- Write a query to calculate the cumulative total rentals per customer.
SELECT r.customer_id,
       r.rental_date,
       COUNT(r.rental_id) OVER (PARTITION BY r.customer_id ORDER BY r.rental_date) AS cumulative_rentals
FROM sakila.rental r;

-- Write a query to display each film’s title along with its rental rate and the average rental rate of all films.
SELECT title, rental_rate,
       (SELECT AVG(rental_rate) FROM sakila.film) AS avg_rental_rate
FROM sakila.film;

-- Rank customers in each store by the total rentals they made, using DENSE RANK().
SELECT c.store_id, c.customer_id, c.first_name, c.last_name,
       COUNT(r.rental_id) AS total_rentals,
       DENSE_RANK() OVER (PARTITION BY c.store_id ORDER BY COUNT(r.rental_id) DESC) AS customer_rank
FROM sakila.customer c
JOIN sakila.rental r ON c.customer_id = r.customer_id
GROUP BY c.store_id, c.customer_id, c.first_name, c.last_name;

---------------------------------------------------------------------------------
-- Write a query to display each film’s title and the corresponding category name.
SELECT f.title, c.name AS category
FROM sakila.film f
JOIN sakila.film_category fc ON f.film_id = fc.film_id
JOIN sakila.category c ON fc.category_id = c.category_id;

-- Display all films and their associated actors.
SELECT f.title, a.first_name, a.last_name
FROM sakila.film f
JOIN sakila.film_actor fa ON f.film_id = fa.film_id
JOIN sakila.actor a ON fa.actor_id = a.actor_id
ORDER BY f.title;

-- List the customers’ names and the store they belong to.
SELECT c.first_name, c.last_name, s.store_id
FROM sakila.customer c
JOIN sakila.store s ON c.store_id = s.store_id
ORDER BY s.store_id, c.last_name;


-- Display rental details (rental date, film title, and customer name).
SELECT r.rental_date, f.title, c.first_name, c.last_name
FROM sakila.rental r
JOIN sakila.inventory i ON r.inventory_id = i.inventory_id
JOIN sakila.film f ON i.film_id = f.film_id
JOIN sakila.customer c ON r.customer_id = c.customer_id
ORDER BY r.rental_date;


-- Display the payment amount, payment date, and the staff member who processed each payment.
SELECT p.amount, p.payment_date, s.first_name, s.last_name
FROM sakila.payment p
JOIN sakila.staff s ON p.staff_id = s.staff_id
ORDER BY p.payment_date;

------------------------------------------------------------------------------
-- Update the rental rate of all films with rating G by increasing it by 0.50.


-- Delete all customers who have never made a rental.


-- Create a view called TopCustomers showing customers and their total payment amounts in descending order.


-- Find the films that are not rented.


-- Display the top 3 categories with the highest number of films.









