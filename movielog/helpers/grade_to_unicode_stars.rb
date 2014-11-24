module Movielog
  #
  # Responsible for providing template helper methods.
  #
  module Helpers
    def grade_to_unicode_stars(grade:)
      return '' unless grade

      Movielog::ConvertGradeToUnicodeStars.call(grade: grade)
    end
  end
end
