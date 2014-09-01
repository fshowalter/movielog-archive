module Movielog
  module Console
    #
    # Responsible for formatting as bold for the console.
    #
    class Bold
      class << self
        def call(text: text)
          term = Term::ANSIColor
          term.cyan text
        end
      end
    end
  end
end
