require "yaml"
require_relative "rails_routes_to_openapi/util/file_helpers"
require_relative "rails_routes_to_openapi/util/open_api_helpers"

module RailsRoutesToOpenAPI
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

  def self.convert(routes_output)
    route_info = Util::FileHelpers.parse(routes_output)
    yaml_format = Util::OpenAPIHelpers.convert(route_info).to_hash.deep_stringify_keys.to_yaml
    timestamp = Time.now.strftime("%Y%m%d%H%M%S")
    output_file = "openapi_v3.1_#{timestamp}.yml"

    File.open(output_file, "w") { |file| file.write(yaml_format) }
  end
end

# Load Rake tasks if Rails is defined
if defined?(Rails)
  Dir[File.join(__dir__, 'tasks/**/*.rake')].each { |ext| load ext }
end