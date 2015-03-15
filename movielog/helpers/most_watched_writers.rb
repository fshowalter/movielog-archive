module Movielog
  #
  # Responsible for providing template helper methods.
  #
  module Helpers
    def most_watched_writers(limit: 5)
      @@most_watched_writers ||= Movielog.most_watched_writers(limit: limit)
    end
  end
end
