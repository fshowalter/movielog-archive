module Movielog
  module Db
    module Queries
      #
      # Responsible for returning the most watched writers.
      #
      class MostWatchedWriters
        class << self
          #
          # RResponsible for returning the most watched writers.
          #
          # @param db [SQLite3::Database] The database.
          # @param limit [Integer] The number of writers to return.
          # @return [Array<OpenStruct>] The most watched writers.
          def call(db:, limit: 3)
            db.results_as_hash = true
            sql_query(db: db).execute(limit).reduce([]) do |a, row|
              a << OpenStruct.new(row)
            end
          end

          private

          def sql_query(db: db)
            db.prepare(
              <<-SQL
                SELECT most_watched_writers.*, people.* FROM most_watched_writers
                  INNER JOIN people ON most_watched_writers.full_name = people.full_name
                  ORDER BY watch_count DESC, most_recent_watch_date DESC
                  LIMIT ?;
              SQL
            )
          end
        end
      end
    end
  end
end