module Movielog
  module Db
    #
    # Responsible for querying the most watched directors.
    #
    #
    class QueryMostWatchedDirectors
      class << self
        #
        # Responsible for querying the most watched directors.
        #
        # @param db [SQLite3::Database] The database.
        # @param limit [string] The max number to return.
        # @return [void]
        def call(db:, limit: 10)
          db.results_as_hash = true

          most_watched_directors_query(db: db).execute(limit).each_with_object([]) do | row, a |
            a << OpenStruct.new(row);
          end
        end

        private

        def most_watched_directors_query(db:)
          db.prepare(
            <<-SQL
              SELECT people.full_name, people.first_name, people.last_name, most_watched_directors.watch_count AS count
                FROM most_watched_directors
                INNER JOIN people ON most_watched_directors.full_name = people.full_name
                ORDER BY count DESC
                LIMIT ?;
            SQL
          )
        end
      end
    end
  end
end
