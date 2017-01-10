# frozen_string_literal: true
require 'spec_helper'

describe Movielog do
  describe '#site_url' do
    it 'returns the site url' do
      expect(Movielog.site_url).to eq 'https://www.franksmovielog.com'
    end
  end

  describe '#site_title' do
    it 'returns the site title' do
      expect(Movielog.site_title).to eq "Frank's Movie Log"
    end
  end

  describe '#next_viewing_number' do
    it 'returns the number of viewings plus one' do
      expect(Movielog).to(receive(:viewings)).and_return(1 => 'viewing 1', 2 => 'viewing 2')

      expect(Movielog.next_viewing_number).to eq 3
    end
  end

  describe '#movies' do
    it 'calls MovieDb.fetch_viewings' do
      expect(Movielog).to(receive(:viewed_db_titles)).and_return('viewed db titles')
      expect(MovieDb).to(receive(:fetch_movies)).and_return('fetch_viewings data')

      expect(Movielog.movies).to eq 'fetch_viewings data'
    end
  end

  describe '#viewings' do
    it 'calls Movielog::ParseViewings' do
      expect(Movielog::ParseViewings).to(receive(:call)).and_return('parse viewings data')

      expect(Movielog.viewings).to eq 'parse viewings data'
    end
  end

  describe '#reviews' do
    it 'calls Movielog::ParseReviews' do
      expect(Movielog::ParseReviews).to(receive(:call)).and_return('parse reviews data')

      expect(Movielog.reviews).to eq 'parse reviews data'
    end

    describe 'when #cache_reviews is true' do
      before(:each) do
        Movielog.cache_reviews = true
      end

      after(:each) do
        Movielog.cache_reviews = false
      end

      it 'caches reviews' do
        expect(Movielog::ParseReviews).to(receive(:call)).and_return('parse reviews data')

        expect(Movielog.reviews).to eq 'parse reviews data'

        expect(Movielog.instance_variable_get('@reviews')).to eq 'parse reviews data'
      end
    end
  end

  describe '#reviews_by_sequence' do
    it 'returns the reviews sorted by sequence in reverse' do
      expect(Movielog).to(receive(:reviews)) do
        {
          'title 1' => OpenStruct.new(db_title: 'title 1', sequence: 2),
          'title 2' => OpenStruct.new(db_title: 'title 2', sequence: 1)
        }
      end

      reviews_by_sequence = Movielog.reviews_by_sequence

      expect(reviews_by_sequence.first.db_title).to eq('title 1')
      expect(reviews_by_sequence.last.db_title).to eq('title 2')
    end

    describe 'when #cache_reviews is true' do
      before(:each) do
        Movielog.cache_reviews = true
      end

      after(:each) do
        Movielog.cache_reviews = false
      end

      it 'caches reviews_by_sequence' do
        expect(Movielog).to(receive(:reviews)) do
          {
            'title 1' => OpenStruct.new(db_title: 'title 1', sequence: 2),
            'title 2' => OpenStruct.new(db_title: 'title 2', sequence: 1)
          }
        end

        reviews_by_sequence = Movielog.reviews_by_sequence

        expect(reviews_by_sequence.first.db_title).to eq('title 1')
        expect(reviews_by_sequence.last.db_title).to eq('title 2')

        expect(Movielog.instance_variable_get('@reviews_by_sequence').length).to eq 2
      end
    end
  end

  describe '#db' do
    it 'returns a new movie_db instance' do
      expect(Movielog.db).to be_an_instance_of(SQLite3::Database)
    end
  end

  describe '#cast_and_crew' do
    it 'calls Movielog::Db::QueryMostReviewedPersons' do
      expect(Movielog::Db::QueryMostReviewedPersons).to receive(:call)

      Movielog.cast_and_crew
    end
  end

  describe '#viewed_db_titles' do
    it 'returns a unique collection of viewed titles' do
      expect(Movielog).to(receive(:viewings)) do
        {
          1 => OpenStruct.new(db_title: 'Rio Bravo (1959)'),
          2 => OpenStruct.new(db_title: 'The Big Sleep (1946)'),
          3 => OpenStruct.new(db_title: 'Reservoir Dogs (1992)'),
          4 => OpenStruct.new(db_title: 'North by Northwest (1959)'),
          5 => OpenStruct.new(db_title: 'Rio Bravo (1959)'),
          6 => OpenStruct.new(db_title: 'Some Like it Hot (1959)')
        }
      end

      expect(Movielog.viewed_db_titles).to match_array([
                                                         'Rio Bravo (1959)',
                                                         'The Big Sleep (1946)',
                                                         'Reservoir Dogs (1992)',
                                                         'North by Northwest (1959)',
                                                         'Some Like it Hot (1959)'
                                                       ])
    end
  end

  describe '#venues' do
    it 'returns a unique collection of venues' do
      expect(Movielog).to(receive(:viewings)) do
        {
          1 => OpenStruct.new(venue: 'Blu-ray'),
          2 => OpenStruct.new(venue: 'Amazon Instant'),
          3 => OpenStruct.new(venue: 'DVD'),
          4 => OpenStruct.new(venue: 'Blu-ray'),
          5 => OpenStruct.new(venue: 'Netflix Streaming')
        }
      end

      expect(Movielog.venues).to eq([
                                      'Amazon Instant',
                                      'Blu-ray',
                                      'DVD',
                                      'Netflix Streaming'
                                    ])
    end
  end

  describe '#viewings_for_db_title' do
    it 'returns a collection of viewings for the given title' do
      expect(Movielog).to(receive(:viewings)) do
        {
          1 => OpenStruct.new(db_title: 'Rio Bravo (1959)', sequence: 1),
          2 => OpenStruct.new(db_title: 'The Big Sleep (1946)', sequence: 2),
          3 => OpenStruct.new(db_title: 'Reservoir Dogs (1992)', sequence: 3),
          4 => OpenStruct.new(db_title: 'North by Northwest (1959)', sequence: 4),
          5 => OpenStruct.new(db_title: 'Rio Bravo (1959)', sequence: 5),
          6 => OpenStruct.new(db_title: 'Some Like it Hot (1959)', sequence: 6)
        }
      end

      viewings = Movielog.viewings_for_db_title(db_title: 'Rio Bravo (1959)')
      expect(viewings.length).to eq 2
      expect(viewings.first.db_title).to eq 'Rio Bravo (1959)'
      expect(viewings.first.sequence).to eq 1
      expect(viewings.last.db_title).to eq 'Rio Bravo (1959)'
      expect(viewings.last.sequence).to eq 5
    end
  end
end
