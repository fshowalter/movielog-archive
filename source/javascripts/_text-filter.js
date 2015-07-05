/* global Gator */

(
  function initSorter(factory) {
    'use strict';

    Gator(document).on('keyup', '[data-filter-type="text"]', function handleTextFilterKeyUp() {
      var event;

      if (!this.movielogFilter) {
        factory.create(this);
      }

      if (window.CustomEvent) {
        event = new CustomEvent('filter-changed', {
          'bubbles': true,
          'cancelable': false
        });
      } else {
        event = document.createEvent('CustomEvent');
        event.initCustomEvent('filter-changed', true, true);
      }

      this.dispatchEvent(event);
    });
  }(function buildTextFilterFactory() {
    'use strict';

    function TextFilter(node) {
      this.node = node;
      this.attribute = node.dataset.filterAttribute || TextFilter.DEFAULTS.filterAttribute;
    }

    TextFilter.DEFAULTS = {
      filterAttribute: 'text'
    };

    TextFilter.escapeRegExp = function escapeRegExp(str) {
      return str.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, '\\$&');
    };

    TextFilter.prototype.getMatcher = function getMatcher() {
      var attribute = this.attribute;
      var regex;
      var value = this.node.value;

      if (!value) {
        return null;
      }

      regex = new RegExp(TextFilter.escapeRegExp(value), 'i');

      return function matcher(item) {
        return regex.test(item.getAttribute(attribute));
      };
    };


    // Run the standard initializer
    function initialize(node) {
      var filter = new TextFilter(node);
      node.movielogFilter = filter;

      return node.movielogFilter;
    }

    // Use an object instead of a function for future expansibility;
    return {
      create: initialize
    };
  }())
);
