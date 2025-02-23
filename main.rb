#!/usr/bin/env ruby
require "slop"
require "dry/monads"
require "yaml"
require_relative "util/file_helpers"
require_relative "util/open_api_helpers"

include Dry::Monads[:result]

# Simple CLI Parsing
opts = Slop.parse { |o|
  o.string "-f", "--file", "routes file to read in"
  o.on "--version", "print the version" do
    puts Slop::VERSION
    exit
  end
}

class ::Hash
  def deep_stringify_keys
    each_with_object({}) do |(k, v), h|
      h[k.to_s] = case v
                  when Hash
                    v.deep_stringify_keys
                  when Array
                    v.map { |i| i.is_a?(Hash) ? i.deep_stringify_keys : i }
                  else
                    v
                  end
    end
  end
end

# Define handlers for Either Monad
handle_failure = lambda do |failure|
  # just write the failure to stdout for now
  puts failure
  exit 1
end

handle_success = lambda do |success|
  # ! I really detest this hack. There needs to be a better way.
  res = success.to_hash.deep_stringify_keys

  # Write OpenAPI output to YAML file
  # puts success
  File.open("temp.yml", "w") { |file| file.write(res.to_yaml) }
  exit 0
end

# Main
# ! This looks synchronous. How do you write file streams in Ruby instead of creating large memory buffers?
file_data = Util::FileHelpers.call(opts.to_hash[:file]).value_or(handle_failure)
yaml_format = Util::OpenAPIHelpers.call(file_data)

# Fold either handlers based on success or failure
yaml_format.either(handle_success, handle_failure)
