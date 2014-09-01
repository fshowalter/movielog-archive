require 'spec_helper'
require 'support/io_helper'

describe Movielog::Console::CreateFeature do
  before(:each) do
    IOHelper.clear
    allow(File).to receive(:open).with(Movielog.features_path + '/test-feature.md', 'w')
  end

  it 'creates features with titles and date' do
    IOHelper.type_input('test feature')
    IOHelper.confirm

    expect(Movielog::Console::CreateFeature).to(receive(:puts))
    expect(Movielog).to receive(:next_post_number).and_return(2)

    feature = Movielog::Console::CreateFeature.call

    expect(feature.title).to eq 'test feature'
    expect(feature.sequence).to eq 2
    expect(feature.slug).to eq 'test-feature'
  end

end
