use chrono::NaiveDate;
use crate::schema::pcr_count;

#[derive(Debug, Queryable, QueryableByName)]
#[table_name = "pcr_count"]
pub struct PcrCount {
    pub id: i32,
    pub date: NaiveDate,
    pub count: i32,
}
