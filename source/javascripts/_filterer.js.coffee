"use strict"

class Filterer
  constructor: (options) ->
    @options = $.extend(options, Filterer.DEFAULTS, typeof options == 'object' && options)
    @attribute = @options.attribute
    @$items = $(@options.target).find @options.itemsSelector
    @filters = []

  @DEFAULTS =
    attribute: 'text'
    itemsSelector: 'li'

  ###
  Copyright 2009 Nicholas C. Zakas. All rights reserved. MIT Licensed
  ###
  @timedChunk: (items, process, context, callback) ->
    todo = items.concat() #create a clone of the original
    processItem = ->
      start = +new Date()
      loop
        process.call(context, todo.shift())
        break unless todo.length > 0 and (+new Date() - start < 50)
      if todo.length > 0
        setTimeout processItem, 25
      else if callback
        callback items

    setTimeout processItem, 25

  addFilter: (filter) ->
    @filters.push(filter) if @filters.indexOf(filter) == -1

  filter: ->
    matchers = []

    for filter in @filters
      matcher = filter.matcher()
      matchers.push(matcher) if matcher?

    matchItem = (item) ->
      match = true

      for matcher in matchers
        if !matcher(item)
          match = false
          break

      if match
        item.removeAttribute 'style'
      else
        item.style.display = 'none'

    Filterer.timedChunk @$items.get(), matchItem

###
Borrowed from underscore.js
###
underscoreDebounce = (func, wait, immediate) ->
  ->
    context = this;
    args = arguments;
    timestamp = new Date();
    later = ->
      last = (new Date()) - timestamp;
      if last < wait
        timeout = setTimeout(later, wait - last);
      else
        timeout = null;
        result = func.apply(context, args) if (!immediate)

    callNow = immediate && !timeout;
    timeout = setTimeout(later, wait) if (!timeout)

    func.apply(context, args) if (callNow)

$(document).off 'filter-changed.movielog-filters', '[data-filter-controls]'
$(document).on 'filter-changed.movielog', '[data-filter-controls]', (e) ->
  $this = $(@)
  data = $this.data('movielog.filterer')

  unless data
    $this.data('movielog.filterer', (data = new Filterer($this.data())))

  data.addFilter($(e.target).data('movielog.filter'))

  underscoreDebounce( ->
    data.filter()
  , 50)()
