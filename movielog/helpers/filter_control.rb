module Movielog
  #
  # Responsible for providing template helper methods.
  #
  module Helpers
    def call(control: control, label: nil)
      label = filter_control_label(label) if label

      content_tag(:div, class: 'filter-control') do
        [
          label,
          control
        ].join.html_safe
      end
    end
  end
end
