require 'active_support/core_ext/hash/slice'

module Movielog
  #
  # Responsible for creating new viewing instances.
  #
  class CreateReview
    class << self
      def call(reviews_path, review)
        file_name = new_review_file_name(reviews_path, review)
        File.open(file_name, 'w') do |file|
          file.write(reviews.slice(:number, :title, :date).to_yaml)
        end

        file_name
      end

      private

      def new_review_file_name(reviews_path, review)
        File.join(reviews_path, review[:slug] + ".yml")
      end
    end
  end
end