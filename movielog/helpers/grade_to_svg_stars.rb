module Movielog
  #
  # Responsible for providing template helper methods.
  #
  module Helpers
    def grade_to_svg_stars(grade:)
      ConvertGradeToSvgStars.call(grade: grade)
    end

    #
    # Responsible for converting a letter grade into an SVG star graphic.
    #
    class ConvertGradeToSvgStars
      class << self
        def call(grade:)
          return '' if grade.blank?

          '<svg class="rating" xmlns="http://www.w3.org/2000/svg" ' \
          'xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 2560 512">' \
          "#{grade_to_shapes(grade)}" \
          '</svg>'
        end

        private

        def grade_to_shapes(grade)
          SVG_STARS_FOR_LETTER_GRADE[grade] || ''
        end

        def star(index = 0)
          "<polygon transform=\"translate(#{512 * index})\" class=\"star\" " \
          "points=\"256,389.375 97.781,499.477 153.601,314.977 0,198.523 192.71,194.59 " \
          "256,12.523 319.297,194.59 512,198.523 358.399,314.977 414.226,499.477 \"/>"
        end

        def half_star(index = 0)
          "<path transform=\"translate(#{512 * index})\" class=\"empty-star\" " \
          "d=\"M 512,198.523 319.289,194.594 256,12.525 192.707,194.594 " \
          '0,198.526 153.599,314.975 97.784,499.475 255.996,389.381 ' \
          '414.225,499.475 358.394,314.975 512,198.526 z M 359.201,423.656 256,351.744 V ' \
          "106.115 l 41.284,118.766 125.701,2.559 -100.199,75.969 36.415,120.247 z\" />" \
          "<path transform=\"translate(#{512 * index})\" class=\"star\" " \
          "d=\"M 256,16.638245 193.39062,194.82574 0.67187503,198.76324 " \
          "154.26562,315.20075 l -55.812495,184.5 156.874995,-109.15625 0,-373.906255 z\" />"
        end

        def empty_star(index = 0)
          "<path transform=\"translate(#{512 * index})\" class=\"empty-star\" " \
          "d=\"M 512, 198.52 l -192.709-3.924 L 255.995,12.524 l -63.288,182.071 " \
          'L 0,198.52 l 153.599,116.463 L 97.781,499.476 l 158.214-110.103 ' \
          'l 158.229,110.103 l -55.831-184.493 L 512,198.52 z M 359.202,423.764 ' \
          'L 255.994,351.94 l -103.207,71.823 l 36.414-120.35 L 89.003,227.448 ' \
          'l 125.708-2.566 l 41.292-118.773 l 41.283,118.773 l 125.699,2.566 ' \
          "l -100.2,75.967 L 359.202,423.764 z\"/>"
        end
      end

      SVG_STARS_FOR_LETTER_GRADE = {
        'A+' => [star, star(1), star(2), star(3), star(4)].join,
        'A' => [star, star(1), star(2), star(3), empty_star(4)].join,
        'A-' => [star, star(1), star(2), star(3), empty_star(4)].join,
        'B+' => [star, star(1), star(2), empty_star(3), empty_star(4)].join,
        'B' => [star, star(1), star(2), empty_star(3), empty_star(4)].join,
        'B-' => [star, star(1), star(2), empty_star(3), empty_star(4)].join,
        'C+' => [star, star(1), empty_star(2), empty_star(3), empty_star(4)].join,
        'C' => [star, star(1), empty_star(2), empty_star(3), empty_star(4)].join,
        'C-' => [star, star(1), empty_star(2), empty_star(3), empty_star(4)].join,
        'D+' => [star, empty_star(1), empty_star(2), empty_star(3), empty_star(4)].join,
        'D' => [star, empty_star(1), empty_star(2), empty_star(3), empty_star(4)].join,
        'D-' => [star, empty_star(1), empty_star(2), empty_star(3), empty_star(4)].join,
        'F' => [empty_star, empty_star(1), empty_star(2), empty_star(3), empty_star(4)].join
      }
    end
  end
end
