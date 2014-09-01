module Movielog
  module Console
    #
    # Responsible for providing a console interface for searching and selecting movie titles.
    #
    class AskForTitle
      class << self
        def call(db:, query_proc:)
          result = nil

          while result.nil?
            query = Ask.input 'Title'
            results = search_titles(db: db, query_proc: query_proc, query: query)
            choices = format_title_results(results: results) + ['Search Again']
            idx = Ask.list(' Title', choices)

            next if idx == results.length

            result = results[idx]
          end

          result
        end

        private

        def search_titles(db:, query_proc:, query:)
          results = query_proc.call(db, query)

          results.each do |movie|
            movie.headline_cast = MovieDb.headline_cast_for_title(db: db, title: movie.title)
            movie.aka_titles = MovieDb.aka_titles_for_title(db: db, title: movie.title)
          end

          results
        end

        def format_title_results(results:)
          results.map do |movie|
            [
              Bold.call(text: movie.display_title),
              format_headline_cast(headline_cast: movie.headline_cast),
              format_aka_titles(aka_titles: movie.aka_titles),
              "\n"
            ].join
          end
        end

        def format_aka_titles(aka_titles:)
          return unless aka_titles.any?

          "\n   " + aka_titles.map { |aka_title| "aka #{aka_title}" }.join("\n   ")
        end

        def format_headline_cast(headline_cast:)
          return unless headline_cast.any?
          "\n   " + headline_cast.map do |person|
            "#{person.first_name} #{person.last_name}"
          end.join(', ')
        end
      end
    end
  end
end
