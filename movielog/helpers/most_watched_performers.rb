module Movielog
  #
  # Responsible for providing template helper methods.
  #
  module Helpers
    def most_watched_performers(limit: 5)
      @@most_watched_performers ||= Movielog.most_watched_performers(limit: limit)
    end
  end
end
