module Movielog
  #
  # Responsible for providing template helper methods.
  #
  module Helpers
    def headline_cast(title:)
      MovieDb.headline_cast_for_title(title: title, db: Movielog.db).map do |person|
        "#{person.first_name} #{person.last_name}"
      end.to_sentence
    end
  end
end
