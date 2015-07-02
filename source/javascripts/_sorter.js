(function (factory) {
  window.Movielog = window.Movielog || {};
  window.Movielog.sorter = factory();

   Gator(document).on('change', '[data-sorter]', function(e) {
     e.preventDefault();

     var sorter = e.target.movielogSorter;

     if (!sorter) {
       sorter = window.Movielog.sorter.create(e.target);
     }

     sorter.sort();
   });
}(function () {
  Sorter = (function() {
    function Sorter(node) {
      this.element = node;
      this.list = document.querySelector(node.dataset.target);
      this.dataMap = Sorter.mapItems(this.list.querySelectorAll(Sorter.DEFAULTS.itemsSelector));
    }

    Sorter.DEFAULTS = {
      itemsSelector: 'li'
    };

    Sorter.descendingSort = function(a, b) {
      return -1 * Sorter.ascendingSort(a, b);
    };

    Sorter.ascendingSort = function(a, b) {
      if (typeof a === 'string') {
        return a.value.localeCompare(b.value);
      } else {
        if (a.value === b.value) {
          return 0;
        } else {
          if (a.value > b.value) {
            return 1;
          } else {
            return -1;
          }
        }
      }
    };

    Sorter.removeElementToInsertLater = function(element) {
      var nextSibling, parentNode;
      
      parentNode = element.parentNode;
      nextSibling = element.nextSibling;
      
      parentNode.removeChild(element);

      return function() {
        if (nextSibling) {
          return parentNode.insertBefore(element, nextSibling);
        } else {
          return parentNode.appendChild(element);
        }
      };
    };

    Sorter.mapItems = function(items) {
      var dataset, i, item, key, len, map, value;
      map = [];
      for (i = 0, len = items.length; i < len; i++) {
        item = items[i];
        dataset = item.dataset;
        for (key in dataset) {
          value = dataset[key];
          if (map[key] == null) {
            map[key] = [];
          }
          map[key].push({
            item: item,
            value: value
          });
        }
      }
      return map;
    };

    Sorter.prototype.sortDataMap = function (sorter) {
      var attribute, sortAttributeAndOrder, sortOrder, sortFunction, value;

      value = sorter.element.value;
      sortAttributeAndOrder = (/(.*)-(asc|desc)$/.exec(value)).slice(1, 3);

      attribute = sortAttributeAndOrder[0];
      sortOrder = sortAttributeAndOrder[1];

      attribute = Sorter.camelCase(attribute);
      sortFunction = sortOrder === 'desc' ? Sorter.descendingSort : Sorter.ascendingSort;

      return sorter.dataMap[attribute].sort(sortFunction);
    };

    Sorter.camelCase = function (str) {
      return str.replace(/^([A-Z])|[\s-_](\w)/g, function(match, p1, p2) {
        if (p2) return p2.toUpperCase();
        return p1.toLowerCase();
      });
    };


    Sorter.prototype.sort = function() {
      var i, len, reinsert, sortedItem, sortedItems;
      
      reinsert = Sorter.removeElementToInsertLater(this.list);

      this.list.innerHTML = '';
      sortedItems = Sorter.prototype.sortDataMap(this);

      for (i = 0, len = sortedItems.length; i < len; i++) {
        sortedItem = sortedItems[i];
        this.list.appendChild(sortedItem.item);
      }

      return reinsert();
    };

    return Sorter;
  })();

  // Run the standard initializer
  function initialize (node) {
    var sorter = new Sorter(node);
    node.movielogSorter = sorter;

    return node.movielogSorter;
  }

  // Use an object instead of a function for future expansibility;
  return {
    create: initialize
  };
}));
