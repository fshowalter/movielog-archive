# frozen_string_literal: true
module Movielog
  module Db
    #
    # Responsible for creating the viewings and most viewed tables.
    #
    class CreateMostWatchedTables
      class << self
        #
        # Responsible for creating the viewings and most viewed tables.
        #
        # @param db [SQLite3::Database] The database.
        # @return [void]
        def call(db:)
          db.execute_batch(most_watched_schema(
                             type: 'performers', table: 'performance', threshold: 10
          ))
          db.execute_batch(most_watched_schema(
                             type: 'directors', table: 'direction', threshold: 5
          ))
          db.execute_batch(most_watched_schema(
                             type: 'writers', table: 'writing', threshold: 5
          ))
        end

        private

        # rubocop:disable Metrics/MethodLength
        def most_watched_schema(type:, table:, threshold:)
          <<-SQL
          DROP TABLE IF EXISTS most_watched_#{type};
          CREATE TABLE most_watched_#{type} (
            "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            "full_name" varchar(255) NOT NULL,
            "movie_count" INTEGER NOT NULL,
            "watched_movie_count" INTEGER NOT NULL,
            "percent_seen" FLOAT NOT NULL,
            "watch_count" INTEGER NOT NULL,
            "most_recent_watch_date" DATE NOT NULL);

          CREATE INDEX "index_most_watched_#{type}_on_watched_movie_count" ON "most_watched_#{type}" ("watched_movie_count");

          INSERT INTO most_watched_#{type}(
            full_name, movie_count, watched_movie_count, percent_seen, watch_count, most_recent_watch_date)
          SELECT c.full_name,
          COUNT(DISTINCT c.title) AS movie_count,
          COUNT(DISTINCT v.title) AS watched_movie_count,
          (ROUND((COUNT(DISTINCT v.title) * 1.0/COUNT(DISTINCT c.title) * 1.0)*100)) as percent_seen,
          COUNT(DISTINCT v.id) AS watch_count,
          MAX(v.date) AS most_recent_watch_date
          FROM #{table}_credits c
          LEFT OUTER JOIN (movies m INNER JOIN viewings v ON m.title = v.title) ON c.title = m.title
          GROUP BY c.full_name
          HAVING watch_count >= #{threshold};

          CREATE UNIQUE INDEX "index_most_watched_#{type}_on_full_name" ON "most_watched_#{type}" ("full_name");

          PRAGMA vacuum;
          SQL
        end
        # rubocop:enable Metrics/LineLength
        # rubocop:enable Metrics/MethodLength
      end
    end
  end
end
