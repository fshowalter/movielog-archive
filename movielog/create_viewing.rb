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
        File.open(new_viewing_file_name(viewings_path, viewing), 'w') do |file|
          file.write(viewing.slice(:number, :title, :date, :venue).to_yaml)
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
        slug = viewing[:display_title].slugize
        File.join(viewings_path, sprintf("%04d", number) + "-" + slug + ".yml")
      end
    end
  end
end