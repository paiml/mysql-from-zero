//! Top-customers-by-rental-count Sakila demo (Coursera MySQL from Zero, M5).
//!
//! Walks the same problem as the Duke `mysql-to-python-webserver` recording:
//! join `customer` against `rental`, count rentals per customer, return the
//! top 10. The Bash and Python lessons in M1 surface this same answer via
//! `mysql -e ...` and a `http.server` script — this example closes the loop
//! by porting the identical query into typed Rust via `sqlx::MySqlPool`.
//!
//! Workspace-artifact equivalent: `sql/02-queries/01_joins.sql` — the SQL
//! module 3 lesson runs the same `LEFT JOIN ... GROUP BY ... ORDER BY` shape
//! at the `mysql` CLI. This Rust binary returns the same row set, mapped
//! through a `#[derive(FromRow)]` struct and serialized as JSON on stdout.
//!
//! Run:  cargo run -p mysql-rust --example top_customers_sqlx

use anyhow::{Context, Result};
use serde::Serialize;
use sqlx::mysql::MySqlPoolOptions;
use sqlx::FromRow;

/// One row of the top-customers query — the typed shape the Rust client
/// sees when the same JOIN that the Bash + Python lessons run lands here.
#[derive(Debug, Serialize, FromRow)]
struct TopCustomer {
    customer_id: u16,
    first_name: String,
    last_name: String,
    rental_count: i64,
}

const TOP_CUSTOMERS_SQL: &str = "
    SELECT c.customer_id, c.first_name, c.last_name, COUNT(r.rental_id) AS rental_count
    FROM customer c
    LEFT JOIN rental r ON r.customer_id = c.customer_id
    GROUP BY c.customer_id
    ORDER BY rental_count DESC
    LIMIT 10
";

#[tokio::main]
async fn main() -> Result<()> {
    let url = std::env::var("MYSQL_URL")
        .unwrap_or_else(|_| "mysql://app:appdev@127.0.0.1:3306/sakila".to_string());

    // Small pool — single-shot read, no need for more than two connections.
    let pool = MySqlPoolOptions::new()
        .max_connections(2)
        .connect(&url)
        .await
        .with_context(|| format!("failed to connect to MySQL at {url}"))?;

    // Runtime `query_as` (NOT the `query_as!` macro) so the example builds
    // without a live DATABASE_URL at compile time. The lesson video calls
    // this out — ship the binary, run it against any Sakila that's up.
    let rows: Vec<TopCustomer> = sqlx::query_as::<_, TopCustomer>(TOP_CUSTOMERS_SQL)
        .fetch_all(&pool)
        .await
        .context("top-customers query failed")?;

    // Serialize the typed rows as JSON on stdout — same answer as the
    // Python `http.server` lesson, just in Rust and ready to pipe.
    let json = serde_json::to_string_pretty(&rows).context("failed to serialize rows as JSON")?;
    println!("{json}");

    // Provable contract — the demo is honest only if the data we get back
    // matches what the lesson teaches. If Sakila drifts (re-imported with
    // a different shape, customer table truncated, etc.), this fails loud.
    assert!(
        rows.len() == 10,
        "Top-customers contract: query must return exactly 10 rows. \
         Got {}. Re-import Sakila or adjust the LIMIT.",
        rows.len()
    );
    let top = rows.first().expect("rows.len() == 10 was just asserted");
    assert!(
        top.rental_count >= 1,
        "Top-customers contract: #1 customer must have ≥1 rental. \
         Got rental_count={} for customer_id={}.",
        top.rental_count,
        top.customer_id
    );
    assert!(
        top.customer_id > 0,
        "Top-customers contract: customer_id must be positive. \
         Got customer_id={}.",
        top.customer_id
    );
    // Sort invariant — the ORDER BY must actually order. Catches the case
    // where someone edits the SQL and forgets the DESC.
    let counts: Vec<i64> = rows.iter().map(|r| r.rental_count).collect();
    let mut sorted = counts.clone();
    sorted.sort_by(|a, b| b.cmp(a));
    assert!(
        counts == sorted,
        "Top-customers contract: rows must be sorted by rental_count DESC. \
         Got {counts:?}."
    );

    pool.close().await;
    Ok(())
}
