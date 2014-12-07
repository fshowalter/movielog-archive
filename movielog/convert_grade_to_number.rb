module Movielog
  #
  # Responsible for converting a letter grade into a number.
  #
  class ConvertGradeToNumber
    NUMBER_FOR_LETTER_GRADE = {
      'A+' => 15,
      'A' => 13,
      'A-' => 12,
      'B+' => 11,
      'B' => 10,
      'B-' => 9,
      'C+' => 8,
      'C' => 7,
      'C-' => 6,
      'D+' => 5,
      'D' => 4,
      'D-' => 3,
      'F' => 0
    }
    class << self
      def call(grade: grade)
        NUMBER_FOR_LETTER_GRADE[grade]
      end
    end
  end
end
