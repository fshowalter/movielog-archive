module Movielog
  module Console
    #
    # Responsible for providing a console interface to create review tweets.
    #
    class CreateReviewTweet
      class << self
        #
        # Responsible for providing a console interface to create a review tweet.
        #
        # @return [void].
        def call
          review = GetReview.call
          tweet = build_tweet(review)
          TweetMessage.call(tweet)
          puts tweet
        end

        private

        def build_tweet(review)
          long_url = "http://www.franksmovielog.com/reviews/#{review.slug}"

          url = ShortenUrl.call(long_url)
          grade = Movielog::App.grade_to_text(review.grade)
          headline_cast = Movielog::App.headline_cast_for_title(title).map do |person|
            "#{person.first_name} #{person.last_name}"
          end.join(', ')

          "#{review.display_title.upcase} (#{grade}) #{headline_cast}".slice(0, 122) + "... #{url}"
        end

        #
        # Responsible for getting a review via the console.
        #
        class GetReview
          class << self
            #
            # Responsible for getting a review via the console.
            #
            # @param title [String] The review title.
            # @return [Movielog::Review] The review.
            def call(title = nil)
              require 'inquirer'

              while title.nil?
                query = Ask.input 'Title'
                results = Movielog::App.search_for_reviewed_title(query)
                choices = format_title_results(results) + ['Search Again']
                idx = Ask.list(' Title', choices)

                next if idx == results.length

                title = results[idx].title
              end

              Movielog::App.reviews_by_title[title]
            end

            private

            def format_title_results(results)
              results.map do |movie|
                [
                  movie.display_title,
                  headline_cast(movie.title),
                  aka_titles(movie.title),
                  "\n"
                ].join
              end
            end

            def aka_titles(title)
              aka_titles = Movielog::App.aka_titles_for_title(title)
              return unless aka_titles.any?

              "\n   " + aka_titles.map { |aka_title| "aka #{aka_title.aka_title}" }.join("\n   ")
            end

            def headline_cast(title)
              headline_cast = Movielog::App.headline_cast_for_title(title)
              return unless headline_cast.any?
              "\n   " + headline_cast.map do |person|
                "#{person.first_name} #{person.last_name}"
              end.join(', ')
            end
          end
        end

        #
        # Responsible for shortening a url.
        #
        class ShortenUrl
          class << self
            #
            # Responsible for shortening a given url.
            #
            # @param url [String] The url to shorten.
            # @return [String] The shortened url.
            def call(url)
              require 'google/api_client'
              require 'google/api_client/client_secrets'
              require 'google/api_client/auth/installed_app'

              get_existing_shortened_url(url) || create_new_shortened_url(url)
            end

            private

            def create_new_shortened_url(url)
              result = client.execute(api_method: urlshortener.url.insert,
                                      body_object: { longUrl: url })
              result.data.id
            end

            def get_existing_shortened_url(url)
              result = client.execute(api_method: urlshortener.url.list)

              result.data['items'].each do |item|
                return item.id if item.long_url == url
              end

              nil
            end

            def urlshortener
              @urlshortener ||= client.discovered_api('urlshortener')
            end

            def client
              @client ||= begin
                client = Google::APIClient.new(
                  application_name: "Frank's Movie Log", application_version: '1.0.0')

                client_secrets = Google::APIClient::ClientSecrets.load

                # Run installed application flow. Check the samples for a more
                # complete example that saves the credentials between runs.
                client.authorization = Google::APIClient::InstalledAppFlow.new(
                  client_id: client_secrets.client_id,
                  client_secret: client_secrets.client_secret,
                  scope: ['https://www.googleapis.com/auth/urlshortener']).authorize

                client
              end
            end
          end
        end

        #
        # Responsible for tweeting a message.
        #
        class TweetMessage
          class << self
            #
            # Responsible for tweeting a given message.
            #
            # @param message [String] The tweet content.
            # @return [void]
            def call(message)
              require 'twitter'

              client.update(message)
            end

            private

            def client
              twitter = YAML.load(File.open(
                File.join(File.expand_path('../../../', __FILE__), 'twitter.yml')))

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
    end
  end
end
