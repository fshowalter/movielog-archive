# frozen_string_literal: true
require 'spec_helper'
require 'support/io_helper'

describe Movielog::Console::CreateReview do
  let(:movie) do
    OpenStruct.new(display_title: 'Test Movie')
  end

  before(:each) do
    IOHelper.clear
  end

  it 'calls Movielog::CreateReview with correct data' do
    expect(Movielog).to receive(:headline_cast_for_movie).with(movie: movie).and_return(
      [
        OpenStruct.new(first_name: 'Person', last_name: '1'),
      ],
    )
    expect(Movielog).to receive(:aka_titles_for_movie).with(movie: movie).and_return(['aka title'])

    query_proc = ->(_query) { [movie] }

    IOHelper.type_input('Test Movie')
    IOHelper.select

    expect(Movielog::Console::CreateReview).to receive(:puts).twice

    expect(Movielog::CreateReview).to receive(:call).with(movie: movie).and_return(OpenStruct.new(sequence: 1))

    Movielog::Console::CreateReview.call(query_proc: query_proc)
  end
end
