require 'movie_db'

#
# The Movielog namespace.
#
module Movielog
  #
  # Responsible defining the Movielog API.
  #
  class App
    class << self
      #
      # Responsible for returning the viewings, keyed by sequence.
      #
      # @return (see ParseViewings.call)
      def viewings
        ParseViewings.call(viewings_path) || {}
      end

      #
      # Responsible for returning the reviews, keyed by sequence.
      #
      # @return (see ParseReviews.call)
      def reviews
        ParseReviews.call(reviews_path) || {}
      end

      #
      # Responsible for returning the reviews, keyed by title.
      #
      # @return [Hash] A hash of {Movielog::Review} objects, keyed by title.
      def reviews_by_title
        reviews.values.each_with_object({}) do |review, hash|
          hash[review.title] = review
        end
      end

      #
      # Responsible for returning the features, keyed by sequence.
      #
      # @return (see ParseFeatures.call)
      def features
        ParseFeatures.call(features_path) || {}
      end

      #
      # Responsible for returning the features and reviews, keyed by sequence.
      #
      # @return [Hash] A hash of {Movielog::Review} and {Movielog::Feature} objects, keyed by 
      #  sequence.
      def posts
        features.merge(reviews)
      end

      #
      # Responsible for returning a collection of unique viewing venues.
      #
      # @return [Enumerable<String>] The unique viewing venues.
      def venues
        viewings.values.map(&:venue).uniq
      end

      # (see MovieDb::App.search_titles)
      def search_titles(query, db = db)
        MovieDb::App.search_titles(db, query)
      end

      #
      # Responsible for returning the viewing for the given title.
      #
      # @param title [String] The title.
      # @return [Enumerable<Object>] The viewings.
      def viewings_for_title(title)
        viewings.select { |_number, viewing| viewing.title == title }.values
      end

      # (see MovieDb::App.info_for_title)
      def info_for_title(title, db = db)
        MovieDb::App.info_for_title(db, title)
      end

      #
      # Responsible for searching titles scoped to those with viewings.
      #
      # @param query [String] The title query.
      # @param db [SQLite3::Database] The movie db.
      # @return (see MovieDb::App.search_within_titles)
      def search_for_viewed_title(query, db = db)
        titles = viewings.values.map(&:title).uniq
        MovieDb::App.search_within_titles(db, query, titles)
      end

      def search_for_reviewed_title(query, db = db)
        titles = reviews.values.map(&:title).uniq
        MovieDb::App.search_within_titles(db, query, titles)
      end

      # (see MovieDb::App.directors_for_title)
      def directors_for_title(title, db = db)
        MovieDb::App.directors_for_title(db, title)
      end

      # (see MovieDb::App.writers_for_title)
      def writers_for_title(title, db = db)
        MovieDb::App.writers_for_title(db, title)
      end

      # (see MovieDb::App.headline_cast_for_title)
      def headline_cast_for_title(title, db = db)
        MovieDb::App.headline_cast_for_title(db, title)
      end

      # (see MovieDb::App.aka_titles_for_title)
      def aka_titles_for_title(title, display_title = title, db = db)
        MovieDb::App.aka_titles_for_title(db, title, display_title)
      end

      #
      # Responsible for returing a movie_db connection.
      #
      # @return [SQLite3::Database] The movie_db database.
      def db
        @db ||= MovieDb::App.connection(db_path)
      end

      #
      # Responsible for creating a new viewing. 
      #
      # @param viewing_hash [Hash] The viewing data.
      # @return (see Movielog::CreateViewing.call)
      def create_viewing(viewing_hash)
        viewing_hash[:number] ||= viewings.length + 1
        viewing_hash[:slug] = Movielog::Slugize.call(viewing_hash[:display_title])
        CreateViewing.call(viewings_path, viewing_hash)
      end

      #
      # Responsible for creating a new review. 
      #
      # @param review_hash [Hash] The review data.
      # @return (see Movielog::CreateReview.call)
      def create_review(review_hash)
        review_hash[:date] = Date.today
        review_hash[:sequence] = posts.length + 1
        review_hash[:slug] = Movielog::Slugize.call(review_hash[:display_title])
        CreateReview.call(reviews_path, review_hash)
      end

      #
      # Responsible for creating a new feature. 
      #
      # @param feature_hash [Hash] The feature data.
      # @return (see Movielog::CreateFeature.call)
      def create_feature(feature_hash)
        feature_hash[:date] = Date.today
        feature_hash[:sequence] = posts.length + 1
        feature_hash[:slug] = Movielog::Slugize.call(feature_hash[:title])
        CreateFeature.call(features_path, feature_hash)
      end

      #
      # Responsible for converting the given grade to unicode star text. 
      #
      # @param (see Movielog::GradeToStarText.call)
      # @return (see Movielog::GradeToStarText.call)
      def grade_to_text(grade)
        Movielog::GradeToStarText.call(grade)
      end

      private

      def url_encode(word)
        URI.escape(word, /[^\w_+-]/i)
      end

      def viewings_path
        File.expand_path('../../viewings/', __FILE__)
      end

      def reviews_path
        File.expand_path('../../reviews/', __FILE__)
      end

      def features_path
        File.expand_path('../../features/', __FILE__)
      end

      def db_path
        File.expand_path('../../db/', __FILE__)
      end
    end
  end
end
