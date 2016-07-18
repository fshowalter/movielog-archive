require 'ostruct'

module Movielog
  #
  # Responsible for holding review data.
  #
  class Review < OpenStruct
  	def title_without_year
  		self.display_title.gsub(/\([^\)]+\)$/, '')
  	end

  	def year
  		(self.db_title || self.display_title)[/\(([^\)]+)\)$/, 1]
  	end
  end
end
