module FilterHelpers
  def filter_control(control, label = nil)
    if label
      label = filter_control_label(label)
    end

    content_tag(:div, class: "filter-control") do
      [
        label,
        control
      ].join.html_safe
    end
  end

  def sort_filter(label, attribute, target, options)
    html_options = {}
    html_options["class"] = "filter-select"
    data = {}
    data["sorter"] = attribute
    data["target"] = target
    html_options["data"] = data
    html_options[:options] = options
    field_tag = select_tag(filter_control_attribute(attribute), html_options)
    filter_control(content_tag(:div, field_tag, class: "sort-wrap"), label)
  end

  def oldest_year(collection, date_method)
    collection.map(&date_method).sort.first.year
  end

  def newest_year(collection, date_method)
    collection.map(&date_method).sort.reverse.first.year
  end

  def filter_control_label(label)
    label_tag(label, class: "filter-label", for: filter_control_attribute(label))
  end

  def filter_control_attribute(text)
    text.downcase.gsub(" ", "-")
  end

  def text_filter(placeholder, attribute)
    options = {}
    options["placeholder"] = placeholder
    options["class"] = "filter-text-box"
    options["data"] = {}
    options["data"]["filter-attribute"] = attribute
    options["data"]["filter-type"] = "text"

    field_tag = text_field_tag(attribute, options)

    filter_control(content_tag(:div, field_tag, class: "search-wrap clearable-wrap"))
  end

  def range_filter(label, attribute, min, max)
    data = {}
    data["filter-attribute"] = attribute
    data["filter-type"] = "range"
    data["filter-min-value"] = min
    data["filter-max-value"] = max
    options = {}
    options["class"] = "filter-range"
    options["data"] = data

    control = content_tag(:div, options) do
      [
        content_tag(:div, class: "noUiSlider noUi-target") do
          content_tag(:div, class: "noUi-base noUi-background noUi-horizontal") do
            [
              content_tag(:div, content_tag(:div, nil, class: "noUi-handle noUi-handle-lower"), class: "noUi-origin noUi-origin-lower", style: "left: 0%;"),
              content_tag(:div, content_tag(:div, nil, class: "noUi-handle noUi-handle-upper"), class: "noUi-origin noUi-origin-upper", style: "left: 100%;"),
            ].join.html_safe
          end
        end,
        content_tag(:div, min, class: "filter-range__min"),
        content_tag(:div, max, class: "filter-range__max")
      ].join.html_safe
    end

    # control = content_tag(:div, options) do
    #   content_tag(:div, nil, class: "noUiSlider")
    # end

    filter_control(control, label)
  end
end