module Movielog
  module Db
    #
    # Responsible for querying related titles for a given title based on the cast.
    #
    #
    class QueryRelatedTitlesByCast
      class << self
        #
        # Responsible for querying related titles for a given title based on the cast.
        #
        # Any reviews found with members of the headline cast are returned, as well as
        # any reviews for other cast members provided the total of the reviews is greater
        # than or equal to 5.
        #
        # @param db [SQLite3::Database] The database.
        # @param title [string] The title.
        # @return [void]
        def call(db:, title:)
          performers = {}

          MovieDb.headline_cast_for_title(db: db, title: title, count: 10).each do |performer|
            next unless reviewed_performer?(db: db, performer_full_name: performer.full_name)

            performers[performer] = review_titles_for_performer(
              db: db, performer: performer.full_name)
          end

          performers
        end

        private

        def reviewed_performer?(db:, performer_full_name:)
          @reviewed_performers ||= begin
            db.results_as_hash = true
            db.prepare('SELECT * FROM most_reviewed_performers WHERE review_count > 4')
              .execute
              .each_with_object({}) do |row, a|
                a[row['full_name']] = OpenStruct.new(row)
              end
          end

          @reviewed_performers.key?(performer_full_name)
        end

        def review_titles_for_performer(db:, performer:)
          db.results_as_hash = true
          review_titles = review_titles_for_performer_query(db: db).execute(performer)
          review_titles.map do |review_title|
            review_title['title']
          end
        end

        def review_titles_for_performer_query(db:)
          db.prepare(
            <<-SQL
              SELECT reviews.title FROM reviews
                INNER JOIN performance_credits ON reviews.title = performance_credits.title
                INNER JOIN movies on reviews.title = movies.title
                WHERE performance_credits.full_name = ?
                ORDER BY movies.year DESC;
            SQL
          )
        end
      end
    end
  end
end
