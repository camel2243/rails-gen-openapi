require_relative "../structs/rails_route_info"
module Util
  class FileHelpers
    class << self
      # Takes routes output and returns RouteInfo based on each line
      # for REST verb, uri_pattern and associated controller_action
      def parse(routes_output)
        split_file_data = split(routes_output)
        filtered_file_data = filter_header(split_file_data)
        create_route_info(filtered_file_data)
      end

      # Returns string array for each line
      def split(file_content)
        file_content.split(/\n/)
      rescue
        raise "Failed to split file content"
      end

      # Filter out the header line
      def filter_header(file_content_array)
        # Assuming the first line is the header
        file_content_array.drop(1)
      rescue
        raise "Failed to filter header"
      end

      # Accepts string array from file line
      def create_route_info(file_data)
        # Use regex to split each line into prefix, verb, uri_pattern, and controller_action
        file_data.flat_map { |line|
          next if line.empty?
          match = line.match(/^\s*(\S*)\s*(GET|POST|PUT|PATCH|DELETE|OPTIONS|HEAD)?\s+(\S+)\s+(.+)\s*$/)
          if match
            prefix, verb, uri_pattern, controller_action = match.captures
            # Split the verb by '|' if it exists, otherwise default to 'GET'
            verbs = verb&.split('|') || ['GET']
            verbs.map { |v| Structs::RouteInfo.new(verb: v, uri_pattern: uri_pattern, controller_action: controller_action) }
          end
        }.compact
      rescue
        raise "Failed to map line to RouteInfo"
      end
    end
  end
end
