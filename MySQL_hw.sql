USE sakila;

# 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name FROM actor;
    
# 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
ALTER TABLE actor
ADD `Actor Name` VARCHAR(50);

UPDATE actor 
SET `Actor Name` = CONCAT(first_name, ' ', last_name);
    
# 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
SELECT 
    actor_id, first_name, last_name
FROM
    actor
WHERE
    first_name = 'Joe';
    
# 2b. Find all actors whose last name contain the letters GEN:
SELECT 
    actor_id, first_name, last_name
FROM
    actor
WHERE
    last_name LIKE '%gen%';

# 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT 
    actor_id, first_name, last_name
FROM
    actor
WHERE
    last_name LIKE '%li%'
ORDER BY last_name, first_name;

# 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT
	country_id, country
FROM
	country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

# 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
ALTER TABLE
	actor
ADD middle_name VARCHAR(50)
AFTER first_name;

# 3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.
ALTER TABLE
	actor
MODIFY COLUMN
	middle_name BLOB;

# 3c. Now delete the middle_name column.
ALTER TABLE
	actor
DROP COLUMN
	middle_name;
    
# 4a. List the last names of actors, as well as how many actors have that last name.
SELECT
	last_name AS `Last name`,
    COUNT(last_name) AS `Actors w last name`
FROM
	actor
GROUP BY 
	last_name;
    
# 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT
	last_name AS `Last name`,
    COUNT(last_name) AS `Actors w last name`
FROM
	actor
GROUP BY 
	last_name
HAVING
	COUNT(last_name) > 1;

# 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE
	actor
SET
	first_name = "HARPO"
WHERE
	first_name = "GROUCHO" AND last_name = "WILLIAMS";
    
# 4d. In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error.
UPDATE actor 
   SET first_name = CASE WHEN first_name = 'Groucho' THEN 'Mucho Groucho' ELSE first_name END,
       first_name = CASE WHEN first_name = 'Harpo' THEN 'Groucho' ELSE first_name END
WHERE (first_name = 'Groucho' AND last_name = 'Williams') 
   OR (first_name = 'Harpo' AND last_name = 'Williams');

# 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE actor;

# 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT
	s.first_name, s.last_name, a.address
FROM
	staff s
INNER JOIN
	address a
ON
	s.address_id = a.address_id;

# 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT
	s.first_name, s.last_name, p.Total
FROM
	staff s
INNER JOIN
	(SELECT
		staff_id, SUM(amount) as Total
	FROM
		payment
	WHERE
		payment_date LIKE "2005-08%"
	GROUP BY
		staff_id) p
ON
	s.staff_id = p.staff_id;

# 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT
	f.title as `Film`, fa.`# actors`
FROM
	film f
INNER JOIN
	(SELECT
		film_id, COUNT(actor_id) AS `# actors`
	FROM
		film_actor
    GROUP BY
		film_id) fa
ON
	f.film_id = fa.film_id;

# 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT
	f.title `Film`, i.`Copies`
FROM
	film f
INNER JOIN (
	SELECT film_id, COUNT(film_id) AS `Copies`
    FROM inventory
    GROUP BY film_id
    ) i
ON f.film_id = i.film_id
WHERE f.title = "Hunchback Impossible";

# 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name
SELECT
	c.first_name, c.last_name, p.Total
FROM
	customer c
INNER JOIN (
	SELECT customer_id, SUM(amount) as Total
    FROM payment
    GROUP BY customer_id) p
ON
	c.customer_id = p.customer_id
ORDER BY last_name;

# 7a. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT f.title
FROM film f
INNER JOIN (
	SELECT language_id
    FROM language
    WHERE name = "English") l
ON
	f.language_id = l.language_id
WHERE
	f.title LIKE "K%" OR f.title LIKE "Q%";

# 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name, title
FROM actor a
INNER JOIN (
	SELECT fa.actor_id, title
	FROM film_actor fa
	INNER JOIN (
		SELECT film_id, title
		FROM film
		WHERE title = "Alone Trip") f
	ON fa.film_id = f.film_id) fa
ON a.actor_id = fa.actor_id;
		
# 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT first_name, last_name, email, co.country
FROM
	customer cu
	JOIN (SELECT address_id, city_id FROM address) a ON cu.address_id = a.address_id
	JOIN (SELECT city_id, country_id FROM city) ci ON a.city_id = ci.city_id
	JOIN (SELECT country_id, country FROM country) co ON ci.country_id = co.country_id
WHERE co.country = "Canada";

# 7d. Identify all movies categorized as famiy films.
SELECT f.title, c.name
FROM
	film f
    JOIN (SELECT film_id, category_id FROM film_category) fc ON f.film_id = fc.film_id
    JOIN (SELECT category_id, name FROM category) c ON fc.category_id = c.category_id
WHERE c.name = "Family";

# 7e. Display the most frequently rented movies in descending order.
SELECT f.title Title, r.`Total rentals`
FROM
	film f
    JOIN (SELECT film_id, inventory_id FROM inventory GROUP BY film_id) i ON f.film_id = i.film_id
    JOIN (SELECT inventory_id, COUNT(inventory_ID) AS `Total rentals` FROM rental GROUP BY inventory_id) r ON r.inventory_id = i.inventory_id
ORDER BY r.`Total rentals` DESC, f.title;

# 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id Store, p.`Total sales`
FROM
	staff s
	INNER JOIN (SELECT staff_id, SUM(amount) `Total sales` FROM payment GROUP BY staff_id) p ON p.staff_id = s.staff_id;

# 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id Store, ci.city City, co.country Country
FROM 
	store s
    LEFT JOIN (SELECT address_id, city_id FROM address) a ON a.address_id = s.address_id
    LEFT JOIN (SELECT city, city_id, country_id FROM city) ci ON ci.city_id = a.address_id
    LEFT JOIN (SELECT country, country_id FROM country) co ON co.country_id = ci.city_id;

# 7h. List the top five genres in gross revenue in descending order. 
SELECT c.name Genre, SUM(p.amount) `Gross revenue`
FROM
	category c
    JOIN (SELECT category_id, film_id FROM film_category) f ON c.category_id = f.category_id
    JOIN (SELECT film_id, inventory_id FROM inventory) i ON f.film_id = i.film_id
    JOIN (SELECT inventory_id, rental_id FROM rental) r ON i.inventory_id = r.inventory_id
    JOIN (SELECT rental_id, amount FROM payment GROUP BY rental_id) p ON r.rental_id = p.rental_id
GROUP BY c.name
ORDER BY SUM(p.amount) DESC
LIMIT 5;

# 8a. Use the solution from the problem above to create a view.
CREATE VIEW Top5GrossingGenres AS
	SELECT c.name Genre, SUM(p.amount) `Gross revenue`
	FROM
		category c
		JOIN (SELECT category_id, film_id FROM film_category) f ON c.category_id = f.category_id
		JOIN (SELECT film_id, inventory_id FROM inventory) i ON f.film_id = i.film_id
		JOIN (SELECT inventory_id, rental_id FROM rental) r ON i.inventory_id = r.inventory_id
		JOIN (SELECT rental_id, amount FROM payment GROUP BY rental_id) p ON r.rental_id = p.rental_id
	GROUP BY c.name
	ORDER BY SUM(p.amount) DESC
	LIMIT 5;

# 8b. Display view from 8a
SELECT * FROM Top5GrossingGenres;

# 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW Top5GrossingGenres;