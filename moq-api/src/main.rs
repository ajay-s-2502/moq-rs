use clap::Parser;

mod server;
use moq_api::ApiError;
use server::{Server, ServerConfig};
use env_logger::{Builder, fmt::TimestampPrecision};

fn init_logger() {
    let mut builder = Builder::from_default_env();
    builder
        .format_timestamp(Some(TimestampPrecision::Micros))
        .init();
}

#[tokio::main]
async fn main() -> Result<(), ApiError> {
	init_logger();

	let config = ServerConfig::parse();
	let server = Server::new(config);
	server.run().await
}
