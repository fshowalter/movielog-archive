//= require _remove_touch_delay
//= require _mobile_navigation
//= require _instantclick

fc = null;

InstantClick.on('change', ->
  fc.destroy() if fc
  fc = FastClick.attach(document.body);
  window._gaq.push ["_trackPageview", location.pathname + location.search] if window._gaq
)

InstantClick.init();

