"use strict"

class Sorter
  constructor: (element, options) ->
    @$element = $(element)
    @options = $.extend({}, Sorter.DEFAULTS, @$element.data(), typeof options == 'object' && options)
    @$target = $(@options.target)
    @dataMap = Sorter.mapItems @$target.find(@options.itemsSelector)

  @DEFAULTS =
    itemsSelector: 'li'

  @descendingSort = (a,b) ->
    -1 * Sorter.ascendingSort a, b

  @ascendingSort = (a,b) ->
    if typeof a is 'string'
        a.value.localeCompare b.value
    else
        if a.value is b.value then 0 else (if a.value > b.value then 1 else -1)

  @removeElementToInsertLater = (element) ->
    parentNode = element.parentNode
    nextSibling = element.nextSibling
    parentNode.removeChild element
    () ->
        if nextSibling then parentNode.insertBefore(element, nextSibling) else parentNode.appendChild element

  @mapItems = (items) ->
    map = []
    for item in items
      $item = $(item)
      data = $item.data();
      for key, value of data
        map[key] ?= [];
        map[key].push
          item : item
          value: value
    map

  sort: ->
    value = @$element.val()
    list = @$target[0]
    reinsert = Sorter.removeElementToInsertLater list
    @$target.empty()

    [attribute, sortOrder] = (/(.*)-(asc|desc)$/.exec value)[1..2]

    sortedItems = @dataMap[jQuery.camelCase attribute].sort(if sortOrder is 'desc' then Sorter.descendingSort else Sorter.ascendingSort)
    list.appendChild sortedItem.item for sortedItem in sortedItems

    reinsert()

###
SORTER DATA-API
###
$(document).on 'change.movielog.sort', '[data-sorter]', (e) ->
  $this = $(@)
  data = $this.data('movielog.sorter')
  $this.data('movielog.sorter', (data = new Sorter($this))) unless data
  data.sort()