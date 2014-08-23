module Movielog
  #
  # Namespace for movielog console use-cases.
  #
  module Console
    #
    # Responsible for providing a command-line interface to create new review tweets.
    #
    class CreateReviewTweet
      class << self
        #
        # Responsible for processing a new review tweet command.
        #
        # @return [String] The full path to the new entry.
        def call
          review = get_review
          puts tweet(review)
        end

        private

        def tweet(review)
          url = short_url(review)
          update_text = "#{tweet_text(review)} #{url}"
          twitter_client.update(update_text)
          update_text
        end

        def short_url(review)
          url = "http://www.franksmovielog.com/reviews/#{review.slug}"
          client = google_client

          urlshortener = client.discovered_api('urlshortener')
          result = client.execute(api_method: urlshortener.url.list)

          result.data['items'].each do |item|
            return item.id if item.long_url == url
          end

          result = client.execute(api_method: urlshortener.url.insert, 
            body_object: { longUrl: url })
 
          result.data.id
        end

        def google_client
          require 'google/api_client'
          require 'google/api_client/client_secrets'
          require 'google/api_client/auth/installed_app'

          client = Google::APIClient.new(
            application_name: "Frank's Movie Log",
            application_version: '1.0.0'
          )

          client_secrets = Google::APIClient::ClientSecrets.load
          
          # Run installed application flow. Check the samples for a more
          # complete example that saves the credentials between runs.
          flow = Google::APIClient::InstalledAppFlow.new(
            client_id: client_secrets.client_id,
            client_secret: client_secrets.client_secret,
            scope: ['https://www.googleapis.com/auth/urlshortener']
          )
          client.authorization = flow.authorize
          client
        end

        def twitter_client
          require 'twitter'

          twitter = YAML::load(File.open(
            File.join(File.expand_path('../../../', __FILE__), 'twitter.yml')))
          Twitter::REST::Client.new do |config|
            config.consumer_key        = twitter['consumer_key']
            config.consumer_secret     = twitter['consumer_secret']
            config.access_token        = twitter['access_token']
            config.access_token_secret = twitter['access_token_secret']
          end
        end

        def tweet_text(review)
          grade = Movielog::App.grade_to_text(review.grade)
          "#{review.display_title.upcase} (#{grade}) #{headline_cast(review.title).strip}"
            .slice(0, 122) + "..."
        end

        def bold(text)
          term = Term::ANSIColor
          term.cyan text
        end

        #
        # Resposible for getting the date from the user.
        #
        # @param terminal [HighLine] The current HighLine instance.
        # @param db [MovieDb::Db] A MovieDb::Db instance.
        # @param title [String] The chosen title.
        #
        # @return [String] The chosen title.
        def get_review(title = nil)
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
  end
end
