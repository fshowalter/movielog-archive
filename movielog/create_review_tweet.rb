module Movielog
  #
  # Responsible for creating review tweets.
  #
  class CreateReviewTweet
    class << self
      def call(url:, display_title:, grade:, headline_cast:, backdrop_url:)
        headline_cast = format_headline_cast(headline_cast: headline_cast)
        tweet = "#{display_title.upcase} (#{grade}) #{headline_cast}".slice(0, 122) + "...#{url}"

        client = twitter_client
        media_id = upload_backdrop(client: client, backdrop_url: backdrop_url)
        client.update(tweet, media_ids: media_id)
        tweet
      end

      private

      def upload_backdrop(client:, backdrop_url:)
        require 'open-uri'

        open(backdrop_url) do |file|
          client.upload(file)
        end
      end

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
