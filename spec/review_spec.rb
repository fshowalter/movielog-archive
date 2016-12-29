# frozen_string_literal: true
require 'spec_helper'

describe Movielog::Review do
  describe '#title_without_year' do
    it 'returns the title without the year' do
      review = Movielog::Review.new(
        sequence: 1,
        db_title: 'Fright Night (1985)',
        title: 'Fright Night (1985)',
        slug: 'fright-night-1985',
        date: '06-07-1985',
        imdb_id: 'tt1233456',
        grade: 'A+',
        backdrop: 'https://image.url',
        backdrop_placeholder: 'placeholder_content',
        content: 'review'
      )
      expect(review.title_without_year).to eq 'Fright Night'
    end

    describe 'when year has roman numeral annotation' do
      it 'returns the title without the year' do
        review = Movielog::Review.new(
          sequence: 1,
          db_title: 'She (1965/I)',
          title: 'She (1965/I)',
          slug: 'she-1965-i',
          date: '06-07-1965',
          imdb_id: 'tt1233456',
          grade: 'C',
          backdrop: 'https://image.url',
          backdrop_placeholder: 'placeholder_content',
          content: 'review'
        )
        expect(review.title_without_year).to eq 'She'
      end
    end
  end

  describe '#year' do
    it 'returns the year' do
      review = Movielog::Review.new(
        sequence: 1,
        db_title: 'Fright Night (1985)',
        title: 'Fright Night (1985)',
        slug: 'fright-night-1985',
        date: '06-07-1985',
        imdb_id: 'tt1233456',
        grade: 'A+',
        backdrop: 'https://image.url',
        backdrop_placeholder: 'placeholder_content',
        content: 'review'
      )
      expect(review.year).to eq '1985'
    end

    describe 'when year has roman numeral annotation' do
      it 'returns the year without annotation' do
        review = Movielog::Review.new(
          sequence: 1,
          db_title: 'She (1965/I)',
          title: 'She (1965/I)',
          slug: 'she-1965-i',
          date: '06-07-1965',
          imdb_id: 'tt1233456',
          grade: 'C',
          backdrop: 'https://image.url',
          backdrop_placeholder: 'placeholder_content',
          content: 'review'
        )
        expect(review.year).to eq '1965'
      end
    end
  end
end
