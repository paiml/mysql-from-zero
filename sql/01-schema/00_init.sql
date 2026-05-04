-- Run on first container start. Real Sakila import comes via:
--   mysql -uapp -pappdev sakila < sakila/sakila-schema.sql
-- This file just establishes a placeholder so the database boots cleanly.
USE sakila;
CREATE TABLE IF NOT EXISTS course_smoke (
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    note VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO course_smoke (note) VALUES ('mysql-from-zero booted');
