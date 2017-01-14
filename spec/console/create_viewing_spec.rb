# frozen_string_literal: true
require 'spec_helper'
require 'support/io_helper'

describe Movielog::Console::CreateViewing do
  let(:movie) do
    OpenStruct.new(display_title: 'Test Movie')
  end

  let(:venues) do
    [
      'Nextflix',
    ]
  end

  before(:each) do
    IOHelper.clear
  end

  it 'calls Movielog::CreateViewing with correct data' do
    expect(Movielog).to receive(:headline_cast_for_movie).with(movie: movie).and_return(
      [
        OpenStruct.new(first_name: 'Person', last_name: '1'),
      ],
    )
    expect(Movielog).to receive(:aka_titles_for_movie).with(movie: movie).and_return(['aka title'])

    query_proc = ->(_query) { [movie] }

    IOHelper.type_input('Test Movie')
    IOHelper.select
    IOHelper.type_input('2014-08-30')
    IOHelper.confirm
    IOHelper.move_down
    IOHelper.select
    IOHelper.type_input('Blu-ray')
    IOHelper.confirm

    expect(Movielog::Console::CreateViewing).to receive(:puts).twice

    expect(Movielog::CreateViewing).to receive(:call).with(
      movie: movie,
      date: Date.parse('2014-08-30'),
      venue: 'Blu-ray',
    ).and_return(OpenStruct.new(number: 'new-sequence-number'))

    Movielog::Console::CreateViewing.call(query_proc: query_proc, venues: venues)
  end
end
