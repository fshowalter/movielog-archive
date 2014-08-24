module Movielog
  module Console
    #
    # Responsible for providing a console interface to create new features.
    #
    class CreateFeature
      class << self
        #
        # Responsible for providing a console interface to create a new feature.
        #
        # @return [void]
        def call
          require 'inquirer'

          loop do
            feature_hash = { title: get_title, date: get_date }

            Movielog::App.create_feature(feature_hash)

            puts "\n Created Feature ##{bold(feature_hash[:number].to_s)}!\n" \
            " #{bold('        Title:')} #{feature_hash[:title]}\n" \
            " #{bold('         Date:')} #{feature_hash[:date]}\n"
          end
        end

        private

        def bold(text)
          term = Term::ANSIColor
          term.cyan text
        end

        def get_title(title = nil, _display_title = nil)
          while title.nil?
            entered_title = Ask.input 'Feature Title'
            title = entered_title if Ask.confirm entered_title
          end

          title
        end

        def get_date(default = Date.today.to_s)
          date = nil

          while date.nil?
            entered_date = Ask.input 'Date', default: default
            next unless (entered_date = Date.parse(entered_date))

            date = entered_date if Ask.confirm entered_date.strftime('%A, %B %d, %Y?  ')
          end

          date
        end
      end
    end
  end
end
