module Movielog
  module Console
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
