# frozen_string_literal: true
require 'movie_db'

Dir[File.expand_path('../**/*.rb', __FILE__)].each { |f| require f }

#
# Responsible for defining the Movielog API.
#
module Movielog
  class << self
    attr_accessor :cache_reviews

    def site_url
      'https://www.franksmovielog.com'
    end

    def site_title
      "Frank's Movie Log"
    end

    def next_viewing_number(viewings: Movielog.viewings)
      viewings.length + 1
    end

    def next_post_number(reviews: Movielog.reviews, pages: Movielog.pages)
      (reviews.length + pages.length) + 1
    end

    def db
      @db ||= MovieDb.new(movie_db_dir: File.expand_path('../../movie_db/', __FILE__))
    end

    def movies(db: Movielog.db, db_titles: Movielog.viewed_db_titles)
      @movies ||= MovieDb.fetch_movies(db: db, titles: db_titles)
    end

    def viewed_db_titles(viewings: Movielog.viewings)
      @viewed_db_titles ||= viewings.values.map(&:db_title).uniq
    end

    def viewings_path
      @viewings_path ||= File.expand_path('../../viewings/', __FILE__)
    end

    def reviews_path
      @reviews_path ||= File.expand_path('../../reviews/', __FILE__)
    end

    def pages_path
      @pages_path ||= File.expand_path('../../pages/', __FILE__)
    end

    def viewings(viewings_path: Movielog.viewings_path)
      @viewings ||= ParseViewings.call(viewings_path: viewings_path) || {}
    end

    def reviews(reviews_path: Movielog.reviews_path)
      if cache_reviews
        @reviews ||= ParseReviews.call(reviews_path: reviews_path) || {}
      else
        ParseReviews.call(reviews_path: reviews_path) || {}
      end
    end

    def reviews_by_sequence(reviews: Movielog.reviews)
      if cache_reviews
        @reviews_by_sequence ||= reviews.values.sort_by(&:sequence).reverse
      else
        reviews.values.sort_by(&:sequence).reverse
      end
    end

    def pages(pages_path: Movielog.pages_path)
      @pages ||= ParsePages.call(pages_path: pages_path) || {}
    end

    def cast_and_crew(db: Movielog.db)
      @cast_and_crew ||= Movielog::Db::QueryMostReviewedPersons.call(db: db)
    end

    def venues(viewings: Movielog.viewings)
      @venues ||= viewings.values.map(&:venue).uniq.sort
    end

    def viewings_for_db_title(viewings: Movielog.viewings, db_title:)
      viewings.values.select { |viewing| viewing.db_title == db_title }
    end
  end
end
