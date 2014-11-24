module Movielog
  #
  # Responsible for providing template helper methods.
  #
  module Helpers
    def grade_to_unicode_stars(grade:)
      return '' unless grade

      Movielog::ConvertGradeToUnicodeStars.call(grade: grade)
    end

    def grade_to_unicode_stars_as_html(grade:)
      return '' unless grade

      Movielog::ConvertGradeToUnicodeStars.call(grade: grade)
        .gsub(/★/, '<span class="star">★</span>')
    end
  end
end
