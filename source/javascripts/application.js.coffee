//= require _load_backdrops
//= require _remove_touch_delay
//= require _mobile_navigation
//= require _instantclick


fc = null;
masonry = null;

InstantClick.on('change', (initial) ->
  fc.destroy() if fc
  fc = FastClick.attach(document.body);
  BackgroundImages.update();
)

InstantClick.init();

