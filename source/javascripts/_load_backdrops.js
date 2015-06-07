window.BackgroundImages = function () {
  function update() {
    var nodes = document.querySelectorAll('[data-backdrop]');
    var retinaMultiplier = window.devicePixelRatio || 1;

    // cache nodelist length
    var nodesLength = nodes.length;

    // loop through nodes
    for(var i = 0; i < nodesLength; i++) {
      // cache node
      updateBackgroundImageForNode(nodes[i], retinaMultiplier);
    }
  }

  function updateBackgroundImageForNode(node, retinaMultiplier) {
    node.style.backgroundImage = 'url(' + backgroundImageUrlForNode(node, retinaMultiplier) + ')';
    node.classList.add('loaded');
  }


  function backgroundImageUrlForNode(node, retinaMultiplier) {
    var url = node.getAttribute('data-backdrop');
    var width = retinaWidth(node, retinaMultiplier);

    return updateWidthInImageUrl(url, width);
  }

  function retinaWidth(node, retinaMultiplier) {
    return node.offsetWidth * retinaMultiplier;
  }

  function updateWidthInImageUrl(baseUrl, width) {
    return baseUrl.replace(/\/w\d*-rj\//, '/w' + width + '-rj/');
  }

  /*
  Borrowed from underscore.js
  */
  _debounce = function(func, wait, immediate) {
    var timeout, args, context, timestamp, result;

    var later = function() {
      var last = new Date() - timestamp;

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

    return function() {
      context = this;
      args = arguments;
      timestamp = new Date();
      var callNow = immediate && !timeout;
      if (!timeout) timeout = setTimeout(later, wait);
      if (callNow) {
        result = func.apply(context, args);
        context = args = null;
      }

      return result;
    };
  };

  var debouncedUpdate = _debounce(function() {
    requestAnimationFrame(update);
  }, 250);

  window.addEventListener('resize', debouncedUpdate, false);

  

  return {
    update:  function() {
      var intervalId = setInterval( function() {
        // When the document has finished loading, stop checking for new images
        // https://github.com/ded/domready/blob/master/ready.js#L15
        if ( /^complete|^i|^c/.test( document.readyState ) ) {
          requestAnimationFrame(update);
          clearInterval( intervalId );
          return;
        }
      }, 250 );
    }
  };
}();