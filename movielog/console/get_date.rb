module Movielog
  module Console
    class GetDate
      class << self
        def call(prompt: 'Date', default: Date.today.to_s)
          date = nil

          while date.nil?
            entered_date = Ask.input prompt, default: default
            next unless (entered_date = Date.parse(entered_date))

            date = entered_date if Ask.confirm entered_date.strftime('%A, %B %d, %Y?  ')
          end

          date
        end
      end
    end
  end
end
