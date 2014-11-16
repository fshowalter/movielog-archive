"use strict"

$ = window.jQuery

class RangeFilter
  constructor: (element, options) ->
    @$element = $(element)
    @options = $.extend({}, RangeFilter.DEFAULTS, options)
    @attribute = @options.filterAttribute
    sliderElement = @$element.find('.noUiSlider')
    @slider = sliderElement.noUiSlider
      range: { min: @options.filterMinValue, max: @options.filterMaxValue }
      start: [@options.filterMinValue, @options.filterMaxValue]
      step: 1
      format:
        to: (value) ->
          value
        from: (value) ->
          value

    @slider.on('set', => @$element.trigger $.Event @options.changeEventName)
    sliderElement.Link('lower').to($('.filter-numeric.min'));
    sliderElement.Link('upper').to($('.filter-numeric.max'));

  @DEFAULTS =
    filterAttribute: 'text'
    filterMinValue: 1
    filterMaxValue: 10
    changeEventName: 'filter-changed.movielog'
    onSlide: ->
      values = @slider.val()
      @$element.find('.filter-range__min').text values[0]
      @$element.find('.filter-range__max').text values[1]

  matcher: ->
    range = @slider.val()
    return null if range[0] is @options.filterMinValue and range[1] is @options.filterMaxValue
    return (item) =>
      value = parseInt item.getAttribute(@attribute)
      # console.log range
      (value >= range[0] && value <= range[1])

###
RANGEFILTER PLUGIN DEFINITION
###
old = $.fn.rangeFilter

$.fn.rangeFilter = (option) ->
  @each ->
    $this = $(@)
    data = $this.data('movielog.filter')
    options = $.extend({}, RangeFilter.DEFAULTS, $this.data(), typeof option == 'object' && option)

    $this.data('movielog.filter', (data = new RangeFilter(@, options))) unless data
    data[option]() if typeof option == 'string'

$.fn.rangeFilter.Constructor = RangeFilter

###
RANGEFILTER NO CONFLICT
###
$.fn.rangeFilter.noConflict = ->
  $.fn.rangeFilter = old
  this

###
RANGEFILTER DATA-API
###
$(document).on("mousedown.range-filter.movielog.data-api MSPointerDown.range-filter.movielog.data-api touchstart.range-filter.movielog.data-api", "[data-filter-type='range']", (e)->
  $this = $(@)
  if !$this.data('movielog.filter')
    e.preventDefault()
    $this.rangeFilter();
    $(e.target).trigger(e)
)

$(document).on("keydown.range-filter.movielog.data-api", "[data-filter-type='range']", (e) ->
  $this = $(@)
  if !$this.data('movielog.filter') && e.which != 9
    # e.preventDefault()
    $this.rangeFilter();
    $(e.target).trigger 'keydown', e
    $(e.target).trigger 'keyup', e
)