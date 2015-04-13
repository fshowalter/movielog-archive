//= require _mini-rhythm
//= require _remove_touch_delay
//= require _mobile_navigation
//= require _instantclick

fc = null;

InstantClick.on('change', (initial) ->
  fc.destroy() if fc
  fc = FastClick.attach(document.body);
  window.set_rhythm
)

InstantClick.init();

