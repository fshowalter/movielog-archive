require 'active_support/core_ext/hash/slice'

module Movielog
  #
  # Responsible for creating new viewing instances.
  #
  class CreateReview
    class << self
      def call(reviews_path:, title:, display_title:, sequence:, slug:)
        file_name = new_review_file_name(reviews_path: reviews_path, slug: slug)

        front_matter = {
          sequence: sequence,
          title: title,
          slug: slug,
          display_title: display_title,
          date: Date.today,
          imdb_id: '',
          grade: ''
        }

        content = "#{front_matter.to_yaml}---\n"

        File.open(file_name, 'w') { |file| file.write(content) }

        Review.new(front_matter)
      end

      private

      def new_review_file_name(reviews_path: reviews_path, slug: slug)
        File.join(reviews_path, slug + '.md')
      end
    end
  end
end
