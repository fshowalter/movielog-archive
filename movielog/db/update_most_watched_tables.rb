# frozen_string_literal: true
require 'awesome_print'

module Movielog
  module Db
    #
    # Responsible for updating the viewings and most viewed tables.
    #
    class UpdateMostWatchedTables
      class << self
        #
        # Responsible for updating the viewings and most viewed tables.
        #
        # @param db [SQLite3::Database] The database.
        # @param viewings [Enumerable] The viewings.
        # @return [void]
        def call(db:, viewings:)
          db.execute_batch(viewings_table_schema)
          insert_viewings(db: db, viewings: viewings)

          CreateMostWatchedTables.call(db: db)
          CreateViewingsByDecadeTable.call(db: db)
        end

        private

        def viewings_table_schema
          <<-SQL
          PRAGMA FOREIGN_KEYS = ON;
          DROP TABLE IF EXISTS "viewings";
          CREATE TABLE "viewings" (
            "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            "title" varchar(255) NOT NULL,
            "date" date NOT NULL,
            FOREIGN KEY ("title") REFERENCES "movies" ("title"));
          CREATE INDEX "index_viewings_on_title" ON "viewings" ("title");
          SQL
        end

        def insert_viewings(db:, viewings:)
          progress = progress_bar(title: 'inserting viewings', length: viewings.length)

          insert_viewing_statement = prepare_insert_viewing_statement(db: db)

          viewings.each do |viewing|
            begin
              insert_viewing_statement.execute(title: viewing.db_title, date: viewing.date.iso8601)
              progress.increment
            rescue SQLite3::ConstraintException
              puts "Foreign Key error: #{viewing.db_title} [#{viewing.title}]"
            end
          end
        end

        def progress_bar(title:, length:)
          ProgressBar.create(title: title, total: length, format: '%t |%w| %e')
        end

        def prepare_insert_viewing_statement(db:)
          db.prepare(
            <<-SQL
          INSERT INTO viewings (title, date)
            VALUES (:title, :date)
          SQL
          )
        end
      end
    end
  end
end
