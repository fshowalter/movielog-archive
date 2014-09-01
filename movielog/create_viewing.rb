module Movielog
  #
  # Responsible for creating new viewing instances.
  #
  class CreateViewing
    class << self
      #
      # Responsible for creating a new viewing instance.
      #
      def call(viewings_path:, title:, date:, display_title:, venue:, number:, slug:) # rubocop: disable Metrics/ParameterLists, Metrics/LineLength
        file_name = File.join(viewings_path, format('%04d', number) + '-' + slug + '.yml')

        viewing = build_viewing(number: number,
                                title: title,
                                display_title: display_title,
                                date: date,
                                venue: venue)

        File.open(file_name, 'w') { |file| file.write(viewing.to_yaml) }

        OpenStruct.new(viewing)
      end

      private

      def build_viewing(number:, title:, display_title:, date:, venue:)
        {
          number: number,
          title: title,
          display_title: display_title,
          date: date,
          venue: venue
        }
      end
    end
  end
end
