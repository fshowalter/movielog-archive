module Movielog
  #
  # Responsible for providing template helper methods.
  #
  module Helpers
    def filter_control_label(label)
      label_tag(label, class: 'filter-label', for: filter_control_attribute(label))
    end
  end
end
