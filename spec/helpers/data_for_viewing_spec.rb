require 'spec_helper'
require 'support/stub_template_context'

describe Movielog::Helpers do
  let(:context) { stub_template_context }
  describe '#data_for_viewing' do
    it 'returns a data hash for the given viewing' do
      viewing = OpenStruct.new(
        sortable_title: 'Rio Bravo (1959)',
        release_date: Date.parse('1959-06-01'),
        date: '2011-03-12')

      expect(context.data_for_viewing(viewing: viewing)).to eq(

          data: {
            title: 'Rio Bravo (1959)',
            release_date: '1959-06-01',
            release_date_year: 1959,
            viewing_date: '2011-03-12'
          }
        )
    end
  end
end
