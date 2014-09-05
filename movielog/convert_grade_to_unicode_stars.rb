module Movielog
  #
  # Responsible for converting a letter grade into a unicode star sequence.
  #
  class ConvertGradeToUnicodeStars
    UNICODE_STAR_FOR_LETTER_GRADE = {
      'A+' => '★★★★★',
      'A' => '★★★★½',
      'A-' => '★★★★☆',
      'B+' => '★★★½☆',
      'B' => '★★★☆☆',
      'B-' => '★★★☆☆',
      'C+' => '★★½☆☆',
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
