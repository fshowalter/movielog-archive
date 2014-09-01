class Movielog
  class ShortenUrl
    class << self
      def call(url: url)
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

      private

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
    end
  end
end
