# frozen_string_literal: true
require 'spec_helper'
require 'support/io_helper'

describe Movielog::Console::CreatePage do
  before(:each) do
    IOHelper.clear
  end

  it 'calls Movielog::CreatePage with correct data' do
    IOHelper.type_input('Test Page')
    IOHelper.confirm

    expect(Movielog::Console::CreatePage).to(receive(:puts)).twice

    expect(Movielog::CreatePage).to receive(:call).with(
      title: 'Test Page',
    ).and_return(OpenStruct.new(title: 'New Page Title'))

    Movielog::Console::CreatePage.call
  end
end
