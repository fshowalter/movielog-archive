require 'movie_db'

Dir[File.expand_path('../**/*.rb', __FILE__)].each { |f| require f }

module Movielog
  class << self
    def create_feature(title:)
      CreateFeature.call(features_path: features_path,
                         title: title,
                         sequence: next_post_number,
                         slug: slugize(title))
    end

    def create_viewing(title:, date:, display_title:, venue:)
      CreateViewing.call(viewings_path: viewings_path,
                         title: title,
                         date: date,
                         display_title: display_title,
                         venue: venue,
                         number: next_viewing_number,
                         slug: slugize(display_title))
    end

    def create_review(title:, display_title:)
      CreateReview.call(reviews_path: reviews_path,
                        title: title,
                        display_title: display_title,
                        sequence: next_post_number,
                        slug: slugize(display_title))
    end

    def create_review_tweet(title:, _display_title:, headline_cast:)
      review = reviews_by_title[title]
      url = ShortenUrl.call("http://www.franksmovielog.com/reviews/#{review.slug}")

      CreateReviewTweet.call(
        url: url,
        display_title: review.display_title,
        grade: grade_to_text(review.grade),
        headline_cast: headline_cast)
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

    def search_for_viewed_title(db: db, query: query)
      MovieDb.search_within_titles(db: db, query: query, titles: viewed_titles)
    end

    def search_for_reviewed_title(db, query)
      MovieDb.search_within_titles(db, query, reviewed_titles)
    end

    def reviews_by_title
      reviews.values.each_with_object({}) do |review, hash|
        hash[review.title] = review
      end
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
      viewings.select do |_number, viewing|
        viewing.title == title
      end.values
    end

    def info_for_title(title, db = db)
      MovieDb::App.info_for_title(db, title)
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

    def grade_to_text(grade)
      return if grade.blank?

      case grade
      when 'A+'
        '★★★★★'
      when 'A'
        '★★★★½'
      when 'A-'
        '★★★★☆'
      when 'B+'
        '★★★½☆'
      when 'B'
        '★★★☆☆'
      when 'B-'
        '★★★☆☆'
      when 'C+'
        '★★½☆☆'
      when 'C'
        '★★½☆☆'
      when 'C-'
        '★★½☆☆'
      when 'D+'
        '★★☆☆☆'
      when 'D'
        '★½☆☆☆'
      when 'D-'
        '★½☆☆☆'
      when 'F'
        '★☆☆☆☆'
      end
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
  end
end
