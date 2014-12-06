module Movielog
  #
  # Responsible for providing template helper methods.
  #
  module Helpers
    def grade_to_image_tag(grade:, options: {})
      return '' if grade.blank?

      info = ImageInfoForGrade.call(grade: grade)

      unless development?
        info.file = 'https://www.franksmovielog.com/' + image_path(info.file)
      end

      options[:alt] = info.alt

      image_tag(info.file, options)
    end

    #
    # Responsible for providing image tag info for a given grade.
    #
    class ImageInfoForGrade
      INFO_FOR_GRADE = {
        'A+' => OpenStruct.new(file: '5-stars.svg', alt: '5 Stars (out of 5)'),
        'A' => OpenStruct.new(file: '4-stars.svg', alt: '4 Stars (out of 5)'),
        'B' => OpenStruct.new(file: '3-stars.svg', alt: '3 Stars (out of 5)'),
        'C' => OpenStruct.new(file: '2-stars.svg', alt: '2 Stars (out of 5)'),
        'D' => OpenStruct.new(file: '1-star.svg', alt: '1 Star (out of 5)'),
        'F' => OpenStruct.new(file: 'no-stars.svg', alt: '0 Stars (out of 5)')
      }

      class << self
        def call(grade:)
          INFO_FOR_GRADE[grade] || INFO_FOR_GRADE[grade[0]]
        end
      end
    end
  end
end
