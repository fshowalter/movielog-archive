require 'ostruct'

module Movielog
  #
  # Responsible for holding review data.
  #
  class Review < OpenStruct
    def title_without_year
      title.gsub(/\([^\)]+\)$/, '').strip
    end

    def year
      (db_title || display_title)[/\((\d{4}).*\)$/, 1]
    end
  end
end
