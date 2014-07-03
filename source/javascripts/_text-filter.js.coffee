"use strict"

$ = window.jQuery

class TextFilter
  constructor: (element, options) ->
    @$element = $(element)
    @options = $.extend({}, TextFilter.DEFAULTS, options)
    @attribute = @options.filterAttribute

  @DEFAULTS =
    filterAttribute: 'text'

  matcher: ->
    return null unless @$element.val()
    regex = new RegExp @$element.val(), 'i'
    (item) =>
      regex.test item.getAttribute(@attribute)

###
TEXTFILTER PLUGIN DEFINITION
###
old = $.fn.textFilter

$.fn.textFilter = (option) ->
  @each ->
    $this = $(@)
    data = $this.data('movielog.filter')
    options = $.extend({}, TextFilter.DEFAULTS, $this.data(), typeof option == 'object' && option)

    $this.data('movielog.filter', (data = new TextFilter(@, options))) unless data
    if typeof option == 'string' then data[option]() else data

$.fn.textFilter.Constructor = TextFilter

###
TEXTFILTER NO CONFLICT
###
$.fn.textFilter.noConflict = ->
  $.fn.textFilter = old
  this

###
FILTERER DATA-API
###
$(document).on 'keyup.text-filter.movielog.data-api', '[data-filter-type="text"]', (e) ->
  $(@).textFilter().trigger $.Event 'filter-changed.movielog'


