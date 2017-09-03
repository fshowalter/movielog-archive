# frozen_string_literal: true

require 'tty-prompt'

module Movielog
  module Console
    #
    # Responsible for formatting as bold for the console.
    #
    class Ask
      class << self
        def input(text:)
          @prompt ||= TTY::Prompt.new

          @prompt.ask(text)
        end

        def select(prompt:, choices:)
          @prompt ||= TTY::Prompt.new

          @prompt.select(prompt, choices)
        end

        def confirm(prompt:)
          @prompt ||= TTY::Prompt.new

          @prompt.yes?(prompt)
        end
      end
    end
  end
end
