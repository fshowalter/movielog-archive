// = require _load-backdrops
// = require _fastclick
// = require _toggle-search
// = require _instantclick

(
  function initMovielog() {
    'use strict';

    var fastClick;

    window.InstantClick.on('change', function handleInstantClickChange(isInitial) {
      if (fastClick) {
        fastClick.destroy();
      }

      fastClick = window.FastClick.attach(document.body);

      if (!isInitial) {
        window.MovielogBackdrops.update();
      }
    });

    window.InstantClick.init();
  }()
);
