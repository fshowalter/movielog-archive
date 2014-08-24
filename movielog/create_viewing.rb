require 'active_support/core_ext/hash/slice'

module Movielog
  #
  # Responsible for creating new viewing instances.
  #
  class CreateViewing
    class << self
      #
      # Responsible for creating a new viewing instance.
      #
      # @param viewings_path [String] Path to the folder to store the viewing.
      # @param viewing [Hash] The viewing data. The `:number` and `:slug` values are used to 
      #  generate the filename.
      # @return [String] The full path of the persisted viewing.
      def call(viewings_path, viewing)
        file_name = new_viewing_file_name(viewings_path, viewing)
        File.open(file_name, 'w') do |file|
          file.write(viewing.slice(:number, :title, :display_title, :date, :venue).to_yaml)
        end

        file_name
      end

      private

      def new_viewing_file_name(viewings_path, viewing)
        number = viewing[:number]
        slug = viewing[:slug]
        File.join(viewings_path, format('%04d', number) + '-' + slug + '.yml')
      end
    end
  end
end
