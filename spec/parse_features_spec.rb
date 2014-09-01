require 'spec_helper'
require 'support/stub_files_helper'

describe Movielog::ParseFeatures do
  let(:files) do
    {
      'feature1.md' => <<-EOF,
---
:sequence: 1
:title: Feature 1
:slug: feature-1
:date: 2014-07-01
:description: >
  Wherin I test the parse features feature.
---
Feature 1 content.
      EOF

      'feature2.md' => <<-EOF
---
:sequence: 2
:title: Feature 2
:slug: feature-2
:date: 2014-07-01
:description: >
  Wherin I continue to test the parse features feature.
---
Feature 2 content.
      EOF
    }
  end

  it 'reads features from the given directory' do
    stub_files(files: files, path: 'test_features_path/*.md')

    features = Movielog::ParseFeatures.call(features_path: 'test_features_path')

    expect(features.length).to eq 2

    expect(features[1].title).to eq 'Feature 1'
    expect(features[1].sequence).to eq 1
    expect(features[1].content).to eq "Feature 1 content.\n"

    expect(features[2].title).to eq 'Feature 2'
    expect(features[2].sequence).to eq 2
    expect(features[2].content).to eq "Feature 2 content.\n"
  end

  context 'when error parsing yaml' do
    let(:bad_files) do
      {
        'feature1.md' => <<-EOF,
---
:sequence: 1
1:bad
---
Feature 1 content.
        EOF
      }
    end

    it 'writes an error message' do
      stub_files(files: bad_files, path: 'test_features_path/*.md')

      expect(Movielog::ParseFeatures).to receive(:puts) do |arg|
        expect(arg).to start_with('YAML Exception reading feature1.md:')
      end

      Movielog::ParseFeatures.call(features_path: 'test_features_path')
    end
  end

  context 'when error reading file' do
    let(:bad_file) do
      {
        'feature1.md' => <<-EOF,
---
:bad_file: true
---
Feature 1 content.
      EOF

        'feature2.md' => <<-EOF
---
:sequence: 2
:title: Feature 2
:slug: feature-2
:date: 2014-07-01
:description: >
  Wherin I continue to test the parse features feature.
---
Feature 2 content.
        EOF
      }
    end
    it 'writes an error message' do
      stub_files(files: bad_file, path: 'test_features_path/*.md')

      original_load = YAML.method(:load)
      expect(YAML).to receive(:load).with("---\n:bad_file: true\n").and_raise(RuntimeError)
      expect(YAML).to receive(:load) do |args|
        original_load.call(args)
      end

      expect(Movielog::ParseFeatures).to receive(:puts)
        .with('Error reading file feature1.md: RuntimeError')

      Movielog::ParseFeatures.call(features_path: 'test_features_path')
    end
  end
end
