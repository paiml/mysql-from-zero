# mysql-from-zero

[![License: MIT OR Apache-2.0](https://img.shields.io/badge/license-MIT%20OR%20Apache--2.0-blue.svg)](#license)
[![MSRV](https://img.shields.io/badge/MSRV-1.95-orange.svg)](rust-toolchain.toml)

Companion repo for the standalone Coursera course **MySQL from Zero**.

A from-scratch MySQL course aimed at data engineers — schema design,
indexing, query plans, replication, and a final module on connecting
from Rust via `sqlx` and `mysql_async`.

## What's in this repo

- `compose.yml` — local MySQL 8.4 node with general + slow-query logs on
- `sql/` — schema bootstrap, query examples, index demos
- `crates/mysql-rust/` — Rust workspace member showing typed access via sqlx

## Quick start

```bash
git clone https://github.com/paiml/mysql-from-zero
cd mysql-from-zero
make up        # docker compose up -d (MySQL 8.4 + empty `sakila` schema)
make sakila    # download + load Sakila schema and data into the container
make test      # cargo test --workspace
```

Run `make help` to see every target. `make sakila` is idempotent — once
`sakila-db/sakila-data.sql` exists locally, re-running just re-loads
the schema (useful if you `DROP DATABASE` and want a fresh seed).

## Quick start — `top_customers_sqlx` Rust demo

The `top_customers_sqlx` example closes the loop the Duke videos open: the M1
`bash-pipelines-with-mysql` lesson surfaces the top renters via `mysql -e ...`,
the `mysql-to-python-webserver` lesson serves the same answer from a Python
`http.server`, and this binary returns the identical row set through typed Rust
via `sqlx::MySqlPool`. Bring the database up first, then run the demo:

```bash
make up && make sakila        # MySQL container + Sakila loaded (one-time)
cargo run -p mysql-rust --example top_customers_sqlx
```

Sample output (top of the JSON array):

```json
[
  {
    "customer_id": 148,
    "first_name": "ELEANOR",
    "last_name": "HUNT",
    "rental_count": 46
  },
  ...
]
```

The demo expects the compose.yml-provided Sakila to be running on
`127.0.0.1:3306` with `user=app password=appdev db=sakila`. Override with
`MYSQL_URL=mysql://...` if your database lives elsewhere. Embedded runtime
`assert!` contracts fail loudly if the query returns fewer than 10 rows, the
top customer has 0 rentals, or the result is not sorted by rental count.

## Course outline

- **M1** — MySQL Foundations (install, CLI, Sakila import)
- **M2** — Schema Design and Data Types (PKs, FKs, normalization)
- **M3** — Querying (SELECT, JOIN, aggregates, window functions)
- **M4** — Indexes, EXPLAIN, and Performance (B-tree, plans, slow log)
- **M5** — Operations and the Rust Client (backups, replication, sqlx)

## License

Dual-licensed under either of

- [Apache License, Version 2.0](LICENSE-APACHE)
- [MIT License](LICENSE-MIT)

at your option.
