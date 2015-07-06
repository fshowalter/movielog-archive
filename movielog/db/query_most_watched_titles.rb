module Movielog
  module Db
    #
    # Responsible for querying the most watched titles.
    #
    #
    class QueryMostWatchedTitles
      class << self
        #
        # Responsible for querying the most watched titles.
        #
        # @param db [SQLite3::Database] The database.
        # @param limit [string] The max number to return.
        # @return [void]
        def call(db:, limit: 10)
          db.results_as_hash = true

          most_watched_titles_query(db: db).execute(limit).each_with_object([]) do | row, a |
            a << OpenStruct.new(row);
          end
        end

        private

        def most_watched_titles_query(db:)
          db.prepare(
            <<-SQL
              SELECT movies.display_title, count(viewings.title) AS count FROM viewings
                INNER JOIN movies ON viewings.title = movies.title
                GROUP BY viewings.title
                HAVING count > 1
                ORDER BY count DESC
                LIMIT ?;
            SQL
          )
        end
      end
    end
  end
end
