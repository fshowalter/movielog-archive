/* global Gator */

(
  function initSorter(factory) {
    'use strict';

    Gator(document).on('change', '[data-sorter]', function handleSorterChange(e) {
      var sorter;

      e.preventDefault();

      sorter = e.target.movielogSorter;

      if (!sorter) {
        sorter = factory.create(e.target);
      }

      sorter.sort();
    });
  }(function buildSorterFactory() {
    'use strict';

    function Sorter(node) {
      this.element = node;
      this.list = document.querySelector(node.dataset.target);
      this.dataMap = Sorter.mapItems(this.list.querySelectorAll(Sorter.DEFAULTS.itemsSelector));
    }

    Sorter.DEFAULTS = {
      itemsSelector: 'li'
    };

    Sorter.descendingSort = function descendingSort(a, b) {
      return -1 * Sorter.ascendingSort(a, b);
    };

    Sorter.ascendingSort = function ascendingSort(a, b) {
      if (typeof a === 'string') {
        return a.value.localeCompare(b.value);
      }

      if (a.value === b.value) {
        return 0;
      }

      if (a.value > b.value) {
        return 1;
      }

      return -1;
    };

    Sorter.removeElementToInsertLater = function removeElementToInsertLater(element) {
      var nextSibling;
      var parentNode;

      parentNode = element.parentNode;
      nextSibling = element.nextSibling;

      parentNode.removeChild(element);

      return function insertRemovedElement() {
        if (nextSibling) {
          return parentNode.insertBefore(element, nextSibling);
        }

        return parentNode.appendChild(element);
      };
    };

    Sorter.getKeysForItem = function getKeysForItem(item, dataset) {
      var key;
      var keys = [];

      for (key in dataset) {
        if ({}.hasOwnProperty.call(dataset, key)) {
          keys.push(key);
        }
      }

      return keys;
    };

    Sorter.mapValuesForItem = function mapValuesForItem(item, dataset, keys, map) {
      var i;
      var key;
      var len;
      var value;

      for (i = 0, len = keys.length; i < len; i++) {
        key = keys[i];
        value = dataset[key];

        if (!map[key]) {
          map[key] = [];
        }

        map[key].push({
           item: item,
           value: value
         });
      }

      return map;
    };

    Sorter.mapItems = function mapItems(items) {
      var dataset;
      var i;
      var item;
      var keys;
      var len;
      var map = [];

      for (i = 0, len = items.length; i < len; i++) {
        item = items[i];
        dataset = item.dataset;
        keys = keys || Sorter.getKeysForItem(item, dataset);
        Sorter.mapValuesForItem(item, dataset, keys, map);
      }

      return map;
    };

    Sorter.prototype.sortDataMap = function sortDataMap(sorter) {
      var attribute;
      var sortAttributeAndOrder;
      var sortOrder;
      var sortFunction;
      var value;

      value = sorter.element.value;
      sortAttributeAndOrder = (/(.*)-(asc|desc)$/.exec(value)).slice(1, 3);

      attribute = sortAttributeAndOrder[0];
      sortOrder = sortAttributeAndOrder[1];

      attribute = Sorter.camelCase(attribute);
      sortFunction = sortOrder === 'desc' ? Sorter.descendingSort : Sorter.ascendingSort;

      return sorter.dataMap[attribute].sort(sortFunction);
    };

    Sorter.camelCase = function camelCase(str) {
      return str.replace(/^([A-Z])|[\s-_](\w)/g, function handleCamelCaseRegexMatch(match, p1, p2) {
        if (p2) { return p2.toUpperCase(); }
        return p1.toLowerCase();
      });
    };


    Sorter.prototype.sort = function sort() {
      var i;
      var len;
      var reinsert;
      var sortedItem;
      var sortedItems;

      reinsert = Sorter.removeElementToInsertLater(this.list);

      this.list.innerHTML = '';
      sortedItems = Sorter.prototype.sortDataMap(this);

      for (i = 0, len = sortedItems.length; i < len; i++) {
        sortedItem = sortedItems[i];
        this.list.appendChild(sortedItem.item);
      }

      return reinsert();
    };

    // Run the standard initializer
    function initialize(node) {
      var sorter = new Sorter(node);
      node.movielogSorter = sorter;

      return node.movielogSorter;
    }

    // Use an object instead of a function for future expansibility;
    return {
      create: initialize
    };
  }())
);
