# Project README

A high-performance HTTP server written in Rust.

## Features

- **Async I/O** — Built on Tokio for non-blocking request handling
- **Middleware** — Composable middleware pipeline
- **Routing** — Pattern-based URL routing with parameter extraction
- **TLS** — Native TLS support via rustls

## Quick Start

```rust
use myserver::App;

#[tokio::main]
async fn main() {
    let app = App::new()
        .get("/", |_req| "Hello, world!")
        .listen("0.0.0.0:3000")
        .await;
}
```

## Benchmarks

| Metric        | Value       |
|---------------|-------------|
| Requests/sec  | 142,000     |
| Latency (p99) | 2.3ms       |
| Memory usage  | 12MB idle   |

## License

MIT
