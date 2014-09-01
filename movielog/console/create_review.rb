module Movielog
  module Console
    #
    # Responsible for providing a command-line interface to create new reviews.
    #
    class CreateReview
      class << self
        #
        # Responsible for processing a new review command.
        #
        # @return [Movielog::Review] the created review.
        def call
          movie = ask_for_title
          review = Movielog::CreateReview.call(reviews_path: Movielog.reviews_path,
                                               title: movie.title,
                                               display_title: movie.display_title,
                                               sequence: Movielog.next_post_number,
                                               slug: slugize(text: movie.display_title))

          puts "\n Created Review #{Bold.call(text: review.display_title)}!\n" \
          " #{Bold.call(text: '        Title:')} #{review.title}\n" \
          " #{Bold.call(text: '     Sequence:')} #{review.sequence}\n"

          review
        end

        private

        def slugize(text: text)
          Movielog::Slugize.call(text: text)
        end

        def ask_for_title
          query_proc = lambda do |db, query|
            MovieDb.search_within_titles(db: db, query: query, titles: Movielog.viewed_titles)
          end

          db = Movielog.db
          AskForTitle.call(db: db, query_proc: query_proc)
        end
      end
    end
  end
end
