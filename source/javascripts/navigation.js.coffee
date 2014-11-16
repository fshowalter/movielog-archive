//= require _gator-1.2.3

hide = (menu, toggle) ->
  return unless menu.classList.contains('in')

  menu.style.height = getComputedStyle(menu).height
  menu.offsetHeight
  menu.classList.add('js-collapsing')
  menu.classList.remove('js-collapse', 'in')
  menu.setAttribute('aria-expanded', false)

  toggle.classList.add('collapsed')
  toggle.setAttribute('aria-expanded', false)

  Gator(menu).on 'transitionend', (event) ->
    if event.propertyName == 'height'
      Gator(@).off 'transitionend'
      @.classList.remove('js-collapsing')
      @.classList.add('js-collapse')

  menu.style.height = '0'

show = (menu, toggle) ->
  return if menu.classList.contains('in')

  menu.classList.remove('js-collapse')
  menu.classList.add('js-collapsing')
  menu.style.height = '0'
  menu.setAttribute('aria-expanded', true)

  toggle.classList.remove('js-collapsed')
  toggle.setAttribute('aria-expanded', true)

  Gator(menu).on 'transitionend', (event) ->
    if event.propertyName == 'height'
      Gator(@).off 'transitionend'
      @.classList.remove('js-collapsing')
      @.classList.add('js-collapse', 'in')
      @.style.height = ''

  menu.style.height = menu.scrollHeight + 'px'

Gator(document).on 'click', '[data-toggle]', (e) ->
  menu = @.nextSibling

  if menu.classList.contains('in')
    hide(menu, @)
  else
    show(menu, @)
