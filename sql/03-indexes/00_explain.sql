-- M4 lesson 4.1 — read EXPLAIN before trusting the query plan.
EXPLAIN ANALYZE
SELECT customer_id, COUNT(*)
FROM rental
WHERE rental_date >= '2026-01-01'
GROUP BY customer_id
HAVING COUNT(*) > 5;
