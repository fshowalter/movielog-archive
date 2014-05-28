require 'yaml'

module Movielog
  class ParseFeatures
    class << self
      def call(features_path)
        Dir["#{features_path}/*.md"].reduce({}) do |memo, file|
          begin
            content = IO.read(file)
            if content =~ /\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)/m
              data = YAML.load($1)
              data[:content] = $POSTMATCH
              memo[data[:sequence]] = Feature.new(data)
              memo
            end
          rescue SyntaxError => e
            puts "YAML Exception reading #{file}: #{e.message}"
          rescue Exception => e
            puts "Error reading file #{file}: #{e.message}"
          end
        end
      end
    end
  end
end