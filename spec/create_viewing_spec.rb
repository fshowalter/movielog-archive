# frozen_string_literal: true
require 'spec_helper'

describe Movielog::CreateViewing do
  let(:movie) do
    OpenStruct.new(title: 'Test Movie', display_title: 'Test Movie Display (I)')
  end

  it('creates review') do
    allow(File).to receive(:open).with('test-viewings-path' + '/0012-test-movie-display-i.yml', 'w')

    expect(Movielog::CreateViewing.call(
      viewings_path: 'test-viewings-path',
      sequence: 12,
      movie: movie,
      date: Date.parse('208-03-12'),
      venue: 'Blu-ray',
    ).to_h).to eq(
      number: 12,
      db_title: 'Test Movie',
      title: 'Test Movie Display (I)',
      date: Date.parse('208-03-12'),
      venue: 'Blu-ray',
    )
  end
end
