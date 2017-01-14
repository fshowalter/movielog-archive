# frozen_string_literal: true
module Movielog
  module Console
    #
    # Responsible for providing a console interface for searching and selecting movies.
    #
    class AskForMovie
      class << self
        def call(query_proc:)
          result = nil

          while result.nil?
            query = Ask.input 'Title'
            results = query_proc.call(query: query)
            choices = format_title_results(results: results) + ['Search Again']
            idx = Ask.list(' Title', choices)

            next if idx == results.length

            result = results[idx]
          end

          result
        end

        private

        def add_headline_cast_and_aka_titles_to_movie(movie:); end

        def format_title_results(results:)
          results.map do |movie|
            [
              Bold.call(text: movie.display_title),
              format_headline_cast(movie: movie),
              format_aka_titles(movie: movie),
              "\n",
            ].join
          end
        end

        def format_aka_titles(movie:)
          aka_titles = Movielog.aka_titles_for_movie(movie: movie)

          return unless aka_titles.any?

          "\n   " + aka_titles.map { |aka_title| "aka #{aka_title}" }.join("\n   ")
        end

        def format_headline_cast(movie:)
          headline_cast = Movielog.headline_cast_for_movie(movie: movie)

          return unless headline_cast.any?
          "\n   " + headline_cast.map do |person|
            "#{person.first_name} #{person.last_name}"
          end.join(', ')
        end
      end
    end
  end
end
