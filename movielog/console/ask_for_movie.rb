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
            query = Ask.input(text: 'Title:')
            results = query_proc.call(query: query)
            choices = format_title_results(results: results)
            choice = Ask.select(prompt: ' Title', choices: choices)
            next if choice == nil

            result = choice
          end

          result
        end

        private

        def add_headline_cast_and_aka_titles_to_movie(movie:); end

        def format_title_results(results:)
          formatted_results = results.each_with_object({}) do |result, a|
            a[key_for_result(result: result)] = result
          end

          formatted_results['Search Again'] = nil
          formatted_results
        end

        def key_for_result(result:)
          [
            Bold.call(text: "#{result.title} (#{result.release_date})"),
            format_overview(overview: result.overview),
            format_aka_titles(result: result),
            "\n",
          ].join
        end

        def format_aka_titles(result:)
          "\n   aka #{result.original_title}" if result.original_title != result.title
        end

        def format_overview(overview:)
          "\n   #{overview.slice(0, 120)}..."
        end
      end
    end
  end
end
