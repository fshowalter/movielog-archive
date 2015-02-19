//= require _gator

hide = (menu, toggle) ->
  return if menu.classList.contains('js-collapsed')

  menu.classList.add('js-collapsing', 'js-collapsed')
  menu.setAttribute('aria-expanded', false)

  toggle.setAttribute('aria-expanded', false)

  Gator(menu).on 'transitionend', (event) ->
    if event.propertyName == 'height'
      Gator(@).off 'transitionend'
      @.classList.remove('js-collapsing')

show = (menu, toggle) ->
  return unless menu.classList.contains('js-collapsed')

  menu.classList.add('js-collapsing')
  menu.classList.remove('js-collapsed')
  menu.setAttribute('aria-expanded', true)

  toggle.setAttribute('aria-expanded', true)

  Gator(menu).on 'transitionend', (event) ->
    if event.propertyName == 'height'
      Gator(@).off 'transitionend'
      @.classList.remove('js-collapsing')


Gator(document).on 'click', '[data-toggle]', (e) ->
  menu = @.nextSibling

  if @.classList.contains('js-open') then @.classList.remove('js-open') else @.classList.add('js-open')

  return if menu.classList.contains('js-collapsing')

  if menu.classList.contains('js-collapsed') then show(menu, @) else hide(menu, @)

