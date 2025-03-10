Gem::Specification.new do |spec|
  spec.name          = "rails_routes_to_openapi"
  spec.version       = "0.1.4"
  spec.authors       = ["Camel Chang"]
  spec.email         = ["a556622821@gmail.com"]
  spec.summary       = "Convert Rails routes to OpenAPI YAML"
  spec.description   = "A gem to convert Rails routes to OpenAPI v3.1 YAML"
  spec.homepage      = "https://github.com/camel2243/rails-gen-openapi"
  spec.license       = "Apache-2.0"
  spec.metadata      = {
    "source_code_uri" => "https://github.com/camel2243/rails-gen-openapi",
    "homepage_uri"    => "https://github.com/camel2243/rails-gen-openapi",
    "documentation_uri" => "https://github.com/camel2243/rails-gen-openapi/blob/main/README.md"
  }

  spec.files         = Dir["lib/**/*", "Rakefile", "README.md"]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "dry-types"
  spec.add_dependency "dry-struct"
  spec.add_dependency "yaml"
  spec.add_dependency "deep_merge"

  spec.files         += Dir["lib/tasks/**/*.rake"]
end