require 'ostruct'

module Movielog
  #
  # Responsible for holding review data.
  #
  class Review < OpenStruct
  	def title_without_year
  		self.title.gsub(/\([^\)]+\)$/, '')
  	end

  	def year
  		(self.db_title || self.display_title)[/\((\d{4}).*\)$/, 1]
  	end
  end
end
