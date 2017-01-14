# frozen_string_literal: true
require 'awesome_print'

module Movielog
  module Console
    #
    # Responsible for providing a console interface to create new reviews.
    #
    class CreateReview
      class << self
        #
        # Responsible for processing a new review command.
        #
        # @return [OpenStruct] The new review data.
        def call(query_proc: Movielog.method(:search_viewed_titles))
          movie = AskForMovie.call(query_proc: query_proc)
          review = Movielog::CreateReview.call(movie: movie)

          puts "\n Created Review #{Bold.call(text: review.sequence.to_s)}!\n"
          ap(review.to_h, ruby19_syntax: true)

          review
        end
      end
    end
  end
end
