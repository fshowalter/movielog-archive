"use strict"

$ = window.jQuery

class RadioFilter
  constructor: (element, options) ->
    @$element = $(element)
    @options = $.extend({}, RadioFilter.DEFAULTS, options)
    @attribute = @options.filterAttribute
    @$inputs = @$element.find('input[type="radio"]')

  @DEFAULTS =
    filterAttribute: 'text'
    changeEventName: 'changed.radioFilter'

  # @sizeRadios: ($element) ->
  #   labels = $element.find('label')
  #   width = 100 / labels.length
  #   label.style.width = "#{width}%" for label in labels
  #   $element

  @getFilterValue: ($inputs) ->
    filterValue = (input) ->
      name = input.getAttribute('name')
      id = input.getAttribute('id')
      regex = new RegExp "^#{name}_(.*)$", 'i'
      (regex.exec id)[1]

    $inputs.filter(":checked")[0].value

  matcher: ->
    filter = RadioFilter.getFilterValue(@$element.find('input[type="radio"]'))
    regex = new RegExp "^#{filter}$", 'i'
    return (item) =>
      if (!filter || filter == "on")
        return true
      regex.test item.getAttribute(@attribute)

###
RADIOFILTER PLUGIN DEFINITION
###
old = $.fn.radioFilter

$.fn.radioFilter = (option) ->
  @each ->
    $this = $(@)
    data = $this.data('movielog.filter')
    options = $.extend({}, RadioFilter.DEFAULTS, $this.data(), typeof option == 'object' && option)

    $this.data('movielog.filter', (data = new RadioFilter(@, options))) unless data
    data[option]() if typeof option == 'string'

$.fn.radioFilter.Constructor = RadioFilter

###
RADIOFILTER NO CONFLICT
###
$.fn.rangeFilter.noConflict = ->
  $.fn.radioFilter = old
  this

###
SORTER DATA-API
###
$(document).on 'change.movielog.radio-filter', '[data-filter-type="radio"]', (e) ->
  $this = $(@)
  $this.radioFilter().trigger $.Event 'filter-changed.movielog'
  $this.find('label').removeClass('active')
  $(e.target).parent('label').toggleClass("active")
