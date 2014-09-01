require 'active_support/core_ext/hash/slice'

module Movielog
  #
  # Responsible for creating new viewing instances.
  #
  class CreateReview
    class << self
      def call(reviews_path:, title:, display_title:, sequence:, slug:)
        file_name = File.join(reviews_path, slug + '.md')

        front_matter = front_matter(title: title,
                                    sequence: sequence,
                                    display_title: display_title,
                                    slug: slug)

        content = "#{front_matter.to_yaml}---\n"

        File.open(file_name, 'w') { |file| file.write(content) }

        Review.new(front_matter)
      end

      private

      def front_matter(title:, display_title:, sequence:, slug:)
        {
          sequence: sequence,
          title: title,
          slug: slug,
          display_title: display_title,
          date: Date.today,
          imdb_id: '',
          grade: ''
        }
      end
    end
  end
end
