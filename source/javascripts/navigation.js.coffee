//= require _gator-1.2.3

hide = (menu, toggle) ->
  return if menu.classList.contains('js-collapsed')

  menu.classList.add('js-collapsed')
  menu.setAttribute('aria-expanded', false)
  toggle.setAttribute('aria-expanded', false)

show = (menu, toggle) ->
  return unless menu.classList.contains('js-collapsed')

  menu.classList.remove('js-collapsed')
  menu.setAttribute('aria-expanded', true)

  toggle.setAttribute('aria-expanded', true)

Gator(document).on 'click', '[data-toggle]', (e) ->
  menu = @.nextSibling

  if menu.classList.contains('js-collapsed')
    show(menu, @)
  else
    hide(menu, @)

