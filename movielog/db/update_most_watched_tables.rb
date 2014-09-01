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
          CreateMostWatchedTables.call(db: db)
          insert_viewings(db: db, viewings: viewings)
        end

        private

        def insert_viewings(db:, viewings:)
          progress = progress_bar(title: 'inserting viewings', length: viewings.length)

          insert_viewing_statement = prepare_insert_viewing_statement(db: db)

          viewings.values.each do |viewing|
            insert_viewing_statement.execute(title: viewing.title, date: viewing.date.iso8601)
            progress.increment
          end
        end

        def progress_bar(title:, length:)
          ProgressBar.create(title: title, total: length, format: '%t |%w| %e')
        end

        def prepare_insert_viewing_statement(db: db)
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
