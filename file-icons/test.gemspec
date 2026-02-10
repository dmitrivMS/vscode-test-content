Gem::Specification.new do |spec|
  spec.name          = "http_client"
  spec.version       = "2.1.0"
  spec.authors       = ["Jane Developer"]
  spec.email         = ["jane@example.com"]

  spec.summary       = "A lightweight HTTP client with retry support"
  spec.description   = "Provides a simple interface for making HTTP requests with automatic retries, timeouts, and connection pooling."
  spec.homepage      = "https://github.com/example/http_client"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.files         = Dir["lib/**/*.rb", "LICENSE", "README.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "net-http", "~> 0.4"
  spec.add_dependency "json", "~> 2.7"

  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "webmock", "~> 3.19"
  spec.add_development_dependency "rubocop", "~> 1.57"
end
