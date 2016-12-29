# frozen_string_literal: true
require 'yaml'

module Movielog
  #
  # Responsible for parsing viewing data.
  #
  class ParseViewings
    class << self
      def call(viewings_path:)
        Dir["#{viewings_path}/*.yml"].each_with_object({}) do |file, viewings|
          viewing = read_viewing(file)
          next unless viewing.is_a?(Hash)
          viewings[viewing[:number]] = Movielog::Viewing.new(viewing)
        end
      end

      private

      def read_viewing(file)
        YAML.load(IO.read(file))
      rescue YAML::SyntaxError => e
        puts "YAML Exception reading #{file}: #{e.message}"
      rescue => e
        puts "Error reading file #{file}: #{e.message}"
      end
    end
  end
end
