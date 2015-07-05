// = require _gator

/* global Gator */

(
  function initSearchToggle() {
    'use strict';

    function hide(menu, toggle) {
      if (menu.classList.contains('js-toggle_off')) {
        return;
      }

      menu.classList.add('js-toggling', 'js-toggle_off');
      menu.setAttribute('aria-expanded', false);
      toggle.setAttribute('aria-expanded', false);

      Gator(menu).on('transitionend', function handleTransitionEnd(event) {
        if (event.propertyName === 'width' || event.propertyName === 'opacity') {
          Gator(this).off('transitionend');
          this.classList.remove('js-toggling');
          toggle.innerHTML = toggle.getAttribute('data-toggle-label');
        }
      });
    }

    function show(menu, toggle) {
      if (!menu.classList.contains('js-toggle_off')) {
        return;
      }

      menu.classList.add('js-toggling');
      menu.classList.remove('js-toggle_off');
      menu.setAttribute('aria-expanded', true);
      toggle.setAttribute('aria-expanded', true);

      Gator(menu).on('transitionend', function handleTransitionEnd(event) {
        if (event.propertyName === 'width' || event.propertyName === 'opacity') {
          Gator(this).off('transitionend');
          this.classList.remove('js-toggling');
          toggle.innerHTML = 'Cancel';
          if (!/iPad|iPhone|iPod/g.test(navigator.userAgent)) {
            return this.querySelectorAll('input[type="text"]')[0].focus();
          }
        }
      });
    }

    Gator(document).on('click', '[data-toggle]', function handleSearchToggleClick() {
      var menu;
      menu = this.nextSibling;

      if (!this.getAttribute('data-toggle-label')) {
        this.setAttribute('data-toggle-label', this.innerHTML);
      }

      if (menu.classList.contains('js-toggling')) {
        return;
      }

      if (menu.classList.contains('js-toggle_off')) {
        show(menu, this);
      } else {
        hide(menu, this);
      }
    });

    document.documentElement.classList.add('js');

    document.documentElement.addEventListener('mousedown', function handleMouseDownToRemoveOutline() {
      return document.documentElement.classList.add('js-no_outline');
    });

    document.documentElement.addEventListener('keydown', function handleKeyDownToAddOutline() {
      return document.documentElement.classList.remove('js-no_outline');
    });
  }()
);


