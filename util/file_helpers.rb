require "dry/monads"
require "dry/monads/do"
require_relative "../structs/rails_route_info"
module Util
  class FileHelpers
    class << self
      include Dry::Monads[:result]
      include Dry::Monads::Do.for(:call)

      # Takes file path and returns RouteInfo based on each line
      # for REST verb, uri_pattern and associated controller_action
      def call(file)
        file_data = yield read(file)
        split_file_data = yield split(file_data)
        filtered_file_data = yield filter_header(split_file_data)
        route_info = yield create_route_info(filtered_file_data)
        Success(route_info)
      end

      # Simply read the routes file and return data
      def read(file)
        filepath = File.join(File.dirname(__dir__), file)
        file = File.read(filepath)
        Success(file)
      rescue
        Failure("Failed to parse file")
      end

      # Returns string array for each line
      def split(file_content)
        file_lines = file_content.split(/\n/)
        Success(file_lines)
      rescue
        Failure("Failed to split file lines")
      end

      # Filter out the header line
      def filter_header(file_content_array)
        # Assuming the first line is the header
        Success(file_content_array.drop(1))
      rescue
        Failure("Failed to filter header line")
      end

      # Accepts string array from file line
      def create_route_info(file_data)
        # Use regex to split each line into prefix, verb, uri_pattern, and controller_action
        route_info_arr = file_data.flat_map { |line|
          next if line.empty?
          match = line.match(/^\s*(\S*)\s*(GET|POST|PUT|PATCH|DELETE|OPTIONS|HEAD)?\s+(\S+)\s+(.+)\s*$/)
          if match
            prefix, verb, uri_pattern, controller_action = match.captures
            # Split the verb by '|' if it exists, otherwise default to 'GET'
            verbs = verb&.split('|') || ['GET']
            verbs.map { |v| Structs::RouteInfo.new(verb: v, uri_pattern: uri_pattern, controller_action: controller_action) }
          end
        }.compact
        Success(route_info_arr)
      rescue
        Failure("Failed to map line content to RouteInfo")
      end
    end
  end
end
