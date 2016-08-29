# frozen_string_literal: true
module Movielog
  module Db
    #
    # Responsible for creating the viewings and most viewed tables.
    #
    class CreateMostReviewedTables
      class << self
        #
        # Responsible for creating the viewings and most viewed tables.
        #
        # @param db [SQLite3::Database] The database.
        # @return [void]
        def call(db:)
          db.execute_batch(most_reviewed_schema(
                             type: 'performers', table: 'performance', threshold: 2
          ))
          db.execute_batch(most_reviewed_schema(
                             type: 'directors', table: 'direction', threshold: 2
          ))
          db.execute_batch(most_reviewed_schema(
                             type: 'writers', table: 'writing', threshold: 2
          ))
        end

        private

        # rubocop:disable Metrics/MethodLength
        def most_reviewed_schema(type:, table:, threshold:)
          <<-SQL
          DROP TABLE IF EXISTS most_reviewed_#{type};
          CREATE TABLE "most_reviewed_#{type}" (
            "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            "full_name" varchar(255) NOT NULL,
            "movie_count" INTEGER NOT NULL,
            "reviewed_movie_count" INTEGER NOT NULL,
            "percent_reviewed" FLOAT NOT NULL,
            "review_count" INTEGER NOT NULL,
            "most_recent_review_date" DATE NOT NULL);

          CREATE INDEX "index_most_reviewed_#{type}_on_review_count" ON "most_reviewed_#{type}" ("review_count");

          INSERT INTO most_reviewed_#{type}(
            full_name, movie_count, reviewed_movie_count, percent_reviewed, review_count, most_recent_review_date)
          SELECT c.full_name,
          COUNT(DISTINCT c.title) AS movie_count,
          COUNT(DISTINCT r.title) AS reviewed_movie_count,
          (ROUND((COUNT(DISTINCT r.title) * 1.0/COUNT(DISTINCT c.title) * 1.0)*100)) as percent_reviewed,
          COUNT(DISTINCT r.id) AS review_count,
          MAX(r.date) AS most_recent_review_date
          FROM #{table}_credits c
          LEFT OUTER JOIN (movies m INNER JOIN reviews r ON m.title = r.title) ON c.title = m.title
          GROUP BY c.full_name
          HAVING review_count >= #{threshold};
          SQL
        end
        # rubocop:enable Metrics/LineLength
        # rubocop:enable Metrics/MethodLength
      end
    end
  end
end
