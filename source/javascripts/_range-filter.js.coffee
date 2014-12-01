"use strict"

$ = window.jQuery

class RangeFilter
  constructor: (element, options) ->
    @$element = $(element)
    @options = $.extend({}, RangeFilter.DEFAULTS, @$element.data(), typeof options == 'object' && options)
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
      (value >= range[0] && value <= range[1])

newRangeFilter = (element) ->
  $this = $(element)
  data = $this.data('movielog.filter')
  $this.data('movielog.filter', (data = new RangeFilter($this))) unless data
  data

###
RANGEFILTER DATA-API
###
$(document).one("mousedown.range-filter.movielog.data-api MSPointerDown.range-filter.movielog.data-api touchstart.range-filter.movielog.data-api", "[data-filter-type='range']", (e)->
  e.preventDefault()
  newRangeFilter(@)
  $(e.target).trigger(e)
)

$(document).on("keydown.range-filter.movielog.data-api", "[data-filter-type='range']", (e) ->
  if e.which != 9
    $(document).off('keydown.range-filter.movielog.data-api')
    newRangeFilter(@)
    $(e.target).trigger 'keydown', e
    $(e.target).trigger 'keyup', e
)