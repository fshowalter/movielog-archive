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

  describe '#next_viewing_sequence' do
    it 'returns the number of viewings plus one' do
      viewings = [
        OpenStruct.new(number: 3),
        OpenStruct.new(number: 1),
      ]

      expect(Movielog.next_viewing_sequence(viewings: viewings)).to eq 3
    end
  end

  describe '#next_review_sequence' do
    it 'returns the max review sequence plus one' do
      reviews = {
        'review-1' => OpenStruct.new(sequence: 3),
        'review-2' => OpenStruct.new(sequence: 1),
      }

      expect(Movielog.next_review_sequence(reviews: reviews)).to eq 4
    end
  end

  describe '#movies' do
    it 'calls MovieDb.fetch_viewings' do
      expect(MovieDb).to(receive(:fetch_movies)).and_return('fetch_viewings data')

      expect(Movielog.movies(db_titles: [])).to eq 'fetch_viewings data'
    end
  end

  describe '#viewings' do
    it 'calls Movielog::ParseViewings' do
      expect(Movielog::ParseViewings).to(receive(:call)).and_return('parse viewings data')

      expect(Movielog.viewings).to eq 'parse viewings data'
    end
  end

  describe '#pages' do
    it 'calls Movielog::ParsePages' do
      expect(Movielog::ParsePages).to(receive(:call)).and_return('parse pages data')

      expect(Movielog.pages).to eq 'parse pages data'
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
    let(:reviews) do
      {
        'title 1' => OpenStruct.new(db_title: 'title 1', sequence: 2),
        'title 2' => OpenStruct.new(db_title: 'title 2', sequence: 1),
      }
    end

    it 'returns the reviews sorted by sequence in reverse' do
      reviews_by_sequence = Movielog.reviews_by_sequence(reviews: reviews)

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
        reviews_by_sequence = Movielog.reviews_by_sequence(reviews: reviews)

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
      viewings = [
        OpenStruct.new(db_title: 'Rio Bravo (1959)'),
        OpenStruct.new(db_title: 'The Big Sleep (1946)'),
        OpenStruct.new(db_title: 'Reservoir Dogs (1992)'),
        OpenStruct.new(db_title: 'North by Northwest (1959)'),
        OpenStruct.new(db_title: 'Rio Bravo (1959)'),
        OpenStruct.new(db_title: 'Some Like it Hot (1959)'),
      ]

      expect(Movielog.viewed_db_titles(viewings: viewings)).to match_array(
        [
          'Rio Bravo (1959)',
          'The Big Sleep (1946)',
          'Reservoir Dogs (1992)',
          'North by Northwest (1959)',
          'Some Like it Hot (1959)',
        ],
      )
    end
  end

  describe '#venues' do
    it 'returns a unique collection of venues' do
      viewings = [
        OpenStruct.new(venue: 'Blu-ray'),
        OpenStruct.new(venue: 'Amazon Instant'),
        OpenStruct.new(venue: 'DVD'),
        OpenStruct.new(venue: 'Blu-ray'),
        OpenStruct.new(venue: 'Netflix Streaming'),
      ]

      expect(Movielog.venues(viewings: viewings)).to eq(
        [
          'Amazon Instant',
          'Blu-ray',
          'DVD',
          'Netflix Streaming',
        ],
      )
    end
  end

  describe '#viewings_for_db_title' do
    it 'returns a collection of viewings for the given title' do
      viewings = [
        OpenStruct.new(db_title: 'Rio Bravo (1959)', number: 6),
        OpenStruct.new(db_title: 'The Big Sleep (1946)', number: 5),
        OpenStruct.new(db_title: 'Reservoir Dogs (1992)', number: 4),
        OpenStruct.new(db_title: 'North by Northwest (1959)', number: 3),
        OpenStruct.new(db_title: 'Rio Bravo (1959)', number: 2),
        OpenStruct.new(db_title: 'Some Like it Hot (1959)', number: 1),
      ]

      viewings = Movielog.viewings_for_db_title(viewings: viewings, db_title: 'Rio Bravo (1959)')

      expect(viewings.length).to eq 2
      expect(viewings.first.db_title).to eq 'Rio Bravo (1959)'
      expect(viewings.first.number).to eq 6
      expect(viewings.last.db_title).to eq 'Rio Bravo (1959)'
      expect(viewings.last.number).to eq 2
    end
  end

  describe '#search_viewed_titles' do
    let(:db) do
      OpenStruct.new(name: 'db')
    end

    let(:viewed_db_titles) do
      ['A Viewed Title']
    end

    it 'calls MovieDb.search_within_titles' do
      expect(MovieDb).to(receive(:search_within_titles)).with(
        db: db,
        titles: viewed_db_titles,
        query: 'test query',
      ).and_return('search_within_titles data')

      expect(Movielog.search_viewed_titles(
               db: db,
               viewed_db_titles: viewed_db_titles,
               query: 'test query',
      )).to eq 'search_within_titles data'
    end
  end

  describe '#search_for_movie' do
    let(:db) do
      OpenStruct.new(name: 'db')
    end

    it 'calls MovieDb.search_titles' do
      expect(MovieDb).to(receive(:search_titles)).with(
        db: db,
        query: 'test query',
      ).and_return('search_titles data')

      expect(Movielog.search_for_movie(
               db: db,
               query: 'test query',
      )).to eq 'search_titles data'
    end
  end

  describe '#headline_cast_for_movie' do
    let(:db) do
      OpenStruct.new(name: 'db')
    end

    let(:movie) do
      OpenStruct.new(title: 'db title', display_title: 'display title')
    end

    it 'calls MovieDb.headline_cast_for_title' do
      expect(MovieDb).to(receive(:headline_cast_for_title)).with(
        db: db,
        title: 'db title',
      ).and_return('headline_cast_for_title data')

      expect(Movielog.headline_cast_for_movie(
               db: db,
               movie: movie,
      )).to eq 'headline_cast_for_title data'
    end
  end

  describe '#aka_titles_for_movie' do
    let(:db) do
      OpenStruct.new(name: 'db')
    end

    let(:movie) do
      OpenStruct.new(title: 'db title', display_title: 'display title')
    end

    it 'calls MovieDb.aka_titles_for_title' do
      expect(MovieDb).to(receive(:aka_titles_for_title)).with(
        db: db,
        title: 'db title',
        display_title: 'display title',
      ).and_return('aka_titles_for_title data')

      expect(Movielog.aka_titles_for_movie(
               db: db,
               movie: movie,
      )).to eq 'aka_titles_for_title data'
    end
  end
end
