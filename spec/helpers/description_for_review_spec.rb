require 'spec_helper'
require 'support/stub_template_context'

describe Movielog::Helpers do
  let(:context) { stub_template_context }
  describe '#description_for_review' do
    let(:review) { OpenStruct.new(display_title: 'Rio Bravo (1959)') }
    let(:headline_cast) do
      [
        OpenStruct.new(first_name: 'John', last_name: 'Wayne'),
        OpenStruct.new(first_name: 'Dean', last_name: 'Martin'),
        OpenStruct.new(first_name: 'Ricky', last_name: 'Nelson')
      ]
    end

    it 'returns a the description for a review' do
      expect(context.description_for_review(
        review: review, aka_titles: [], headline_cast: headline_cast)).to eq(
          'A review of the movie Rio Bravo (1959) ' \
          'starring John Wayne, Dean Martin, and Ricky Nelson.')
    end

    context 'when review has aka titles' do
      it 'returns a description with aka titles' do
        aka_titles = ['Howard Hawks\' Rio Bravo (1959)']
        expect(context.description_for_review(
          review: review, aka_titles: aka_titles, headline_cast: headline_cast)).to eq(
            'A review of the movie Rio Bravo (1959) '\
            '(also known as Howard Hawks\' Rio Bravo (1959)) ' \
            'starring John Wayne, Dean Martin, and Ricky Nelson.')
      end
    end
  end
end
