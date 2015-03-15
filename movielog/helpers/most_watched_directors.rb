module Movielog
  #
  # Responsible for providing template helper methods.
  #
  module Helpers
    def most_watched_directors(limit: 5)
     @@most_watched_directors ||= Movielog.most_watched_directors(limit: limit)
    end
  end
end
