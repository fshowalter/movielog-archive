(
  function initMovielogBackgroundImages() {
    'use strict';

    var debouncedUpdate;

    function retinaWidth(node, retinaMultiplier) {
      return node.offsetWidth * retinaMultiplier;
    }

    function updateWidthInImageUrl(baseUrl, width) {
      return baseUrl.replace(/\/w\d*-rj\//, '/w' + width + '-rj/');
    }

    function backgroundImageUrlForNode(node, retinaMultiplier) {
      var url = node.getAttribute('data-backdrop');
      var width = retinaWidth(node, retinaMultiplier);

      return updateWidthInImageUrl(url, width);
    }

    function updateBackgroundImageForNode(node, retinaMultiplier) {
      node.style.backgroundImage = 'url(' + backgroundImageUrlForNode(node, retinaMultiplier) + ')';
      node.classList.add('loaded');
    }

    function updateBackgroundImages() {
      var i;
      var nodes = document.querySelectorAll('[data-backdrop]');
      var retinaMultiplier = window.devicePixelRatio || 1;

      // cache nodelist length
      var nodesLength = nodes.length;

      // loop through nodes
      for (i = 0; i < nodesLength; i++) {
        // cache node
        updateBackgroundImageForNode(nodes[i], retinaMultiplier);
      }
    }

    function underscoreDebounce(func, wait, immediate) {
      var args;
      var context;
      var result;
      var timeout;
      var timestamp;

      var later = function later() {
        var last = (new Date() - timestamp);

        if (last < wait && last >= 0) {
          timeout = setTimeout(later, wait - last);
        } else {
          timeout = null;
          if (!immediate) {
            result = func.apply(context, args);
            if (!timeout) context = args = null;
          }
        }
      };

      return function debouncedFunction() {
        var callNow = immediate && !timeout;

        context = this;
        args = arguments;
        timestamp = new Date();

        if (!timeout) timeout = setTimeout(later, wait);
        if (callNow) {
          result = func.apply(context, args);
          context = args = null;
        }

        return result;
      };
    }

    debouncedUpdate = underscoreDebounce(function getDebouncedUpdate() {
      requestAnimationFrame(updateBackgroundImages);
    }, 250);

    window.addEventListener('resize', debouncedUpdate, false);

    function documentIsFinishedLoading() {
      return /^complete|^i|^c/.test( document.readyState);
    }

    function update() {
      var intervalId = setInterval( function updateOnceDocumentHasFinishedLoading() {
        // When the document has finished loading, stop checking for new images
        // https://github.com/ded/domready/blob/master/ready.js#L15
        if (documentIsFinishedLoading()) {
          requestAnimationFrame(updateBackgroundImages);
          clearInterval(intervalId);
        }
      }, 250 );
    }

    window.MovielogBackgroundImages = {
      update: update
    };
  }()
);
