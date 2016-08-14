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
        hash[review.db_title] = review
      end
    end

    def next_viewing_number
      viewings.length + 1
    end

    def next_post_number
      (reviews.length + pages.length) + 1
    end

    def db
      @db ||= MovieDb.new(movie_db_dir: File.expand_path('../../movie_db/', __FILE__))
    end

    def viewed_titles
      viewings.values.map(&:title).uniq
    end

    def viewings_path
      File.expand_path('../../viewings/', __FILE__)
    end

    def reviews_path
      File.expand_path('../../reviews/', __FILE__)
    end

    def pages_path
      File.expand_path('../../pages/', __FILE__)
    end

    def viewings
      ParseViewings.call(viewings_path: viewings_path) || {}
    end

    def reviews
      parsed_reviews = ParseReviews.call(reviews_path: reviews_path) || {}
      parsed_reviews.keys.sort.reverse.each_with_object([]) do |sequence, collection|
        collection << parsed_reviews[sequence]
      end
    end

    def pages
      ParsePages.call(pages_path: pages_path) || {}
    end

    def cast_and_crew
      Movielog::Db::QueryMostReviewedPersons.call(db: Movielog.db)
    end

    def venues
      viewings.values.map(&:venue).uniq.sort
    end

    def viewings_for_title(title:)
      viewings.values.select { |viewing| viewing.db_title == title }
    end
  end
end
