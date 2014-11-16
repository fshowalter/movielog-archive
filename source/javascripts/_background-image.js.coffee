"use strict"

$ = window.jQuery

class BackgroundImage
  constructor: (element, options) ->
    @$element = $(element)
    @options = $.extend({}, BackgroundImage.DEFAULTS, options)
    @loaded = false
    @load(@options.backgroundImage) if @options.backgroundImage

  load: (url) ->
    desiredWidth = BackgroundImage.queryDesiredWidth(@$element)
    imageUrl = BackgroundImage.updateWidthInImageUrl(url, desiredWidth)
    BackgroundImage.loadImage(imageUrl).done (image) =>
      css = {'background-image': 'url(' + imageUrl + ')', opacity: 1}
      height = image.height

      if window.devicePixelRatio is 1
        # css['min-height'] = image.height
      else
        if image.width < desiredWidth
          css['background-size'] = "contain"
        else
          retinaHeight = image.height / window.devicePixelRatio
          retinaWidth = image.width / window.devicePixelRatio
          # css['min-height'] = retinaHeight
          height = retinaHeight
          css['background-size'] = "#{retinaWidth}px #{retinaHeight}px"

      css['height'] = height unless @options.setHeight is false

      @$element.css(css);
      $caption = @$element.find('.caption')
      $caption.height($caption[0].scrollHeight) if $caption.length
      @loaded = true
      @$element

  @DEFAULTS =
    setHeight: false
    backgroundImage: null

  @queryDesiredWidth = ($element) ->
    width = $element.width();
    window.devicePixelRatio ||= 1
    width = width * window.devicePixelRatio;

  @updateWidthInImageUrl = (baseUrl, width) ->
    baseUrl.replace(/\/w\d*\//, '/w' + width + '/')


  @loadImage = (url) ->
    # Define a "worker" function that should eventually resolve or reject the deferred object.
    loadImage = (deferred) ->
      image = new Image();

      unbindEvents = () ->
        # Ensures the event callbacks only get called once.
        image.onload = null;
        image.onerror = null;
        image.onabort = null;

      loaded = () ->
        unbindEvents();
        # Calling resolve means the image loaded sucessfully and is ready to use.
        deferred.resolve(image);

      errored = () ->
        unbindEvents();
        # Calling reject means we failed to load the image (e.g. 404, server offline, etc).
        deferred.reject(image);

      # Set up event handlers to know when the image has loaded
      # or fails to load due to an error or abort.
      image.onload = loaded;
      image.onerror = errored; # URL returns 404, etc
      image.onabort = errored; # IE may call this if user clicks "Stop"

      # Setting the src property begins loading the image.
      image.src = url;

    # Create the deferred object that will contain the loaded image.
    # We don't want callers to have access to the resolve() and reject() methods,
    # so convert to "read-only" by calling `promise()`.
    $.Deferred(loadImage).promise();



###
BACKGROUNDIMAGE PLUGIN DEFINITION
###
old = $.fn.backgroundImage

$.fn.backgroundImage = (option) ->
  @each ->
    $this = $(@)
    data = $this.data('movielog.backgroundImage')
    options = $.extend({}, BackgroundImage.DEFAULTS, $this.data(), typeof option == 'object' && option)

    $this.data('movielog.backgroundImage', (data = new BackgroundImage(@, options))) unless data
    data[option]() if typeof option == 'string'

$.fn.backgroundImage.Constructor = BackgroundImage

###
BACKGROUNDIMAGE NO CONFLICT
###
$.fn.backgroundImage.noConflict = ->
  $.fn.backgroundImage = old
  this

###
BACKGROUNDIMAGE DATA-API
###
$(document).ready ->
  $('[data-background-image]').each ->
    $this = $(this)
    data = $this.data()
    $this.backgroundImage(data)
