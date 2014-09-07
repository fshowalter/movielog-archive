module Movielog
  module Db
    #
    # Responsible for synching cast and crew with the current movie_db.
    #
    class UpdateMostViewedTables
      class << self
        #
        # Responsible for synching cast and crew with the current movie_db.
        #
        # @param db [SQLite3::Database] The database.
        # @param cast_and_crew [Hash] The cast and crew data.
        # @return [void]
        def call(db:, viewings:)
          CreateMostViewedTables.call(db: db)
          insert_viewings(db: db, viewings: viewings)
        end

        private

        def insert_viewings(db:, viewings:)
          progress = progress_bar(title: 'inserting vieiwngs', length: viewings.length)

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
