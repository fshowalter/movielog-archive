
module Movielog
  class ParseReviews
    class << self
      def call(reviews_path)

        Dir["#{reviews_path}/*.md"].reduce({}) do |memo, file|
          begin
            content = IO.read(file)
            if content =~ /\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)/m
              data = YAML.load($1)
              data[:content] = $POSTMATCH
              memo[data[:number]] = OpenStruct.new(data)
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