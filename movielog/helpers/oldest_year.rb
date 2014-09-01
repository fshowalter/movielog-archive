module Movielog
  #
  # Responsible for providing template helper methods.
  #
  module Helpers
    def oldest_year(collection:, date_method:)
      return unless collection && collection.any?

      collection.map(&date_method).sort.first.year
    end
  end
end
