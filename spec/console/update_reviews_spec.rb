require 'spec_helper'
require 'support/io_helper'

describe Movielog::Console::UpdateReviews do
  before(:each) do
  end

  it 'calls Movielog::Db::UpdateMostReviewedTables' do
    expect(Movielog::Db::UpdateMostReviewedTables).to receive(:call).and_return(true)

    Movielog::Console::UpdateReviews.call
  end

end
