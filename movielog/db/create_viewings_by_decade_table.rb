# frozen_string_literal: true
module Movielog
  module Db
    #
    # Responsible for creating the viewings by decade table.
    #
    class CreateViewingsByDecadeTable
      class << self
        #
        # Responsible for creating the viewings by decade table.
        #
        # @param db [SQLite3::Database] The database.
        # @return [void]
        def call(db:)
          db.execute_batch(viewings_by_decade_schema)
        end

        private

        def viewings_by_decade_schema
          <<-SQL
          DROP TABLE IF EXISTS viewings_by_decade;
          CREATE TABLE viewings_by_decade (
            "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            "decade" varchar(255) NOT NULL,
            "viewing_count" INTEGER NOT NULL);

          INSERT INTO viewings_by_decade(decade, viewing_count)
          SELECT
          SUBSTR(m.year, 1, 3) || '0' AS decade,
          COUNT(v.id) AS viewing_count
          FROM viewings v LEFT JOIN movies m ON m.title = v.title
          GROUP BY decade;
          PRAGMA vacuum;
          SQL
        end
      end
    end
  end
end
