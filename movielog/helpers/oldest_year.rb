module Movielog
  #
  # Responsible for providing template helper methods.
  #
  module Helpers
    def oldest_year(collection, date_method)
      collection.map(&date_method).sort.first.year
    end
  end
end
