module Movielog
  #
  # Responsible for providing template helper methods.
  #
  module Helpers
    def filter_control_attribute(text)
      text.downcase.gsub(' ', '-')
    end
  end
end
