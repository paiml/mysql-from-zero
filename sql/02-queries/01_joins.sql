-- M2 lesson: LEFT JOIN customer -> rental, top renters.
-- This is the same query as TOP_CUSTOMERS_SQL in
-- crates/mysql-rust/examples/top_customers_sqlx.rs. The example keeps its SQL
-- in that Rust constant and never reads this file; keep the two identical.
SELECT c.customer_id, c.first_name, c.last_name, COUNT(r.rental_id) AS rental_count
FROM customer c
LEFT JOIN rental r ON r.customer_id = c.customer_id
GROUP BY c.customer_id
ORDER BY rental_count DESC
LIMIT 10;
