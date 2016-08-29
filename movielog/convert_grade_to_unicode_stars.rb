# frozen_string_literal: true
module Movielog
  #
  # Responsible for converting a letter grade into a unicode star sequence.
  #
  class ConvertGradeToUnicodeStars
    UNICODE_STAR_FOR_LETTER_GRADE = {
      'A' => '★★★★★',
      'B' => '★★★★',
      'C' => '★★★',
      'D' => '&#x2605;&#x2605;',
      'F' => '★'
    }.freeze
    class << self
      def call(grade:)
        return '' if grade.blank?
        UNICODE_STAR_FOR_LETTER_GRADE[grade[0]]
      end
    end
  end
end
