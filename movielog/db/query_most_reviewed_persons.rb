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
          results = {}
          db.results_as_hash = true

          process(db: db, results: results, most_reviewed: 'directors', credit_type: 'direction')
          process(db: db, results: results, most_reviewed: 'writers', credit_type: 'writing')
          process(db: db, results: results, most_reviewed: 'performers', credit_type: 'performance')

          results
        end

        private

        def process(db:, results:, most_reviewed:, credit_type:)
          name_query(db: db, table: "most_reviewed_#{most_reviewed}").execute.each do | row |
            add_results_for_row(db: db, results: results, row: row, table_name: "#{credit_type}_credits")
          end
        end

        def slug_for_person(person:)
          Movielog::Slugize.call(text: "#{person.first_name} #{person.last_name} #{person.annotation}")
        end

        def init_result_for_row(results:, row:)
          person = OpenStruct.new(row)
          full_name = person.full_name
          results[full_name] ||= person
          results[full_name].slug ||= slug_for_person(person: person)
          full_name
        end

        def add_results_for_row(db:, results:, row:, table_name:)
          full_name = init_result_for_row(results: results, row: row)
          results[full_name][table_name] = review_titles_for_person(db: db, table: table_name, full_name: full_name)

          results[full_name][table_name].each do |title|
            results[full_name].all ||= {}
            results[full_name].all[title] = title
          end
        end

        def name_query(db:, table:)
          db.prepare(
            <<-SQL
              SELECT people.full_name, people.first_name, people.last_name, people.annotation
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
