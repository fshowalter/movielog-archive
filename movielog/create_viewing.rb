# frozen_string_literal: true
module Movielog
  #
  # Responsible for creating new viewing files.
  #
  class CreateViewing
    class << self
      #
      # Responsible for creating a new viewing file.
      #
      def call(
        viewings_path: Movielog.viewings_path,
        sequence: Movielog.next_viewing_sequence,
        movie:,
        date:,
        venue:
      )
        front_matter = {
          number: sequence,
          db_title: movie.title,
          title: movie.display_title,
          date: date,
          venue: venue,
        }

        write_file(viewings_path: viewings_path, front_matter: front_matter)

        OpenStruct.new(front_matter)
      end

      private

      def write_file(viewings_path:, front_matter:)
        slug = Movielog::Slugize.call(text: front_matter[:title])

        file_name = File.join(
          viewings_path,
          format('%04d', front_matter[:number]) + '-' + slug + '.yml',
        )

        content = "#{front_matter.to_yaml}\n"

        File.open(file_name, 'w') { |file| file.write(content) }
      end
    end
  end
end
