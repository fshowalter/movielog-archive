// = require _load-backdrops
// = require _fastclick
// = require _toggle-search
// = require _carnac

(
  function initMovielog() {
    'use strict';

    var fastClick;

    window.Carnac.on('change', function handleCarnacChange(isInitial) {
      if (fastClick) {
        fastClick.destroy();
      }

      fastClick = window.FastClick.attach(document.body);

      if (!isInitial) {
        window.MovielogBackdrops.update();
      }
    });

    window.Carnac.init();
  }()
);
