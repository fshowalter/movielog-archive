# frozen_string_literal: true
require 'yaml'

module Movielog
  #
  # Responsible for parsing viewing data.
  #
  class ParseViewings
    class << self
      def call(viewings_path:)
        Dir["#{viewings_path}/*.yml"].map do |file|
          viewing_data = read_viewing(file)
          next unless viewing_data.is_a?(Hash)
          Movielog::Viewing.new(viewing_data)
        end.compact.sort_by(&:number).reverse
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
