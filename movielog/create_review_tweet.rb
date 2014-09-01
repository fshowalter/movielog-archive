module Movielog
  class CreateReviewTweet
    class << self
      def call(url:, display_title:, grade:, headline_cast:)
        headline_cast = format_headline_cast(headline_cast: headline_cast)
        tweet = "#{display_title.upcase} (#{grade}) #{headline_cast}".slice(0, 122) + "...#{url}"
        twitter_client.update(tweet)
        tweet
      end

      private

      def format_headline_cast(headline_cast: headline_cast)
        headline_cast.map { |person| "#{person.first_name} #{person.last_name}" }.join(', ')
      end

      def twitter_client
        require 'twitter'

        twitter = YAML.load(File.open(
          File.join(File.expand_path('../../', __FILE__), 'twitter.yml')))
        Twitter::REST::Client.new do |config|
          config.consumer_key        = twitter['consumer_key']
          config.consumer_secret     = twitter['consumer_secret']
          config.access_token        = twitter['access_token']
          config.access_token_secret = twitter['access_token_secret']
        end
      end
    end
  end
end
