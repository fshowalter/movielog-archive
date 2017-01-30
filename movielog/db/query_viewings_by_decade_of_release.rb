# frozen_string_literal: true
module Movielog
  module Db
    #
    # Responsible for querying viewings by decade of release.
    #
    #
    class QueryViewingsByDecadeOfRelease
      class << self
        #
        # Responsible for querying viewings by decade of release.
        #
        # @param db [SQLite3::Database] The database.
        # @return [void]
        def call(db:)
          db.results_as_hash = true

          viewings_by_decade_of_release_query(db: db).execute.each_with_object([]) do |row, a|
            a << OpenStruct.new(row)
          end
        end

        private

        def viewings_by_decade_of_release_query(db:)
          db.prepare(
            <<-SQL
              SELECT decade, viewing_count FROM viewings_by_decade;
            SQL
          )
        end
      end
    end
  end
end
