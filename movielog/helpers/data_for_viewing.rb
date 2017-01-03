# frozen_string_literal: true
module Movielog
  #
  # Responsible for providing template helper methods.
  #
  module Helpers
    def data_for_viewing(viewing:) # rubocop:disable Metrics/MethodLength
      movie = Movielog.movies[viewing.db_title]

      {
        data: {
          title: movie.display_title,
          sort_title: movie.sortable_title,
          release_date: movie.release_date.iso8601,
          release_date_year: movie.release_date.year,
          viewing_date: viewing.date,
          venue: Movielog.venues.index(viewing.venue)
        }
      }
    end
  end
end
