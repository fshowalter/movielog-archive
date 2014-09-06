require 'spec_helper'
require 'support/stub_template_context'

describe Movielog::Helpers do
  let(:context) { stub_template_context }
  describe '#text_filter' do
    it 'returns a javascript range filter' do
      filter = context.text_filter(
          placeholder: 'Search Titles', attribute: 'data-title')
      expect(filter).to eq(
        "<div class=\"filter-control\">" \
        "<div class=\"search-wrap clearable-wrap\">" \
        "<input type=\"text\" name=\"data-title\" " \
        "placeholder=\"Search Titles\" class=\"filter-text-box\" " \
        "data-filter-attribute=\"data-title\" data-filter-type=\"text\" /></div></div>")
    end
  end
end
