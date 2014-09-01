module Movielog
  module Console
    #
    # Responsible for providing a console interface to create new review tweets.
    #
    class CreateReviewTweet
      class << self
        #
        # Responsible for processing a new review tweet command.
        #
        # @return [void]
        def call
          query_proc = lambda do |db, query|
            MovieDb.search_within_titles(db: db, query: query, titles: Movielog.reviewed_titles)
          end

          db = Movielog.db
          movie = GetTitle.call(db: db, query_proc: query_proc)
          tweet = Movielog.create_review_tweet(title: movie.title,
                                               display_title: movie.display_title,
                                               headline_cast: movie.headline_cast)

          puts tweet
        end
      end
    end
  end
end
