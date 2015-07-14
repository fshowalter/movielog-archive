(
  function initCarnac(factory) {
    'use strict';

    // Browser globals
    window.Carnac = factory();
  }(function buildCarnacFactory() {
    'use strict';

    var bar;
    var $currentLocationWithoutHash;
    var $hasTouch = 'createTouch' in document;
    var $preloadTimer;
    var $ua = navigator.userAgent;
    var $urlToPreload;
    var supported;

      // Preloading-related variables
    var $history = {};
    var $xhr;
    var $url = false;
    var $title = false;
    var $mustRedirect = false;
    var $body = false;
    var $timing = {};
    var $isPreloading = false;
    var $isWaitingForCompletion = false;
    var $trackedAssets = [];

    // Variables defined by public functions
    var $useWhitelist;
    var $preloadOnMousedown;
    var $delayBeforePreload;
    var $eventsCallbacks = {
      fetch: [],
      receive: [],
      wait: [],
      change: []
    };


    // HELPERS
    function removeHash(url) {
      var index = url.indexOf('#');
      if (index < 0) {
        return url;
      }
      return url.substr(0, index);
    }

    function getLinkTarget(target) {
      var currentTarget = target;

      while (currentTarget.nodeName !== 'A') {
        currentTarget = currentTarget.parentNode;
      }

      return currentTarget;
    }

    function isBlacklisted(elem) {
      var currentElement = elem;

      do {
        if (!currentElement.hasAttribute) { // Parent of <html>
          break;
        }
        if (currentElement.hasAttribute('data-instant')) {
          return false;
        }
        if (currentElement.hasAttribute('data-no-instant')) {
          return true;
        }
      }
      while (currentElement = currentElement.parentNode);

      return false;
    }

    function isWhitelisted(elem) {
      var currentElement = elem;

      do {
        if (!currentElement.hasAttribute) { // Parent of <html>
          break;
        }
        if (currentElement.hasAttribute('data-no-instant')) {
          return false;
        }
        if (currentElement.hasAttribute('data-instant')) {
          return true;
        }
      }
      while (currentElement = currentElement.parentNode);

      return false;
    }

    function triggerPageEvent(eventType, arg1) {
      var i;

      for (i = 0; i < $eventsCallbacks[eventType].length; i++) {
        $eventsCallbacks[eventType][i](arg1);
      }

      /* The `change` event takes one boolean argument: "isInitialLoad" */
    }

    function changePage(title, body, newUrl, scrollY) {
      var hashIndex;
      var hashElem;
      var offset;

      document.title = title;

      document.documentElement.replaceChild(body, document.body);
      /* We cannot just use `document.body = doc.body`, it causes Safari (tested
         5.1, 6.0 and Mobile 7.0) to execute script tags directly.
      */

      if (newUrl) {
        history.pushState(null, null, newUrl);

        hashIndex = newUrl.indexOf('#');
        hashElem = hashIndex > -1 && document.getElementById(newUrl.substr(hashIndex + 1));
        offset = 0;

        if (hashElem) {
          while (hashElem.offsetParent) {
            offset += hashElem.offsetTop;
            hashElem = hashElem.offsetParent;
          }
        }
        scrollTo(0, offset);

        $currentLocationWithoutHash = removeHash(newUrl);
      } else {
        scrollTo(0, scrollY);
      }
      instantanize();
      bar.done();
      triggerPageEvent('change', false);
    }

    function setPreloadingAsHalted() {
      $isPreloading = false;
      $isWaitingForCompletion = false;
    }


    // EVENT HANDLERS
    function mousedown(e) {
      preload(getLinkTarget(e.target).href);
    }

    function mouseout() {
      if ($preloadTimer) {
        clearTimeout($preloadTimer);
        $preloadTimer = false;
        return;
      }

      if (!$isPreloading || $isWaitingForCompletion) {
        return;
      }
      $xhr.abort();
      setPreloadingAsHalted();
    }

    function mouseover(e) {
      var anchor;

      if (this.hasAttribute('data-instant-block')) {
        anchor = this.querySelector('a');
      } else {
        anchor = e.target;
      }


      // a = getLinkTarget(e.target)
      this.addEventListener('mouseout', mouseout);

      if (!$delayBeforePreload) {
        preload(anchor.href);
      } else {
        $urlToPreload = anchor.href;
        $preloadTimer = setTimeout(preload, $delayBeforePreload);
      }
    }

    function touchstart(e) {
      // var a = getLinkTarget(e.target)

      var anchor;

      if (this.hasAttribute('data-instant-block')) {
        anchor = this.querySelector('a');
      } else {
        anchor = e.target;
      }

      if ($preloadOnMousedown) {
        this.removeEventListener('mousedown', mousedown);
      } else {
        this.removeEventListener('mouseover', mouseover);
      }
      preload(anchor.href);
    }

    function click(e) {
      var anchor;

      if (e.which > 1 || e.metaKey || e.ctrlKey) { // Opening in new tab
        return;
      }

      e.preventDefault();

      if (this.hasAttribute('data-instant-block')) {
        anchor = this.querySelector('a');
      } else {
        anchor = e.target;
      }

      display(anchor.href);
    }

    function createDocumentUsingFragment(html) {
      var body;
      var doc;
      var head;
      var htmlWrapper;
      var ref;
      var ref1;

      head = (ref = html.match(/<head[^>]*>([\s\S.]*)<\/head>/i) !== null ? ref[0] : void 0) || '<head></head>';
      body = (ref1 = html.match(/<body[^>]*>([\s\S.]*)<\/body>/i) !== null ? ref1[0] : void 0) || '<body></body>';
      htmlWrapper = document.createElement('html');
      htmlWrapper.innerHTML = head + body;
      doc = document.createDocumentFragment();
      doc.appendChild(htmlWrapper);
      return doc;
    }

    function readystatechange() {
      var doc;
      var title;
      var urlWithoutHash;
      var elems;
      var found;
      var elem;
      var data;
      var i;
      var j;

      if ($xhr.readyState < 4) {
        return;
      }
      if ($xhr.status === 0) {
        /* Request aborted */
        return;
      }

      $timing.ready = +new Date() - $timing.start;
      triggerPageEvent('receive');

      if ($xhr.getResponseHeader('Content-Type').match(/\/(x|ht|xht)ml/)) {
        doc = createDocumentUsingFragment($xhr.responseText);
        title = doc.querySelector('title');
        $title = title !== null ? title.textContent : null;
        $body = doc.querySelector('body');

        urlWithoutHash = removeHash($url);
        $history[urlWithoutHash] = {
          body: $body,
          title: $title,
          scrollY: urlWithoutHash in $history ? $history[urlWithoutHash].scrollY : 0
        };

        elems = doc.querySelector('head').children;
        found = 0;

        for (i = elems.length - 1; i >= 0; i--) {
          elem = elems[i];
          if (elem.hasAttribute('data-instant-track')) {
            data = elem.getAttribute('href') || elem.getAttribute('src') || elem.innerHTML;
            for (j = $trackedAssets.length - 1; j >= 0; j--) {
              if ($trackedAssets[j] === data) {
                found++;
              }
            }
          }
        }
        if (found !== $trackedAssets.length) {
          $mustRedirect = true; // Assets have changed
        }
      } else {
        $mustRedirect = true; // Not an HTML document
      }

      if ($isWaitingForCompletion) {
        $isWaitingForCompletion = false;
        display($url);
      }
    }


    // MAIN FUNCTIONS
    function instantanize(isInitializing) {
      var as = document.getElementsByTagName('a');
      var a;
      var b;
      var i;
      var j;
      var blocks = document.querySelectorAll('[data-instant-block]');
      var domain = location.protocol + '//' + location.host;
      var scripts;
      var script;
      var copy;
      var parentNode;
      var nextSibling;

      for (i = as.length - 1; i >= 0; i--) {
        a = as[i];
        if (a.target // target="_blank" etc.
            || a.hasAttribute('download')
            || a.href.indexOf(domain + '/') !== 0 // Another domain, or no href attribute
            || (a.href.indexOf('#') > -1
                && removeHash(a.href) === $currentLocationWithoutHash) // Anchor
            || ($useWhitelist
                ? !isWhitelisted(a)
                : isBlacklisted(a))
           ) {
          continue;
        }
        a.addEventListener('touchstart', touchstart);
        if ($preloadOnMousedown) {
          a.addEventListener('mousedown', mousedown);
        } else {
          a.addEventListener('mouseover', mouseover);
        }
        a.addEventListener('click', click);
      }

      for (i = blocks.length - 1; i >= 0; i--) {
        b = blocks[i];
        a = b.querySelector('a');
        if (a.target // target="_blank" etc.
            || a.hasAttribute('download')
            || a.href.indexOf(domain + '/') !== 0 // Another domain, or no href attribute
            || (a.href.indexOf('#') > -1
                && removeHash(a.href) === $currentLocationWithoutHash) // Anchor
            || ($useWhitelist
                ? !isWhitelisted(a)
                : isBlacklisted(a))
           ) {
          continue;
        }
        b.addEventListener('touchstart', touchstart);
        if ($preloadOnMousedown) {
          b.addEventListener('mousedown', mousedown);
        } else {
          b.addEventListener('mouseover', mouseover);
        }
        b.addEventListener('click', click);
      }

      if (!isInitializing) {
        scripts = document.body.getElementsByTagName('script');

        for (i = 0, j = scripts.length; i < j; i++) {
          script = scripts[i];
          if (script.hasAttribute('data-no-instant') || script.type !== 'text/javascript') {
            continue;
          }
          copy = document.createElement('script');
          if (script.src) {
            copy.src = script.src;
          }
          if (script.innerHTML) {
            copy.innerHTML = script.innerHTML;
          }
          parentNode = script.parentNode;
          nextSibling = script.nextSibling;
          parentNode.removeChild(script);
          parentNode.insertBefore(copy, nextSibling);
        }
      }
    }

    function preload(urlToPreload) {
      var url = urlToPreload;
      if (!$preloadOnMousedown
          && 'display' in $timing
          && +new Date() - ($timing.start + $timing.display) < 100) {
        /* After a page is displayed, if the user's cursor happens to be above
           a link a mouseover event will be in most browsers triggered
           automatically, and in other browsers it will be triggered when the
           user moves his mouse by 1px.

           Here are the behavior I noticed, all on Windows:
           - Safari 5.1: auto-triggers after 0 ms
           - IE 11: auto-triggers after 30-80 ms (depends on page's size?)
           - Firefox: auto-triggers after 10 ms
           - Opera 18: auto-triggers after 10 ms

           - Chrome: triggers when cursor moved
           - Opera 12.16: triggers when cursor moved

           To remedy to this, we do not start preloading if last display
           occurred less than 100 ms ago. If they happen to click on the link,
           they will be redirected.
        */

        return;
      }
      if ($preloadTimer) {
        clearTimeout($preloadTimer);
        $preloadTimer = false;
      }

      if (!url) {
        url = $urlToPreload;
      }

      if ($isPreloading && (url === $url || $isWaitingForCompletion)) {
        return;
      }
      $isPreloading = true;
      $isWaitingForCompletion = false;

      $url = url;
      $body = false;
      $mustRedirect = false;
      $timing = {
        start: +new Date()
      };
      triggerPageEvent('fetch');
      $xhr.open('GET', url);
      $xhr.send();
    }

    function display(url) {
      if (!('display' in $timing)) {
        $timing.display = +new Date() - $timing.start;
      }
      if ($preloadTimer) {
        /* Happens when there’s a delay before preloading and that delay
           hasn't expired (preloading didn't kick in).
        */

        if ($url && $url !== url) {
          /* Happens when the user clicks on a link before preloading
             kicks in while another link is already preloading.
          */

          location.href = url;
          return;
        }
        preload(url);
        bar.start(0, true);
        triggerPageEvent('wait');
        $isWaitingForCompletion = true;
        return;
      }
      if (!$isPreloading || $isWaitingForCompletion) {
        /* If the page isn't preloaded, it likely means the user has focused
           on a link (with his Tab key) and then pressed Return, which
           triggered a click.
           Because very few people do this, it isn't worth handling this case
           and preloading on focus (also, focusing on a link doesn't mean it's
           likely that you'll "click" on it), so we just redirect them when
           they "click".
           It could also mean the user hovered over a link less than 100 ms
           after a page display, thus we didn't start the preload (see
           comments in `preload()` for the rationale behind this.)

           If the page is waiting for completion, the user clicked twice while
           the page was preloading. Either on the same link or on another
           link. If it's the same link something might have gone wrong (or he
           could have double clicked), so we send him to the page the old way.
           If it's another link, it hasn't been preloaded, so we redirect the
           user the old way.
        */

        location.href = url;
        return;
      }
      if ($mustRedirect) {
        location.href = $url;
        return;
      }
      if (!$body) {
        bar.start(0, true);
        triggerPageEvent('wait');
        $isWaitingForCompletion = true;
        return;
      }
      $history[$currentLocationWithoutHash].scrollY = pageYOffset;
      setPreloadingAsHalted();
      changePage($title, $body, $url);
    }


    // PROGRESS BAR FUNCTIONS
    bar = (function progressBarFactory() {
      var $barContainer;
      var $barElement;
      var $barTransformProperty;
      var $barProgress;
      var $barTimer;

      function init() {
        var vendors;
        var transitionProperty;
        var i;
        var style;

        $barContainer = document.createElement('div');
        $barContainer.id = 'instantclick';
        $barElement = document.createElement('div');
        $barElement.id = 'instantclick-bar';
        $barElement.className = 'instantclick-bar';
        $barContainer.appendChild($barElement);

        vendors = ['Webkit', 'Moz', 'O'];

        $barTransformProperty = 'transform';
        if (!($barTransformProperty in $barElement.style)) {
          for (i = 0; i < 3; i++) {
            if (vendors[i] + 'Transform' in $barElement.style) {
              $barTransformProperty = vendors[i] + 'Transform';
            }
          }
        }

        transitionProperty = 'transition';
        if (!(transitionProperty in $barElement.style)) {
          for (i = 0; i < 3; i++) {
            if (vendors[i] + 'Transition' in $barElement.style) {
              transitionProperty = '-' + vendors[i].toLowerCase() + '-' + transitionProperty;
            }
          }
        }

        style = document.createElement('style');
        style.innerHTML = '#instantclick{position:' + ($hasTouch ? 'absolute' : 'fixed') + ';top:0;left:0;width:100%;pointer-events:none;z-index:2147483647;' + transitionProperty + ':opacity .25s .1s}'
          + '.instantclick-bar{background:#29d;width:100%;margin-left:-100%;height:2px;' + transitionProperty + ':all .25s}';
        /* We set the bar's background in `.instantclick-bar` so that it can be
           overriden in CSS with `#instantclick-bar`, as IDs have higher priority.
        */
        document.head.appendChild(style);

        if ($hasTouch) {
          updatePositionAndScale();
          addEventListener('resize', updatePositionAndScale);
          addEventListener('scroll', updatePositionAndScale);
        }
      };

      function start(at, jump) {
        $barProgress = at;
        if (document.getElementById($barContainer.id)) {
          document.body.removeChild($barContainer);
        }
        $barContainer.style.opacity = '1'
        if (document.getElementById($barContainer.id)) {
          document.body.removeChild($barContainer);
          /* So there's no CSS animation if already done once and it goes from 1 to 0 */
        }
        update();
        if (jump) {
          setTimeout(jumpStart, 0);
          /* Must be done in a timer, otherwise the CSS animation doesn't happen. */
        }
        clearTimeout($barTimer);
        $barTimer = setTimeout(inc, 500);
      }

      function jumpStart() {
        $barProgress = 10;
        update();
      }

      function inc() {
        $barProgress += 1 + (Math.random() * 2);
        if ($barProgress >= 98) {
          $barProgress = 98;
        }
        else {
          $barTimer = setTimeout(inc, 500);
        }
        update();
      }

      function update() {
        $barElement.style[$barTransformProperty] = 'translate(' + $barProgress + '%)';
        if (!document.getElementById($barContainer.id)) {
          document.body.appendChild($barContainer);
        }
      }

      function done() {
        if (document.getElementById($barContainer.id)) {
          clearTimeout($barTimer);
          $barProgress = 100;
          update();
          $barContainer.style.opacity = '0';
          /* If you're debugging, setting this to 0.5 is handy. */
          return;
        }

        /* The bar container hasn't been appended: It's a new page. */
        start($barProgress === 100 ? 0 : $barProgress);
        /* $barProgress is 100 on popstate, usually. */
        setTimeout(done, 0);
        /* Must be done in a timer, otherwise the CSS animation doesn't happen. */
      }

      function updatePositionAndScale() {
        var landscape;
        var scaleY;

        /* Adapted from code by Sam Stephenson and Mislav Marohnić
           http://signalvnoise.com/posts/2407
        */

        $barContainer.style.left = pageXOffset + 'px';
        $barContainer.style.width = innerWidth + 'px';
        $barContainer.style.top = pageYOffset + 'px';

        landscape = 'orientation' in window && Math.abs(window.orientation) === 90;
        scaleY = innerWidth / screen[landscape ? 'height' : 'width'] * 2;
        /* We multiply the size by 2 because the progress bar is harder
           to notice on a mobile device.
        */
        $barContainer.style[$barTransformProperty] = 'scaleY(' + scaleY + ')';
      }

      return {
        init: init,
        start: start,
        done: done
      };
    }());


    // PUBLIC VARIABLE AND FUNCTIONS
    supported = 'pushState' in history
                    && (!$ua.match('Android') || $ua.match('Chrome/'))
                    && location.protocol !== 'file:';
    // console.log(supported)
    /* The state of Android's AOSP browsers:

       2.3.7: pushState appears to work correctly, but
              `doc.documentElement.innerHTML = body` is buggy.
              See details here: http://stackoverflow.com/q/21918564
              Note an issue anymore, but it may fail where 3.0 do, this needs
              testing again.

       3.0:   pushState appears to work correctly (though the URL bar is only
              updated on focus), but
              `document.documentElement.replaceChild(doc.body, document.body)`
          throws DOMException: WRONG_DOCUMENT_ERR.

       4.0.2: Doesn't support pushState.

       4.0.4,
       4.1.1,
       4.2,
       4.3:   pushState is here, but it doesn't update the URL bar.
              (Great logic there.)

       4.4:   Works correctly. Claims to be 'Chrome/30.0.0.0'.

       All androids tested with Android SDK's Emulator.
       Version numbers are from the browser's user agent.

       Because of this mess, the only whitelisted browser on Android is Chrome.
    */

    function init() {
      var i;
      var arg;
      var elems;
      var elem;
      var data;

      if ($currentLocationWithoutHash) {
        /* Already initialized */
        return;
      }
      if (!supported) {
        triggerPageEvent('change', true);
        return;
      }
      for (i = arguments.length - 1; i >= 0; i--) {
        arg = arguments[i]
        if (arg === true) {
          $useWhitelist = true
        }
        else if (arg === 'mousedown') {
          $preloadOnMousedown = true
        }
        else if (typeof arg === 'number') {
          $delayBeforePreload = arg;
        }
      }

      $currentLocationWithoutHash = removeHash(location.href);
      $history[$currentLocationWithoutHash] = {
        body: document.body,
        title: document.title,
        scrollY: pageYOffset
      };

      elems = document.head.children;

      for (i = elems.length - 1; i >= 0; i--) {
        elem = elems[i];
        if (elem.hasAttribute('data-instant-track')) {
          data = elem.getAttribute('href') || elem.getAttribute('src') || elem.innerHTML;
          /* We can't use just `elem.href` and `elem.src` because we can't
             retrieve `href`s and `src`s from the Ajax response.
          */
          $trackedAssets.push(data);
        }
      }

      $xhr = new XMLHttpRequest();
      $xhr.addEventListener('readystatechange', readystatechange);

      instantanize(true);

      bar.init();

      triggerPageEvent('change', true);

      addEventListener('popstate', function onPopState() {
        var loc = removeHash(location.href);
        if (loc === $currentLocationWithoutHash) {
          return;
        }

        if (!(loc in $history)) {
          location.href = location.href;
          /* Reloads the page while using cache for scripts, styles and images,
             unlike `location.reload()` */
          return;
        }

        $history[$currentLocationWithoutHash].scrollY = pageYOffset;
        $currentLocationWithoutHash = loc;
        changePage($history[loc].title, $history[loc].body, false, $history[loc].scrollY);
      });
    }

    function on(eventType, callback) {
      $eventsCallbacks[eventType].push(callback);
    }


    /* The debug function isn't included by default to reduce file size.
       To enable it, add a slash at the beginning of the comment englobing
       the debug function, and uncomment "debug: debug," in the return
       statement below the function. */

    /*
    function debug() {
      return {
        currentLocationWithoutHash: $currentLocationWithoutHash,
        history: $history,
        xhr: $xhr,
        url: $url,
        title: $title,
        mustRedirect: $mustRedirect,
        body: $body,
        timing: $timing,
        isPreloading: $isPreloading,
        isWaitingForCompletion: $isWaitingForCompletion
      }
    }
    //*/

    return {
      // debug: debug,
      supported: supported,
      init: init,
      on: on
    };
  })
);
