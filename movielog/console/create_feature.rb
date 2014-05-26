require 'inquirer'

module Movielog
  #
  # Namespace for movielog console use-cases.
  #
  module Console
    #
    # Responsible for providing a command-line interface to create new viewings.
    #
    class CreateViewing
      class << self
        #
        # Responsible for processing a new viewing command.
        #
        # @return [String] The full path to the new entry.
        def call
          loop do
            title = get_title
            feature_hash = {
              title: title,
              date: Date.today,
            }

            Movielog::App.create_feature(feature_hash)

            puts "\n Created Feature ##{bold(viewing_hash[:number].to_s)}!\n" +
            " #{bold('        Title:')} #{viewing_hash[:title]}\n" +
            " #{bold('         Date:')} #{viewing_hash[:date]}\n"
          end
        end

        private

        def bold(text)
          term = Term::ANSIColor
          term.cyan text
        end

        #
        # Resposible for getting the date from the user.
        #
        # @param terminal [HighLine] The current HighLine instance.
        # @param db [MovieDb::Db] A MovieDb::Db instance.
        # @param title [String] The chosen title.
        #
        # @return [String] The chosen title.
        def get_title(title = nil, display_title = nil)
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
