# frozen_string_literal: true
require 'spec_helper'
require 'support/stub_template_context'

describe Movielog::Helpers do
  let(:context) { stub_template_context }
  describe '#data_for_viewing' do
    it 'returns a data hash for the given viewing' do
      expect(Movielog).to(
        receive(:venues).and_return(['test venue']),
      )

      expect(Movielog).to(
        receive(:movies).and_return('The Beyond (1980)' => MovieDb::Movie.new(
          'display_title' => 'The Beyond (1980)',
          'sortable_title' => 'Beyond, The (1980)',
          'release_date' => '1980-06-01',
        )),
      )

      viewing = Movielog::Viewing.new(
        number: 1,
        title: 'The Beyond (1980)',
        db_title: 'The Beyond (1980)',
        date: '2011-03-12',
        venue: 'test venue',
      )

      expect(context.data_for_viewing(viewing: viewing)).to eq(

        data: {
          title: 'The Beyond (1980)',
          sort_title: 'Beyond, The (1980)',
          release_date: '1980-06-01',
          release_date_year: 1980,
          viewing_date: '2011-03-12',
          venue: 0,
        },
      )
    end
  end
end
