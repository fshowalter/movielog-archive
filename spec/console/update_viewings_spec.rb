require 'spec_helper'
require 'support/io_helper'

describe Movielog::Console::UpdateViewings do
  before(:each) do
  end

  it 'calls Movielog::Db::UpdateMostWatchedTables' do
    expect(Movielog::Db::UpdateMostWatchedTables).to receive(:call).and_return(true)

    Movielog::Console::UpdateViewings.call
  end

end
