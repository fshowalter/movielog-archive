# frozen_string_literal: true
module Movielog
  #
  # Responsible for providing template helper methods.
  #
  module Helpers
    def data_for_review(movie:, review:)
      {
        data: {
          title: review.title,
          sort_title: movie.sortable_title,
          release_date: movie.release_date.iso8601,
          release_date_year: movie.release_date.year,
          review_date: review.date,
          grade: Movielog::ConvertGradeToNumber.call(grade: review.grade).to_s.rjust(2, '0')
        }
      }
    end
  end
end
