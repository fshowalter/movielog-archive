module Movielog
  module Db
    #
    # Responsible for querying the most reviewed persons.
    #
    #
    class QueryMostReviewedPersons
      class << self
        #
        # Responsible for querying the most reviewed persons.
        #
        # @param db [SQLite3::Database] The database.
        # @return [void]
        def call(db:)
          results = {};
          db.results_as_hash = true

          name_query(db: db, table: 'most_reviewed_directors').execute.each do | row |
            add_results_for_row(db: db, results: results, row: row, table_name: 'direction_credits')
          end

          name_query(db: db, table: 'most_reviewed_writers').execute.each do | row |
            add_results_for_row(db: db, results: results, row: row, table_name: 'writing_credits')
          end

          name_query(db: db, table: 'most_reviewed_performers').execute.each do | row |
            add_results_for_row(db: db, results: results, row: row, table_name: 'performance_credits')
          end

          results
        end

        private

        def add_results_for_row(db:, results:, row:, table_name:)
          person = OpenStruct.new(row)
          full_name = person.full_name
          results[full_name] ||= person
          results[full_name].slug ||= Movielog::Slugize.call(text: "#{person.first_name} #{person.last_name}")
          results[full_name][table_name] = review_titles_for_person(db: db, table: table_name, full_name: full_name)
        end

        def name_query(db:, table:)
          db.prepare(
            <<-SQL
              SELECT people.full_name, people.first_name, people.last_name
                FROM #{table}
                INNER JOIN people ON #{table}.full_name = people.full_name
            SQL
          )
        end

        def review_titles_for_person(db:, table:, full_name:)
          db.results_as_hash = true
          review_titles = review_titles_for_person_query(db: db, table: table).execute(full_name)
          review_titles.map do |review_title|
            review_title['title']
          end
        end

        def review_titles_for_person_query(db:, table:)
          db.prepare(
            <<-SQL
              SELECT reviews.title FROM reviews
                INNER JOIN #{table} ON reviews.title = #{table}.title
                INNER JOIN movies on reviews.title = movies.title
                WHERE #{table}.full_name = ?
                ORDER BY movies.year DESC;
            SQL
          )
        end
      end
    end
  end
end
