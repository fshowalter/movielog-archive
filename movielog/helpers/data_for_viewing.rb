# frozen_string_literal: true
module Movielog
  #
  # Responsible for providing template helper methods.
  #
  module Helpers
    def data_for_viewing(viewing:)
      {
        data: {
          title: viewing.title,
          sort_title: viewing.sortable_title,
          release_date: viewing.release_date.iso8601,
          release_date_year: viewing.release_date.year,
          viewing_date: viewing.date,
          venue: Movielog.venues.index(viewing.venue)
        }
      }
    end
  end
end
