require "deep_merge"
require_relative "../structs/open_api"

module Util
  class OpenAPIHelpers
    class << self
      # Takes an array of RouteInfo types and generates the OpenAPI v3 spec
      # to write into YAML and export to a file.
      def convert(route_info)
        param_friendly_route_info = convert_params_to_compatible_format(route_info)
        paths_hash = write_paths_hash(param_friendly_route_info)
        write_open_api_compliant_hash(paths_hash)
      end

      def convert_params_to_compatible_format(route_info)
        route_info.map { |info|
          # Remove (.:format) from uri_pattern
          update_string = info.uri_pattern.gsub(/\(\.:format\)/, '')
          
          # Turn something like /a/b/:param/d to /a/b/{param} for OpenAPI standards
          update_string = update_string.split("/").map { |uri|
            uri[0] == ":" ? "{#{uri[1..]}}" : uri
          }.join("/")

          Structs::RouteInfo.new(verb: info.verb, controller_action: info.controller_action, uri_pattern: update_string)
        }
      rescue
        raise 'Could not convert params from :param to {param} format'
      end

      # ! To be honest, I feel like all of this should be cleaned up.
      # Even if it is just that I need a better formatter to make it read easier.
      # I feel like the following four methods are a bit wtf really.
      def get_request_body_schema
        {type: "object", properties: {id: {type: "string", format: "string"}}}
      end

      def get_verb_with_req_body(info)
        Structs::OpenAPI::VerbWithRequestBody.new(summary: info.controller_action, requestBody: {required: true, content: {"application/json": {schema: get_request_body_schema}}}).attributes
      end

      def get_verb(info)
        Structs::OpenAPI::Verb.new(summary: info.controller_action).attributes
      end

      def write_paths_hash(route_info)
        paths_hash = {}
        route_info.each do |info|
          # Simplify the GET part - assume all other REST verbs require a request body
          if info.verb == "GET"
            paths_hash.deep_merge!({info.uri_pattern => {info.verb.downcase => get_verb(info)}})
          else
            paths_hash.deep_merge!({info.uri_pattern => {info.verb.downcase => get_verb_with_req_body(info)}})
          end
        end
        paths_hash
      rescue
        raise 'Could not write paths for hash'
      end

      def write_open_api_compliant_hash(paths_hash)
        info = {
          title: "Rails Routes to OpenAPI",
          description: "Generate an OpenAPI v3.1 YAML file for Postman import",
          version: "1.1.0",
        }
        servers = [{url: "https://api.example.com", description: "Base URL for the API"}]

        # This ends up the final hash to write to disk.
        Structs::OpenAPI::Base.new(openapi: "3.1.0", info: info, servers: servers, paths: paths_hash).attributes
      rescue
        raise 'Could not write OpenAPI compliant hash'
      end
    end
  end
end
