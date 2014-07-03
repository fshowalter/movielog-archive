"use strict"

$ = window.jQuery

class RatingRangeFilter extends $.fn.rangeFilter.Constructor
  constructor: (element, options) ->
    options = $.extend({}, RatingRangeFilter.DEFAULTS, options)
    super(element, options)

  @DEFAULTS =
    filterAttribute: 'text'
    filterMinValue: 1
    filterMaxValue: 11
    changeEventName: 'filter-changed.movielog'
    onSlide: ->
      values = @slider.val()
      @$element.find('.filter-range__min .rating').html RatingRangeFilter.ratingTag(values[0])
      @$element.find('.filter-range__max .rating').html RatingRangeFilter.ratingTag(values[1])

  @ratingTag: (rating) ->
    ratingStar = (char) ->
      switch char
        when '☆'
          return '<span class="rating-star-empty">☆</span>'
        when '½'
          return '<span class="rating-star-half">½</span>'
        when '★'
          return '<span class="rating-star-full">★</span>'

    parseRating = (ratingString) ->
      (ratingStar(star) for star in ratingString).join('')

    switch +rating
      when 1
        parseRating('☆☆☆☆☆')
      when 2
        parseRating('½☆☆☆☆')
      when 3
        parseRating('★☆☆☆☆')
      when 4
        parseRating('★½☆☆☆')
      when 5
        parseRating('★★☆☆☆')
      when 6
        parseRating('★★½☆☆')
      when 7
        parseRating('★★★☆☆')
      when 8
        parseRating('★★★½☆')
      when 9
        parseRating('★★★★☆')
      when 10
        parseRating('★★★★½')
      when 11
        parseRating('★★★★★')

###
RATINGRANGEFILTER PLUGIN DEFINITION
###
old = $.fn.rangeFilter

$.fn.ratingRangeFilter = (option) ->
  @each ->
    $this = $(@)
    data = $this.data('movielog.filter')
    options = $.extend({}, RatingRangeFilter.DEFAULTS, $this.data(), typeof option == 'object' && option)

    $this.data('movielog.filter', (data = new RatingRangeFilter(@, options))) unless data
    data[option]() if typeof option == 'string'

$.fn.ratingRangeFilter.Constructor = RatingRangeFilter

###
RATINGRANGEFILTER NO CONFLICT
###
$.fn.ratingRangeFilter.noConflict = ->
  $.fn.rangeFilter = old
  this

###
RATINGRANGEFILTER DATA-API
###
$(document).on("mousedown.range-filter.movielog.data-api MSPointerDown.range-filter.movielog.data-api touchstart.range-filter.movielog.data-api", "[data-filter-type='rating-range']", (e)->
  $this = $(@)
  if !$this.data('movielog.filter')
    console.log("init")
    e.preventDefault()
    $this.ratingRangeFilter();
    $(e.target).trigger(e)
)