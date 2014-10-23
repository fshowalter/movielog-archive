require 'spec_helper'
require 'support/io_helper'

describe Movielog::Console::CreateReviewTweet do
  let(:db) do
    titles = {
      'Rio Bravo (1959)' => {
        title: 'Rio Bravo (1959)',
        display_title: 'Rio Bravo (1959)',
        year: '1959',
        sortable_title: 'Rio Bravo (1959)',
        aka_titles: ["Howard Hawks' Rio Bravo"]
      }
    }

    cast_and_crew = {
      'Dickinson, Angie' => {
        full_name: 'Dickinson, Angie',
        last_name: 'Dickinson',
        first_name: 'Angie',
        annotation: nil,
        performer_credits: [
          { title: 'Rio Bravo (1959)',
            notes: nil,
            role: 'Feathers',
            position_in_credits: '4'
          }]
      },
      'Martin, Dean' => {
        full_name: 'Martin, Dean',
        last_name: 'Martin',
        first_name: 'Dean',
        annotation: nil,
        performer_credits: [
          { title: 'Rio Bravo (1959)',
            notes: nil,
            role: "Dude ('Borachón')",
            position_in_credits: '2'
          }]
      },
      'Wayne, John' => {
        full_name: 'Wayne, John',
        last_name: 'Wayne',
        first_name: 'John',
        annotation: nil,
        performer_credits: [
          { title: 'Rio Bravo (1959)',
            notes: nil,
            role: 'Sheriff John T. Chance',
            position_in_credits: '1'
          }]
      },
      'Nelson, Ricky' => {
        full_name: 'Nelson, Ricky',
        last_name: 'Nelson',
        first_name: 'Ricky',
        annotation: nil,
        performer_credits: [
          { title: 'Rio Bravo (1959)',
            notes: nil,
            role: 'Colorado Ryan',
            position_in_credits: '3'
          }]
      }
    }

    stub_movie_db(titles: titles, cast_and_crew: cast_and_crew)
  end

  before(:each) do
    IOHelper.clear
    allow(Movielog).to receive(:db).and_return(db)
  end

  it 'creates review' do
    IOHelper.type_input('rio bravo')
    IOHelper.type_input("\r")

    expect(Movielog::Console::CreateReviewTweet).to(receive(:puts))

    expect(Movielog).to receive(:reviewed_titles) do
      [
        'Rio Bravo (1959)',
        'Reservoir Dogs (1992)',
        'The Big Sleep (1946)'
      ]
    end

    expect(Movielog).to receive(:reviews) do
      {
        1 => OpenStruct.new(
                              title: 'Rio Bravo (1959)',
                              slug: 'rio-bravo-1959',
                              display_title: 'Rio Bravo (1959)',
                              grade: 'A+'
                            )
      }
    end

    expect(Movielog::ShortenUrl).to(receive(:call)
      .with(url: 'http://www.franksmovielog.com/reviews/rio-bravo-1959/')
      .and_return('http://short.url'))

    FakeWeb.register_uri(
      :post,
      'https://api.twitter.com/1.1/statuses/update.json',
      status: 200,
      body: { id: 1 }.to_json)

    tweet = Movielog::Console::CreateReviewTweet.call
    expect(tweet).to eq(
      'RIO BRAVO (1959) (★★★★★) John Wayne, Dean Martin, Ricky Nelson...http://short.url')
  end
end
