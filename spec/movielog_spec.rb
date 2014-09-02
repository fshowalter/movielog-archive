require 'spec_helper'

describe Movielog do
  describe '#next_viewing_number' do
    it 'returns the number of viewings plus one' do
      expect(Movielog::ParseViewings).to(
        receive(:call).with(viewings_path: Movielog.viewings_path)) do
        {
          1 => 'a viewing',
          2 => 'another viewing'
        }
      end

      expect(Movielog.next_viewing_number).to eq 3
    end
  end

  describe '#next_post_number' do
    it 'returns the number of reviews and features plus one' do
      expect(Movielog::ParseReviews).to(
        receive(:call).with(reviews_path: Movielog.reviews_path)) do
        {
          1 => 'a review',
          3 => 'another review'
        }
      end

      expect(Movielog::ParseFeatures).to(
        receive(:call).with(features_path: Movielog.features_path)) do
        {
          2 => 'a feature'
        }
      end

      expect(Movielog.next_post_number).to eq 4
    end
  end

  describe '#db' do
    it 'returns a new movie_db instance' do
      expect(Movielog.db).to be_an_instance_of(SQLite3::Database)
    end
  end

  describe '#viewed_titles' do
    it 'returns a unique collection of viewed titles' do
      expect(Movielog::ParseViewings).to(
        receive(:call).with(viewings_path: Movielog.viewings_path)) do
        {
          1 => OpenStruct.new(title: 'Rio Bravo (1959)'),
          2 => OpenStruct.new(title: 'The Big Sleep (1946)'),
          3 => OpenStruct.new(title: 'Reservoir Dogs (1992)'),
          4 => OpenStruct.new(title: 'North by Northwest (1959)'),
          5 => OpenStruct.new(title: 'Rio Bravo (1959)'),
          6 => OpenStruct.new(title: 'Some Like it Hot (1959)')
        }
      end

      expect(Movielog.viewed_titles).to match_array([
        'Rio Bravo (1959)',
        'The Big Sleep (1946)',
        'Reservoir Dogs (1992)',
        'North by Northwest (1959)',
        'Some Like it Hot (1959)'
      ])
    end
  end

  describe '#reviewed_titles' do
    it 'returns a unique collection of reviewed titles' do
      expect(Movielog::ParseReviews).to(
        receive(:call).with(reviews_path: Movielog.reviews_path)) do
        {
          1 => OpenStruct.new(title: 'Rio Bravo (1959)'),
          2 => OpenStruct.new(title: 'The Big Sleep (1946)'),
          3 => OpenStruct.new(title: 'Reservoir Dogs (1992)'),
          4 => OpenStruct.new(title: 'North by Northwest (1959)'),
          5 => OpenStruct.new(title: 'Rio Bravo (1959)'),
          6 => OpenStruct.new(title: 'Some Like it Hot (1959)')
        }
      end

      expect(Movielog.reviewed_titles).to match_array([
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
      expect(Movielog::ParseViewings).to(
        receive(:call).with(viewings_path: Movielog.viewings_path)) do
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

  describe '#viewings_for_title' do
    it 'returns a collection of viewings for the given title' do
      expect(Movielog::ParseViewings).to(
        receive(:call).with(viewings_path: Movielog.viewings_path)) do
        {
          1 => OpenStruct.new(title: 'Rio Bravo (1959)', sequence: 1),
          2 => OpenStruct.new(title: 'The Big Sleep (1946)', sequence: 2),
          3 => OpenStruct.new(title: 'Reservoir Dogs (1992)', sequence: 3),
          4 => OpenStruct.new(title: 'North by Northwest (1959)', sequence: 4),
          5 => OpenStruct.new(title: 'Rio Bravo (1959)', sequence: 5),
          6 => OpenStruct.new(title: 'Some Like it Hot (1959)', sequence: 6)
        }
      end

      viewings = Movielog.viewings_for_title(title: 'Rio Bravo (1959)')
      expect(viewings.length).to eq 2
      expect(viewings.first.title).to eq 'Rio Bravo (1959)'
      expect(viewings.first.sequence).to eq 1
      expect(viewings.last.title).to eq 'Rio Bravo (1959)'
      expect(viewings.last.sequence).to eq 5
    end
  end
end
