require 'yaml'

module Movielog
  #
  # Responsible for parsing review data.
  #
  class ParseReviews
    class << self
      def call(reviews_path:)
        Dir["#{reviews_path}/*.md"].each_with_object({}) do |file, reviews|
          begin
            read_file(file: file, reviews: reviews)
          rescue YAML::SyntaxError => e
            puts "YAML Exception reading #{file}: #{e.message}"
          rescue => e
            puts "Error reading file #{file}: #{e.message}"
          end
        end
      end

      private

      def read_file(file:, reviews:)
        content = IO.read(file)
        return unless content =~ /\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)/m

        data = YAML.load(Regexp.last_match[1])
        data[:content] = $POSTMATCH
        reviews[data[:db_title]] = Review.new(data)
      end
    end
  end
end
