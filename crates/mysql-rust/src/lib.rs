//! Rust client examples for the **MySQL from Zero** course.
//!
//! Module 5 walks `sqlx::MySql` and `mysql_async` against the same Sakila
//! schema the rest of the course uses. The skeleton lands here; the real
//! examples ship with the lessons.

#[cfg(test)]
mod tests {
    #[test]
    fn smoke() {
        assert_eq!(2 + 2, 4);
    }
}
