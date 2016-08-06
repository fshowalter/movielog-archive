require 'yaml'

module Movielog
  #
  # Responsible for parsing feature data.
  #
  class ParseFeatures
    class << self
      def call(features_path: features_path)
        Dir["#{features_path}/*.md"].each_with_object({}) do |file, features|
          begin
            read_file(file: file, features: features)
          rescue YAML::SyntaxError => e
            puts "YAML Exception reading #{file}: #{e.message}"
          rescue => e
            puts "Error reading file #{file}: #{e.message}"
          end
        end
      end

      private

      def read_file(file:, features:)
        content = IO.read(file)
        return unless content =~ /\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)/m
        data = YAML.load(Regexp.last_match[1])
        data[:content] = $POSTMATCH
        features[data[:slug]] = Feature.new(data)
      end
    end
  end
end
