
module Movielog
  class ParseViewings
    class << self
      def call(viewings_path)
        Dir["#{viewings_path}/*.yml"].reduce({}) do |memo, file|
          viewing = YAML.load(IO.read(file))
          memo[viewing[:number]] = viewing
          memo
        end
      end
    end
  end
end