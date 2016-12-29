# frozen_string_literal: true
require 'active_support/core_ext/hash/slice'

module Movielog
  #
  # Responsible for creating new review instances.
  #
  class CreateReview
    class << self
      def call(reviews_path:, title:, display_title:, sequence:, slug:)
        file_name = File.join(reviews_path, slug + '.md')

        front_matter = front_matter(db_title: title,
                                    sequence: sequence,
                                    title: display_title,
                                    slug: slug)

        content = "#{front_matter.to_yaml}---\n"

        File.open(file_name, 'w') { |file| file.write(content) }

        OpenStruct.new(front_matter)
      end

      private

      def front_matter(db_title:, title:, sequence:, slug:) # rubocop:disable Metrics/MethodLength
        {
          sequence: sequence,
          db_title: db_title,
          title: title,
          slug: slug,
          date: Date.today,
          imdb_id: '',
          grade: '',
          backdrop: '',
          backdrop_placeholder: ''
        }
      end
    end
  end
end
