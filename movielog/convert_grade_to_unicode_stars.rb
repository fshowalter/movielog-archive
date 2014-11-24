module Movielog
  #
  # Responsible for converting a letter grade into a unicode star sequence.
  #
  class ConvertGradeToUnicodeStars
    UNICODE_STAR_FOR_LETTER_GRADE = {
      'A+' => '★★★★★',
      'A' => '★★★★☆',
      'A-' => '★★★★☆',
      'B+' => '★★★☆☆',
      'B' => '★★★☆☆',
      'B-' => '★★★☆☆',
      'C+' => '★★☆☆☆',
      'C' => '★★☆☆☆',
      'C-' => '★★☆☆☆',
      'D+' => '★☆☆☆☆',
      'D' => '★☆☆☆☆',
      'D-' => '★☆☆☆☆',
      'F' => '☆☆☆☆☆'
    }
    class << self
      def call(grade: grade)
        UNICODE_STAR_FOR_LETTER_GRADE[grade]
      end
    end
  end
end
