module Movielog
  #
  # Responsible for converting a letter grade into a unicode star sequence.
  #
  class ConvertGradeToUnicodeStars
    UNICODE_STAR_FOR_LETTER_GRADE = {
      'A+' => '★★★★★',
      'A' => '★★★★½',
      'A-' => '★★★★½',
      'B+' => '★★★★☆',
      'B' => '★★★½☆',
      'B-' => '★★★½☆',
      'C+' => '★★★☆☆',
      'C' => '★★½☆☆',
      'C-' => '★★½☆☆',
      'D+' => '★★☆☆☆',
      'D' => '★½☆☆☆',
      'D-' => '★½☆☆☆',
      'F' => '★☆☆☆☆'
    }
    class << self
      def call(grade: grade)
        UNICODE_STAR_FOR_LETTER_GRADE[grade]
      end
    end
  end
end
