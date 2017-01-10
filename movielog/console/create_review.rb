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
        def call(db: Movielog.db, viewed_db_titles: Movielog.viewed_db_titles)

          movie = ask_for_movie(db: db, viewed_db_titles: viewed_db_titles)
          review = Movielog::CreateReview.call(movie: movie)

          puts "\n Created Review #{Bold.call(text: review.sequence.to_s)}!\n"
          ap(review.to_h, ruby19_syntax: true)

          review
        end

        private

        def ask_for_movie(db:, viewed_db_titles:)
          query_proc = lambda do |query|
            MovieDb.search_within_titles(db: db, query: query, titles: viewed_db_titles)
          end

          AskForMovie.call(db: db, query_proc: query_proc)
        end
      end
    end
  end
end
