require "rake"
require_relative "../rails_routes_to_openapi"

namespace :routes_to_openapi do
  desc "Convert Rails routes to OpenAPI YAML"
  task :convert do
    routes_output = IO.popen("rails routes") { |io| io.read }

    # Check if the output contains expected routes information
    if routes_output.include?("Usage:") || routes_output.strip.empty?
      puts "Failed to retrieve routes. Please ensure you are running this task within a Rails project."
      exit 1
    end

    begin
      file_name = RailsRoutesToOpenAPI.convert(routes_output)
      puts "OpenAPI v3 YAML file generated successfully: #{file_name}"
    rescue => e
      puts "Failed to generate OpenAPI YAML file."
      puts e.message
    end
  end
end