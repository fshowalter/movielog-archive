"use strict"

$ = window.jQuery

transitionEnd = ->
  el = document.createElement("bootstrap")
  transEndEventNames =
    WebkitTransition: "webkitTransitionEnd"
    MozTransition: "transitionend"
    OTransition: "oTransitionEnd otransitionend"
    transition: "transitionend"

  for name of transEndEventNames
    return end: transEndEventNames[name]  if el.style[name] isnt `undefined`

# http://blog.alexmaccaw.com/css-transitions
$.fn.emulateTransitionEnd = (duration) ->
  called = false
  $el = this
  $(this).one $.support.transition.end, ->
    called = true

  callback = ->
    $($el).trigger $.support.transition.end  unless called

  setTimeout callback, duration
  this

$ ->
  $.support.transition = transitionEnd()

class Collapse
  constructor: (element, options) ->
    @$element = $(element)
    @options = $.extend({}, Collapse.DEFAULTS, options)
    @transitioning = null

    @collapseHeight = @options.collapseHeight || 0
    @toggle() if @options.toggle

  @DEFAULTS =
    toggle: true

  show: ->
    return false if (@transitioning or @$element.hasClass('open'))

    startEvent = $.Event 'show.movielog.collapse'
    @$element.trigger(startEvent)

    return false if startEvent.isDefaultPrevented()

    @$element
      .removeClass('collapsed')
      .addClass('opening')
      .height(@collapseHeight)

    @transitioning = 1

    @$element.trigger 'showing.movielog.collapse'

    complete = ->
      @$element
        .removeClass('opening')
        .addClass('open')
      @transitioning = 0
      @$element.trigger 'shown.movielog.collapse'

    return complete.call(this) unless $.support.transition

    @$element
      .one($.support.transition.end, $.proxy(complete, @))
      .emulateTransitionEnd(350)
      .height(@$element[0].scrollHeight)

  hide: ->
    return false if (@transitioning or !@$element.hasClass('open'))

    startEvent = $.Event 'hide.movielog.collapse'
    @$element.trigger startEvent
    return false if startEvent.isDefaultPrevented()

    @$element.height(@$element.height())[0].offsetHeight

    @$element
      .addClass('collapsing')
      .removeClass('collapsed')
      .removeClass('open')

    @transitioning = 1

    @$element.trigger $.Event 'hiding.movielog.collapse'

    complete = ->
      @transitioning = 0
      @$element
        .trigger('hidden.movielog.collapse')
        .removeClass('collapsing')
        .addClass('collapsed')

    return complete.call(@) unless $.support.transition

    @$element
      .height(@options.collapseHeight)
      .one($.support.transition.end, $.proxy(complete, @))
      .emulateTransitionEnd(350)

  toggle: ->
    @[if @$element.hasClass('open') then 'hide' else 'show']()


###
COLLAPSE PLUGIN DEFINITION
###
old = $.fn.collapse

$.fn.collapse = (option) ->
  @each ->
    $this = $(@)
    data = $this.data('movielog.collapse')
    options = $.extend({}, Collapse.DEFAULTS, $this.data(), typeof option == 'object' && option)

    $this.data('movielog.collapse', (data = new Collapse(@, options))) unless data
    data[option]() if typeof option == 'string'

$.fn.collapse.Constructor = Collapse

###
COLLAPSE NO CONFLICT
###
$.fn.collapse.noConflict = ->
  $.fn.collapse = old
  this


###
COLLAPSE DATA-API
###
$(document).on('touchend.movielog.collapse.data-api click.movielog.collapse.data-api', '[data-toggle=collapse]', (e) ->
  e.preventDefault()
  $this = $(@)
  target = $this.attr('data-target') or e.preventDefault() or (href = $this.attr('href')) && href.replace(/.*(?=#[^\s]+$)/, '') #strip for ie7
  $target = $(target)
  data    = $target.data('movielog.collapse')
  parent  = $target.attr('data-parent')
  $parent = parent && $(parent)

  if data
    option = 'toggle'
  else
    option = $this.data()
    option.collapseHeight ||= $target.height()

  if not data or not data.transitioning
    if ($parent)
      $parent.find('[data-parent="' + parent + '"]').not($target).css(height: '').removeClass('open')
    $this[if $target.hasClass('open') then 'addClass' else 'removeClass']('collapsed')

  $target.collapse(option))
