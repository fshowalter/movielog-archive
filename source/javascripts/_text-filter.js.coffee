"use strict"

$ = window.jQuery

class TextFilter
  constructor: (element, options) ->
    @$element = $(element)
    @options = $.extend({}, TextFilter.DEFAULTS, @$element.data(), typeof options == 'object' && options)
    @attribute = @options.filterAttribute

  @DEFAULTS =
    filterAttribute: 'text'

  escapeRegExp: (str) ->
    str.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&");

  matcher: ->
    return null unless @$element.val()

    console.log(@escapeRegExp(@$element.val()))
    regex = new RegExp(@escapeRegExp(@$element.val()), 'i')
    (item) =>
      console.log(item.getAttribute(@attribute))
      regex.test item.getAttribute(@attribute)

###
FILTERER DATA-API
###
$(document).on 'keyup.text-filter.movielog.data-api', '[data-filter-type="text"]', (e) ->
  $this = $(@)
  data = $this.data('movielog.filter')

  $this.data('movielog.filter', (data = new TextFilter($this))) unless data

  $this.trigger $.Event 'filter-changed.movielog'