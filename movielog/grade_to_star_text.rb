module Movielog
  #
  # Responsible for converting a letter grade to a unicode star representation.
  #
  class GradeToStarText
    class << self
      #
      # Responsible for converting a given letter grade to a unicode star representation.
      #
      # @param grade [String] The letter grade.
      # @return [String] The unicode star representation.
      def call(grade)
        return if grade.blank?

        grade_to_text[grade]
      end

      private

      # rubocop:disable Metrics/MethodLength
      def grade_to_text
        @grade_to_text ||= {
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
          'F' => '★☆☆☆☆' }
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end