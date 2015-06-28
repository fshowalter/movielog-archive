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
        def call(db: db)
          db.execute_batch(reviews_table_schema)
          db.execute_batch(most_reviewed_schema(
            type: 'performers', table: 'performance', threshold: 2))
          db.execute_batch(most_reviewed_schema(
            type: 'directors', table: 'direction', threshold: 2))
          db.execute_batch(most_reviewed_schema(
            type: 'writers', table: 'writing', threshold: 2))
        end

        private

        def reviews_table_schema
          <<-SQL
          DROP TABLE IF EXISTS "reviews";
          CREATE TABLE "reviews" (
            "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            "title" varchar(255) NOT NULL,
            "date" date NOT NULL,
            CONSTRAINT fk_reviews_title FOREIGN KEY ("title") REFERENCES "movies" ("title"));
          CREATE INDEX "index_reviews_on_title" ON "reviews" ("title");
          SQL
        end

        # rubocop:disable Metrics/LineLength
        # rubocop:disable Metrics/MethodLength
        def most_reviewed_schema(type:, table:, threshold:)
          <<-SQL
          DROP VIEW IF EXISTS most_reviewed_#{type};
          CREATE VIEW most_reviewed_#{type} AS
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
      end
    end
  end
end
