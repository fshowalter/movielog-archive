require 'movie_db'

module Movielog
  #
  # Responsible for serving as an entry-point for the Movielog API.
  #
  class App
    class << self
      def viewings
        ParseViewings.call(viewings_path) || {}
      end

      def reviews
        ParseReviews.call(reviews_path) || {}
      end

      def features
        ParseFeatures.call(features_path) || {}
      end

      def posts
        features.merge(reviews)
      end

      def venues
        viewings.values.map(&:venue).uniq
      end

      def search_titles(query, db = db)
        MovieDb::App.search_titles(db, query)
      end

      def viewings_for_title(title)
        viewings.select do |_number, viewing|
          viewing.title == title
        end.values
      end

      def info_for_title(title, db = db)
        MovieDb::App.info_for_title(db, title)
      end

      def search_for_viewed_title(query, db = db)
        titles = viewings.values.map(&:title).uniq
        MovieDb::App.search_within_titles(db, query, titles)
      end

      def directors_for_title(title, db = db)
        MovieDb::App.directors_for_title(db, title)
      end

      def writers_for_title(title, db = db)
        MovieDb::App.writers_for_title(db, title)
      end

      def headline_cast_for_title(title, db = db)
        MovieDb::App.headline_cast_for_title(db, title)
      end

      def aka_titles_for_title(title, display_title = title, db = db)
        MovieDb::App.aka_titles_for_title(db, title, display_title)
      end

      def db
        @db ||= MovieDb::App.connection(db_path)
      end

      def create_viewing(viewing_hash)
        viewing_hash[:number] ||= viewings.length + 1
        viewing_hash[:slug] = slugize(viewing_hash[:display_title])
        CreateViewing.call(viewings_path, viewing_hash)
      end

      def create_review(review_hash)
        review_hash[:date] = Date.today
        review_hash[:sequence] = posts.length + 1
        review_hash[:slug] = slugize(review_hash[:display_title])
        CreateReview.call(reviews_path, review_hash)
      end

      def create_feature(feature_hash)
        feature_hash[:date] = Date.today
        feature_hash[:sequence] = posts.length + 1
        feature_hash[:slug] = slugize(feature_hash[:title])
        CreateFeature.call(features_path, feature_hash)
      end

      private

      def slugize(words, slug = '-')
        slugged = words.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')
        slugged.gsub!(/&/, 'and')
        slugged.gsub!(/:/, '')
        slugged.gsub!(/[^\w_\-#{Regexp.escape(slug)}]+/i, slug)
        slugged.gsub!(/#{slug}{2,}/i, slug)
        slugged.gsub!(/^#{slug}|#{slug}$/i, '')
        url_encode(slugged.downcase)
      end

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
