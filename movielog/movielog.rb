require 'movie_db'

Dir[File.expand_path('../**/*.rb', __FILE__)].each { |f| require f }

#
# Responsible for defining the Movielog API.
#
module Movielog
  class << self
    def site_url
      'https://www.franksmovielog.com'
    end

    def site_title
      "Frank's Movie Log"
    end

    def reviews_by_title
      reviews.values.each_with_object({}) do |review, hash|
        hash[(review.db_title || review.title)] = review
      end
    end

    def next_viewing_number
      viewings.length + 1
    end

    def next_post_number
      posts.length + 1
    end

    def db
      @db ||= MovieDb.new(movie_db_dir: File.expand_path('../../movie_db/', __FILE__))
    end

    def viewed_titles
      viewings.values.map(&:title).uniq
    end

    def reviewed_titles
      reviews.values.map(&:title).uniq
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

    def avatars_path
      File.expand_path('../../avatars/', __FILE__)
    end

    def avatars
      ParseAvatars.call(avatars_path: avatars_path) || {}
    end

    def viewings
      ParseViewings.call(viewings_path: viewings_path) || {}
    end

    def reviews
      ParseReviews.call(reviews_path: reviews_path) || {}
    end

    def features
      ParseFeatures.call(features_path: features_path) || {}
    end

    def cast_and_crew
      Movielog::Db::QueryMostReviewedPersons.call(db: Movielog.db)
    end

    def posts
      features.merge(reviews)
    end

    def venues
      viewings.values.map(&:venue).uniq.sort
    end

    def viewings_for_title(title:)
      viewings.values.select { |viewing| viewing.title == title }
    end
  end
end
