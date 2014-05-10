module Movielog
  #
  # Namespace for movielog console use-cases.
  #
  module Console
    #
    # Responsible for providing a command-line interface to create new reviews.
    #
    class NewReview
      class << self
        #
        # Responsible for processing a new viewing command.
        #
        # @return [String] The full path to the new entry.
        def call
          loop do
            title, display_title = get_title
            review_hash = {
              title: title,
              display_title: display_title
            }

            file = Movielog::App.add_review(review_hash)

            puts "\n Created Review ##{bold(review_hash[:number].to_s)}!\n" +
            " #{bold('        Title:')} #{review_hash[:title]}\n" +
            " #{bold('Display Title:')} #{review_hash[:display_title]}\n" +
            " #{bold('         Date:')} #{review_hash[:date]}\n"

            exec "open #{file}"
          end
        end

        private

        def bold(text)
          term = Term::ANSIColor
          term.cyan text
        end

        #
        # Resposible for getting the date from the user.
        #
        # @param terminal [HighLine] The current HighLine instance.
        # @param db [MovieDb::Db] A MovieDb::Db instance.
        # @param title [String] The chosen title.
        #
        # @return [String] The chosen title.
        def get_title(title = nil, display_title = nil)
          while title.nil?
            query = Ask.input 'Title'
            results = Movielog::App.search_viewings_for_title(query).limit(20).to_a
            choices = format_title_results(results)
            choices << 'Search Again'
            idx = Ask.list(" Title", choices)

            unless idx == results.length
              title = results[idx].title
              display_title = results[idx].display_title
            end
          end

          [title, display_title]
        end

        def format_title_results(results)
          results.map do |movie|
            [
              movie.display_title,
              headline_cast(movie),
              aka_titles(movie),
              "\n"
            ].join
          end
        end

        def aka_titles(movie)
          return unless movie.other_titles.any?

          "\n   " + movie.other_titles.map { |aka_title| "aka #{aka_title.aka_title}" }.join("\n   ")
        end

        def headline_cast(movie)
          return unless Movielog::App.headline_cast(movie).any?
          "\n   " + Movielog::App.headline_cast(movie).map(&:name).join(', ')
        end
      end
    end
  end
end