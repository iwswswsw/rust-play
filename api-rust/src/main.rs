extern crate api_rust;
extern crate diesel;

use actix_web::{get, web, App, HttpResponse, HttpServer, Responder};
use self::api_rust::*;
use self::models::*;
use self::diesel::prelude::*;
use diesel::sql_types::Integer;
use diesel::sql_query;
use chrono::Datelike;

const MONTHS: usize = 12;

#[derive(Debug)]
struct MonthlyCount {
    month: usize,
    count: i32,
}

#[get("/")]
async fn welcome() -> impl Responder {
    HttpResponse::Ok().body("Welcome! Please access '/[id]' or '/counts/[year]'!")
}

#[get("/{target_id}")]
async fn get_record(target_id: web::Path<i32>) -> impl Responder {
    use api_rust::schema::pcr_count::dsl::*;
    
    println!("target_id: {}", target_id);

    let target_id = target_id.into_inner();
    
    let connection = establish_connection();
    let result = pcr_count
        .filter(id.eq(target_id))
        .load::<PcrCount>(&connection)
        .expect("Error loading pcr_count");
    
    format!("{}: {}", result[0].date, result[0].count)
}

#[get("/counts/{year}")]
async fn get_monthly_counts(year: web::Path<i32>) -> impl Responder {
    println!("year: {}", year);

    let year = year.into_inner();
    
    // postgresに接続しyearでデータを取得
    let connection = establish_connection();
    let results: Vec<PcrCount> = sql_query("SELECT * FROM pcr_count WHERE EXTRACT(YEAR FROM date) = $1 ")
        .bind::<Integer, _>(year)
        .load(&connection)
        .unwrap();
    
    println!("Displaying {} pcr_count", results.len());
    // println!("{:?}", results);
    
    // TODO: 月ごとにcountを集計して返す
    let mut monthly_counts: Vec<MonthlyCount> = Vec::with_capacity(MONTHS);
    for m in 1..MONTHS {
        let m_u32: u32 = m as u32;
        let count = results.iter().filter(|r| r.date.month()==m_u32).map(|r| r.count).collect::<Vec<i32>>().iter().sum();
        monthly_counts.push(MonthlyCount { month: m, count: count });
    }
    
    for c in &monthly_counts {
        println!("{}, {}", c.month, c.count);
    }
    
    let response = monthly_counts.iter().map(|m| m.month.to_string()+", "+&m.count.to_string()).collect::<Vec<String>>().join("\n");
    
    format!("{}", response)
}

#[actix_web::main] // or #[tokio::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| {
        App::new()
            .service(welcome)
            .service(get_record)
            .service(get_monthly_counts)
    })
    .bind(("0.0.0.0", 8080))?
    .run()
    .await
}
