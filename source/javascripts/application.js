// = require _load_backdrops
// = require _fastclick
// = require _toggle_search
// = require _instantclick

(
  function initMovielog() {
    'use strict';

    var fastClick;

    window.InstantClick.on('change', function handleInstantClickChange() {
      if (fastClick) {
        fastClick.destroy();
      }

      fastClick = window.FastClick.attach(document.body);
      window.MovielogBackgroundImages.update();
    });

    window.InstantClick.init();
  }()
);
