module Movielog
  #
  # Responsible for converting a letter grade into a number.
  #
  class ConvertGradeToNumber
    NUMBER_FOR_LETTER_GRADE = {
      'A+' => 15,
      'A' => 14,
      'A-' => 13,
      'B+' => 12,
      'B' => 11,
      'B-' => 10,
      'C+' => 9,
      'C' => 8,
      'C-' => 7,
      'D+' => 6,
      'D' => 5,
      'D-' => 4,
      'F' => 1
    }
    class << self
      def call(grade: grade)
        NUMBER_FOR_LETTER_GRADE[grade]
      end
    end
  end
end
