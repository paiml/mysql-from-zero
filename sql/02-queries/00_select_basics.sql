-- M3 lesson 3.1 — SELECT, WHERE, ORDER BY, LIMIT.
SELECT id, note, created_at
FROM course_smoke
WHERE created_at >= NOW() - INTERVAL 7 DAY
ORDER BY created_at DESC
LIMIT 10;
