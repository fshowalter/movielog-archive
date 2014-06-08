require 'active_support/core_ext/hash/slice'

module Movielog
  #
  # Responsible for creating new viewing instances.
  #
  class CreateViewing
    class << self
      #
      # Responsible for creating a new viewing instance. The {:title} option of the viewing is used
      # to create the filename, everything else is serialized to YAML inside the file.
      #
      # @param viewing [Hash] A hash of values used to create the viewing.
      # @option viewing [string] :title (nil) The movie title.
      #
      def call(viewings_path, viewing)
        file_name = new_viewing_file_name(viewings_path, viewing)
        File.open(file_name, 'w') do |file|
          file.write(viewing.slice(:number, :title, :display_title, :date, :venue).to_yaml)
        end

        file_name
      end

      private

      #
      # Responsible for returning the file name for a new viewing with the given title.
      # @param title [String] The movie title.
      #
      # @return [String] The new file name.
      def new_viewing_file_name(viewings_path, viewing)
        number = viewing[:number]
        slug = viewing[:slug]
        File.join(viewings_path, format('%04d', number) + '-' + slug + '.yml')
      end
    end
  end
end
