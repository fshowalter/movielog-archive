require 'inquirer'

module Movielog
  module Console
    #
    # Responsible for providing a console interface to create new features.
    #
    class CreateFeature
      class << self
        #
        # Responsible for processing a new feature command.
        #
        # @return [Movielog::Feature] the new feature.
        def call
          feature = Movielog.create_feature(title: get_feature_title)

          puts "\n Created Feature #{Bold.call(text: feature.title)}!\n" \
          " #{Bold.call(text: '     Sequence:')} #{feature.sequence}\n"

          feature
        end

        private

        def get_feature_title
          title = nil

          while title.nil?
            entered_title = Ask.input 'Feature Title'
            title = entered_title if Ask.confirm entered_title
          end

          title
        end
      end
    end
  end
end
