FROM rust:1.59-slim-buster

RUN apt update && \
    apt install -y libpq-dev

RUN cargo install cargo-watch
RUN cargo install diesel_cli --no-default-features --features postgres
