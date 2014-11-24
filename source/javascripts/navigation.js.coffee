//= require _gator-1.2.3

hide = (menu, toggle) ->
  return if menu.classList.contains('js-collapsed')

  # menu.style.height = getComputedStyle(menu).height
  # menu.offsetHeight
  # menu.classList.add('js-collapse')
  menu.classList.add('js-collapsing', 'js-collapsed')
  menu.setAttribute('aria-expanded', false)

  # toggle.classList.add('collapsed')
  toggle.setAttribute('aria-expanded', false)

  Gator(menu).on 'transitionend', (event) ->
    if event.propertyName == 'height'
      Gator(@).off 'transitionend'
      @.classList.remove('js-collapsing')
      # @.classList.add('js-collapsed')

  # menu.style.height = '0'

show = (menu, toggle) ->
  return unless menu.classList.contains('js-collapsed')

  menu.classList.add('js-collapsing')
  menu.classList.remove('js-collapsed')
  # menu.style.height = '0'
  menu.setAttribute('aria-expanded', true)

  # toggle.classList.remove('js-collapsed')
  toggle.setAttribute('aria-expanded', true)

  Gator(menu).on 'transitionend', (event) ->
    if event.propertyName == 'height'
      Gator(@).off 'transitionend'
      @.classList.remove('js-collapsing')

  # menu.style.height = menu.scrollHeight + 'px'

Gator(document).on 'click', '[data-toggle]', (e) ->
  menu = @.nextSibling

  return if menu.classList.contains('js-collapsing')

  if menu.classList.contains('js-collapsed')
    show(menu, @)
  else
    hide(menu, @)

