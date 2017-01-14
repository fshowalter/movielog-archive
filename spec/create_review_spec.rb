# frozen_string_literal: true
require 'spec_helper'

describe Movielog::CreateReview do
  let(:movie) do
    OpenStruct.new(title: 'Test Movie', display_title: 'Test Movie Display (I)')
  end

  it('creates review') do
    allow(File).to receive(:open).with('test-reviews-path' + '/test-movie-display-i.md', 'w')

    expect(Movielog::CreateReview.call(
      reviews_path: 'test-reviews-path',
      sequence: 12,
      movie: movie,
    ).to_h).to eq(
      sequence: 12,
      db_title: 'Test Movie',
      title: 'Test Movie Display (I)',
      slug: 'test-movie-display-i',
      date: Date.today,
      imdb_id: '',
      grade: '',
      backdrop: '',
      backdrop_placeholder: nil,
    )
  end
end
