
require 'yaml'

module Movielog
  #
  # Responsible for parsing viewing data.
  #
  class ParseViewings
    class << self
      def call(viewings_path:)
        Dir["#{viewings_path}/*.yml"].each_with_object({}) do |file, viewings|
          viewing = YAML.load(IO.read(file))
          fail "Invalid viewing: #{file}" if viewing.nil?
          viewings[viewing[:number]] = OpenStruct.new(viewing)
        end
      end
    end
  end
end
