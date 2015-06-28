module Movielog
  module Db
    #
    # Responsible for updating the viewings and most viewed tables.
    #
    class UpdateMostReviewedTables
      class << self
        #
        # Responsible for updating the viewings and most viewed tables.
        #
        # @param db [SQLite3::Database] The database.
        # @param reviews [Enumerable] The reviews.
        # @return [void]
        def call(db:, reviews:)
          CreateMostReviewedTables.call(db: db)
          insert_reviews(db: db, reviews: reviews)
        end

        private

        def insert_reviews(db:, reviews:)
          progress = progress_bar(title: 'inserting reviews', length: reviews.length)

          insert_reviews_statement = prepare_insert_reviews_statement(db: db)

          reviews.values.each do |review|
            insert_reviews_statement.execute(title: review.title, date: review.date.iso8601)
            progress.increment
          end
        end

        def progress_bar(title:, length:)
          ProgressBar.create(title: title, total: length, format: '%t |%w| %e')
        end

        def prepare_insert_reviews_statement(db: db)
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
