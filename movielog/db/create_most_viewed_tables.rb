module Movielog
  module Db
    #
    # Responsible for creating the people and credits tables.
    #
    class CreateMostViewedTables
      class << self
        #
        # Responsible for creating the people and credits tables.
        #
        # @param db [SQLite3::Database] The database.
        # @return [void]
        def call(db: db)
          db.execute_batch(viewings_table_schema)
          db.execute_batch(most_viewed_schema(
            type: 'performers', table: 'performance', threshold: 10))
          db.execute_batch(most_viewed_schema(
            type: 'directors', table: 'direction', threshold: 1))
          db.execute_batch(most_viewed_schema(
            type: 'writers', table: 'writing', threshold: 1))
        end

        private

        def viewings_table_schema
          <<-SQL
          DROP TABLE IF EXISTS "viewings";
          CREATE TABLE "viewings" (
            "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            "title" varchar(255) NOT NULL,
            "date" date NOT NULL,
            CONSTRAINT fk_viewings_title FOREIGN KEY ("title") REFERENCES "movies" ("title"));
          CREATE INDEX "index_viewings_on_title" ON "viewings" ("title");
          SQL
        end

        # rubocop:disable Metrics/LineLength
        # rubocop:disable Metrics/MethodLength
        def most_viewed_schema(type:, table:, threshold:)
          <<-SQL
          DROP VIEW IF EXISTS most_viewed_#{type};
          CREATE VIEW most_viewed_#{type} AS
          SELECT c.full_name,
          COUNT(DISTINCT c.title) AS movie_count,
          COUNT(DISTINCT v.title) AS viewed_movie_count,
          (ROUND((COUNT(DISTINCT v.title) * 1.0/COUNT(DISTINCT c.title) * 1.0)*100)) as percent_seen,
          COUNT(DISTINCT v.id) AS viewing_count,
          MAX(v.date) AS most_recent_viewing_date
          FROM #{table}_credits c
          LEFT OUTER JOIN (movies m INNER JOIN viewings v ON m.title = v.title) ON c.title = m.title
          GROUP BY c.full_name
          HAVING viewing_count > #{threshold};
          SQL
        end
      end
    end
  end
end
