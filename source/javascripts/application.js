// = require _load-backdrops
// = require _toggle-search
// = require _carnac

(
  function initMovielog() {
    'use strict';

    window.Carnac.on('change', function handleCarnacChange(isInitial) {
      if (!isInitial) {
        window.MovielogBackdrops.update();
      }
    });

    window.Carnac.init();
  }()
);
