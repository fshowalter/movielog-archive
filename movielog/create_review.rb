require 'active_support/core_ext/hash/slice'

module Movielog
  #
  # Responsible for creating new viewing instances.
  #
  class CreateReview
    class << self
      def call(reviews_path, review)
        file_name = new_review_file_name(reviews_path, review)
        
        content = "#{review.slice(:number, :title, :slug, :display_title, :date).to_yaml}---\n"
        File.open(file_name, 'w') { |file| file.write(content) }

        file_name
      end

      private

      def new_review_file_name(reviews_path, review)
        File.join(reviews_path, review[:slug] + ".md")
      end
    end
  end
end