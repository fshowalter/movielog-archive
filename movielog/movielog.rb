require 'movie_db'

Dir[File.expand_path('../**/*.rb', __FILE__)].each { |f| require f }

#
# Responsible for defining the Movielog API.
#
module Movielog
  UNICODE_STAR_FOR_LETTER_GRADE = {
    'A+' => '★★★★★',
    'A' => '★★★★½',
    'A-' => '★★★★☆',
    'B+' => '★★★½☆',
    'B' => '★★★☆☆',
    'B-' => '★★★☆☆',
    'C+' => '★★½☆☆',
    'C' => '★★½☆☆',
    'C-' => '★★½☆☆',
    'D+' => '★★☆☆☆',
    'D' => '★½☆☆☆',
    'D-' => '★½☆☆☆',
    'F' => '★☆☆☆☆'
  }

  class << self
    def reviews_by_title
      reviews.values.each_with_object({}) do |review, hash|
        hash[review.title] = review
      end
    end

    def next_viewing_number
      viewings.length + 1
    end

    def next_post_number
      posts.length + 1
    end

    def db
      MovieDb.new(movie_db_dir: File.expand_path('../../db/', __FILE__))
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

    def viewings_for_title(title)
      viewings.select { |_number, viewing| viewing.title == title }.values
    end
  end
end
