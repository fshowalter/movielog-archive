# frozen_string_literal: true
require 'spec_helper'
require 'support/io_helper'

describe Movielog::Console::CreateReview do
  let(:movie) do
    OpenStruct.new(title: 'Test Movie')
  end

  before(:each) do
    IOHelper.clear
  end

  it 'calls Movielog::CreateReview with correct data' do
    expect(Movielog::Console::AskForMovie).to receive(:call).and_return(movie)
    expect(Movielog::Console::CreateReview).to receive(:puts).twice

    IOHelper.type_input('Test Movie')
    IOHelper.select

    expect(Movielog::CreateReview).to receive(:call).with({
      movie: movie,
    }).and_return(OpenStruct.new(sequence: 1))

    Movielog::Console::CreateReview.call(db: OpenStruct.new(), viewed_db_titles: [])
  end
end
