-- M3 lesson 3.2 — INNER and LEFT joins on Sakila.
SELECT c.first_name, c.last_name, COUNT(r.rental_id) AS rental_count
FROM customer c
LEFT JOIN rental r ON r.customer_id = c.customer_id
GROUP BY c.customer_id
ORDER BY rental_count DESC
LIMIT 20;
