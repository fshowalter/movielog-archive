require 'spec_helper'
require 'support/stub_template_context'

describe Movielog::Helpers do
  let(:context) { stub_template_context }
  describe '#description_for_review' do
    let(:review) { OpenStruct.new(display_title: 'Rio Bravo (1959)') }

    it 'returns a the description for a review' do
      expect(context.description_for_review(review: review, aka_titles: [])).to eq(
        'A review of Rio Bravo (1959).')
    end

    context 'when review has aka titles' do
      it 'returns a description with aka titles' do
        aka_titles = ['Howard Hawks\' Rio Bravo (1959)']
        expect(context.description_for_review(review: review, aka_titles: aka_titles)).to eq(
        'A review of Rio Bravo (1959), also known as Howard Hawks\' Rio Bravo (1959).')
      end
    end
  end
end
