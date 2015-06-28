module Movielog
  #
  # Responsible for providing template helper methods.
  #
  module Helpers
    def sort_filter(label:, attribute:, target:, options:)
      html_options = {}
      html_options['class'] = 'filter-select'
      data = {}
      data['sorter'] = attribute
      data['target'] = target
      html_options['data'] = data
      html_options[:options] = options
      field_tag = select_tag(filter_control_attribute(attribute), html_options)
      filter_control(
        control: content_tag(:div, field_tag, class: 'filter-text-box-wrap'), label: label)
    end
  end
end
