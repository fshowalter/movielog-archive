require 'active_support/core_ext/hash/slice'

module Movielog
  #
  # Responsible for creating new features.
  #
  class CreateFeature
    class << self
      def call(features_path:, title:, sequence:, slug:)
        file_name = new_feature_file_name(features_path, slug)

        front_matter = {
          title: title,
          sequence: sequence,
          slug: slug,
          date: Date.today
        }

        content = "#{front_matter.to_yaml}---\n"
        File.open(file_name, 'w') { |file| file.write(content) }

        Feature.new(front_matter)
      end

      private

      def new_feature_file_name(features_path, slug)
        File.join(features_path, slug + '.md')
      end
    end
  end
end
