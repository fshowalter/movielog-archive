module Movielog
  module Db
    #
    # Responsible for querying related titles for a given title based on the cast.
    #
    #
    class QueryRecentReviewedReleases
      class << self
        #
        # Responsible for querying related titles for a given title based on the cast.
        #
        # Any reviews found with members of the headline cast are returned, as well as
        # any reviews for other cast members provided the total of the reviews is greater
        # than or equal to 5.
        #
        # @param db [SQLite3::Database] The database.
        # @param title [string] The title.
        # @return [void]
        def call(db:)
          recent_reviewed_releases_query(db: db).execute.each_with_object([]) do |title, titles|
            titles << title[0]
          end
        end

        private

        def recent_reviewed_releases_query(db:)
          db.prepare(
            <<-SQL
              SELECT reviews.title FROM reviews
                INNER JOIN movies on reviews.title = movies.title
                ORDER BY movies.release_date DESC;
            SQL
          )
        end
      end
    end
  end
end
