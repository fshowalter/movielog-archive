module Movielog
  #
  # Responsible for creating new viewing instances.
  #
  class CreateViewing
    class << self
      #
      # Responsible for creating a new viewing instance.
      #
      def call(viewings_path:, title:, date:, display_title:, venue:, number:, slug:)
        file_name = new_viewing_file_name(viewings_path: viewings_path, number: number, slug: slug)

        viewing = {
          number: number,
          title: title,
          display_title: display_title,
          date: date,
          venue: venue
        }

        File.open(file_name, 'w') do |file|
          file.write(viewing.to_yaml)
        end

        OpenStruct.new(viewing)
      end

      private

      def new_viewing_file_name(viewings_path:, number:, slug:)
        File.join(viewings_path, format('%04d', number) + '-' + slug + '.yml')
      end
    end
  end
end
