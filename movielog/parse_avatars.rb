require 'yaml'

module Movielog
  #
  # Responsible for parsing avatar data.
  #
  class ParseAvatars
    class << self
      def call(avatars_path: avatars_path)
        Dir["#{avatars_path}/*.yml"].each_with_object({}) do |file, avatars|
          begin
            data = YAML.load(IO.read(file))
            avatars[data[:slug]] = OpenStruct.new(data)
          rescue YAML::SyntaxError => e
            puts "YAML Exception reading #{file}: #{e.message}"
          rescue => e
            puts "Error reading file #{file}: #{e.message}"
          end
        end
      end
    end
  end
end
