# frozen_string_literal: true
module Movielog
  module Console
    #
    # Responsible for providing a console interface to create new placeholder images.
    #
    class CreatePlaceholder
      class << self
        #
        # Responsible for providing a console interface to create a new placeholder image.
        #
        # @return the base64 encoded placeholder
        def call
          review = ask_for_title
          placeholder = create_placeholder(review)

          puts "\n #{placeholder} \n" \

          placeholder
        end

        private

        def create_placeholder(review)
          Movielog::CreatePlaceholder.call(image: review.backdrop)
        end

        def ask_for_title
          reviews_without_placeholder = Movielog.reviews.values.reject(&:backdrop_placeholder)
          titles = reviews_without_placeholder.map(&:title)

          idx = Ask.list(' Title', titles)

          reviews_without_placeholder[idx]
        end
      end
    end
  end
end
