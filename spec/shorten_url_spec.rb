require 'spec_helper'
require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/installed_app'

describe Movielog::ShortenUrl do
  def stub_client
    client = double(Google::APIClient)
    expect(Google::APIClient).to receive(:new).and_return(client)
    client
  end

  def stub_client_authorization(client:)
    expect(Google::APIClient::ClientSecrets).to receive(:load) do
      OpenStruct.new(client_id: 'movielog', client_secret: 'movielog_secret')
    end

    expect(Google::APIClient::InstalledAppFlow).to receive(:new)
      .with(client_id: 'movielog',
            client_secret: 'movielog_secret',
            scope: ['https://www.googleapis.com/auth/urlshortener']) do
      OpenStruct.new(authorize: 'movielog_authorization')
    end

    expect(client).to receive(:authorization=).with('movielog_authorization')
  end

  def stub_api(client:, list_result: [], insert_url: nil, insert_result: nil)
    result = OpenStruct.new(data: { 'items' => list_result })
    api = OpenStruct.new(url: OpenStruct.new(list: 'api_list_url', insert: 'api_insert_url'))

    expect(client).to receive(:discovered_api).with('urlshortener').and_return(api)
    expect(client).to receive(:execute).with(api_method: 'api_list_url').and_return(result)

    allow(client).to receive(:execute).with(
      api_method: 'api_insert_url', body_object: { longUrl: insert_url }) do
      OpenStruct.new(data: OpenStruct.new(id: insert_result))
    end
  end

  it 'uses the Google API to shorten a url' do
    client = stub_client
    stub_client_authorization(client: client)

    stub_api(client: client, insert_url: 'long_url', insert_result: 'short_url')

    expect(Movielog::ShortenUrl.call(url: 'long_url')).to eq 'short_url'
  end

  context 'when url already exists' do
    it 'returns the short url' do
      client = stub_client
      stub_client_authorization(client: client)

      stub_api(client: client,
               list_result: [OpenStruct.new(id: 'existing_url', long_url: 'long_url')])

      expect(Movielog::ShortenUrl.call(url: 'long_url')).to eq 'existing_url'
    end
  end
end
