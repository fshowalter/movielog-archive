module Movielog
  #
  # Responsible for providing template helper methods.
  #
  module Helpers
    def text_filter(placeholder, attribute)
      options = {}
      options['placeholder'] = placeholder
      options['class'] = 'filter-text-box'
      options['data'] = {}
      options['data']['filter-attribute'] = attribute
      options['data']['filter-type'] = 'text'

      field_tag = text_field_tag(attribute, options)

      filter_control(content_tag(:div, field_tag, class: 'search-wrap clearable-wrap'))
    end
  end
end
