# frozen_string_literal: true
require 'inquirer'
require 'awesome_print'

module Movielog
  module Console
    #
    # Responsible for providing a console interface to create new pages.
    #
    class CreatePage
      class << self
        #
        # Responsible for processing a new page command.
        #
        # @return [OpenStruct] the new page data.
        def call
          title = ask_for_title
          page = Movielog::CreatePage.call(title: title)

          puts "\n Created Page #{Bold.call(text: page.title)}!\n"
          ap(page.to_h, ruby19_syntax: true)

          page
        end

        private

        def ask_for_title
          title = nil

          while title.nil?
            entered_title = Ask.input 'Page Title'
            title = entered_title if Ask.confirm entered_title
          end

          title
        end
      end
    end
  end
end
