
require 'yaml'

module Movielog
  #
  # Responsible for parsing viewing data.
  #
  class ParseViewings
    class << self
      #
      # Responsible for parsing viewing data at the given path.
      #
      # @param viewings_path [String] Path to the viewing data.
      # @return [Hash] A hash of viewing objects, keyed by sequence.
      def call(viewings_path)
        Dir["#{viewings_path}/*.yml"].reduce({}) do |memo, file|
          viewing = YAML.load(IO.read(file))
          fail "Invalid viewing: #{file}" if viewing.nil?
          memo[viewing[:number]] = OpenStruct.new(viewing)
          memo
        end
      end
    end
  end
end
