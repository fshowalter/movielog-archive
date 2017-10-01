# frozen_string_literal: true
module Movielog
  module Db
    #
    # Responsible for updating the local database.
    #
    class UpdateDb
      class << self
        #
        # Responsible for updating the viewings and most viewed tables.
        #
        # @param db [SQLite3::Database] The database.
        # @param reviews [Enumerable] The reviews.
        # @return [void]
        def call(db:, reviews:)
          db.execute_batch(reviews_table_schema)
          insert_reviews(db: db, reviews: reviews)

          CreateMostReviewedTables.call(db: db)
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

        def insert_reviews(db:, reviews:)
          progress = progress_bar(title: 'inserting reviews', length: reviews.length)

          insert_reviews_statement = prepare_insert_reviews_statement(db: db)

          reviews.values.each do |review|
            insert_reviews_statement.execute(title: review.db_title, date: review.date.iso8601)
            progress.increment
          end
        end

        def progress_bar(title:, length:)
          ProgressBar.create(title: title, total: length, format: '%t |%w| %e')
        end

        def prepare_insert_reviews_statement(db:)
          db.prepare(
            <<-SQL
          INSERT INTO reviews (title, date)
            VALUES (:title, :date)
          SQL
          )
        end
      end
    end
  end
end
