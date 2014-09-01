# require 'spec_helper'
# require 'support/io_helper'
# require 'google/api_client'
# require 'google/api_client/client_secrets'
# require 'google/api_client/auth/installed_app'
# require 'ostruct'

# describe Movielog::Console::CreateFeature do
#   before(:each) do
#     IOHelper.clear
#     stub_google_auth
#   end

#   def stub_google_auth
#     FakeWeb.register_uri(
#       :post, 'https://accounts.google.com/o/oauth2/token', status: 200, body: '{}')
#     FakeWeb.register_uri(
#       :get,
#       'https://www.googleapis.com/discovery/v1/apis/urlshortener/v1/rest',
#       status: 200,
#       body: { resources: { url: { methods: { list: 'list' }}}}.to_json
#     )

#     expect(Launchy).to receive(:open) do
#       spawn('sleep 1 && curl http://localhost:9292/?code=testcode')
#     end
#   end

#   def stub_google_client
#     client = double(Google::APIClient)
#     expect(Google::APIClient).to receive(:new).and_return(client)

#     expect(client).to receive(:authorization=)

#     expect(client).to receive(:discovered_api).with('urlshortener') do
#       OpenStruct.new(url: OpenStruct.new(list: 'list', insert: 'insert'))
#     end

#     expect(client).to receive(:execute).with(api_method: 'list') do
#       OpenStruct.new(data: {
#         'items' => [OpenStruct.new(id: '57', long_url: 'http://some.other.url')]
#         })
#     end

#     expect(client).to receive(:execute).with(
#       api_method: 'insert',
#       body_object: {
#         longUrl: 'http://www.franksmovielog.com/reviews/rio-bravo-1959'
#       }) do
#       OpenStruct.new(data: OpenStruct.new(id: 67))
#     end

#     flow = double(Google::APIClient::InstalledAppFlow)
#     expect(Google::APIClient::InstalledAppFlow).to receive(:new).and_return(flow)
#     expect(flow).to receive(:authorize)
#   end

#   def stub_twitter_client
#     expect(Twitter::REST::Client).to receive(:new)
#   end

#   def stub_db
#     db = double(SQLite3::Database)
#     expect(Movielog).to receive(:db).and_return(db)
#     db
#   end

#   def stub_search(db, query)
#     result = yield
#     expect(Movielog).to receive(:search_for_reviewed_title).with(db, query) { result }
#   end

#   def stub_headline_cast(db, title)
#     result = yield

#     expect(MovieDb).to receive(:headline_cast_for_title).with(db, title) { result }
#   end

#   def stub_aka_titles(db, title)
#     result = yield

#     expect(MovieDb).to receive(:aka_titles_for_title).with(db, title) { result }
#   end

#   it 'creates features with titles and date' do
#     db = stub_db

#     stub_search(db, 'rio bravo') do
#       [
#         OpenStruct.new(title: 'Rio Bravo (1959)', display_title: '!Rio Bravo (1959)')
#       ]
#     end

#     stub_headline_cast(db, 'Rio Bravo (1959)') do
#       [
#         OpenStruct.new(first_name: 'John', last_name: 'Wayne'),
#         OpenStruct.new(first_name: 'Dean', last_name: 'Martin'),
#         OpenStruct.new(first_name: 'Ricky', last_name: 'Nelson')
#       ]
#     end

#     stub_aka_titles(db, 'Rio Bravo (1959)') do
#       ["Howard Hawks' Rio Bravo"]
#     end

#     IOHelper.type_input('rio bravo')
#     IOHelper.type_input("\r")

#     expect(Movielog).to receive(:reviews_by_title) do
#       {
#         'Rio Bravo (1959)' => OpenStruct.new({
#           title: 'Rio Bravo (1959)',
#           slug: 'rio-bravo-1959',
#           display_title: 'Rio Bravo (1959)',
#           grade: 'A+'
#         })
#       }
#     end

#     expect(Movielog::Console::CreateReviewTweet).to(receive(:puts))
#     expect(stub_twitter_client).to receive(:update).with('bob')

#     Movielog::Console::CreateReviewTweet.call
#   end

# end
