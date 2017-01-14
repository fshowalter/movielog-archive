# frozen_string_literal: true
require 'active_support/core_ext/hash/slice'

module Movielog
  #
  # Responsible for creating new review instances.
  #
  class CreateReview
    class << self
      def call(
        reviews_path: Movielog.reviews_path,
        sequence: Movielog.next_review_sequence,
        movie:
      )
        front_matter = build_front_matter(sequence: sequence, movie: movie)

        write_file(reviews_path: reviews_path, front_matter: front_matter)

        OpenStruct.new(front_matter)
      end

      private

      def defaults
        {
          date: Date.today,
          imdb_id: '',
          grade: '',
          backdrop: '',
          backdrop_placeholder: nil,
        }
      end

      def build_front_matter(sequence:, movie:)
        defaults.merge(sequence: sequence,
                       db_title: movie.title,
                       title: movie.display_title,
                       slug: Movielog::Slugize.call(text: movie.display_title))
      end

      def write_file(reviews_path:, front_matter:)
        file_name = File.join(
          reviews_path,
          front_matter[:slug] + '.md',
        )

        content = "#{front_matter.to_yaml}---\n"

        File.open(file_name, 'w') { |file| file.write(content) }
      end
    end
  end
end
