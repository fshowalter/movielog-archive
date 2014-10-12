module Movielog
  module Console
    #
    # Responsible for providing a console interface to create new review tweets.
    #
    class CreateReviewTweet
      class << self
        #
        # Responsible for providing a console interface to create a review tweet.
        #
        # @return [void]
        def call
          movie = ask_for_title
          review = Movielog.reviews_by_title[movie.title]
          url = shorten_url(url: "http://www.franksmovielog.com/reviews/#{review.slug}/")
          grade = Movielog::ConvertGradeToUnicodeStars.call(grade: review.grade)
          tweet = Movielog::CreateReviewTweet.call(url: url,
                                                   display_title: review.display_title,
                                                   grade: grade,
                                                   headline_cast: movie.headline_cast)

          puts tweet
          tweet
        end

        private

        def shorten_url(url: url)
          Movielog::ShortenUrl.call(url: url)
        end

        def ask_for_title
          query_proc = lambda do |db, query|
            MovieDb.search_within_titles(db: db, query: query, titles: Movielog.reviewed_titles)
          end

          db = Movielog.db
          AskForTitle.call(db: db, query_proc: query_proc)
        end
      end
    end
  end
end
