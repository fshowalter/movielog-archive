//= require _gator

hide = (menu, toggle) ->
  return if menu.classList.contains('js-toggle-off')

  menu.classList.add('js-toggling', 'js-toggle-off')
  menu.setAttribute('aria-expanded', false)

  toggle.setAttribute('aria-expanded', false)

  Gator(menu).on 'transitionend', (event) ->
    if event.propertyName == 'width' || event.propertyName == 'opacity'
      Gator(@).off 'transitionend'
      @.classList.remove('js-toggling')
      toggle.innerHTML = toggle.getAttribute('data-toggle-label')

show = (menu, toggle) ->
  return unless menu.classList.contains('js-toggle-off')

  menu.classList.add('js-toggling')
  menu.classList.remove('js-toggle-off')
  menu.setAttribute('aria-expanded', true)

  toggle.setAttribute('aria-expanded', true)

  Gator(menu).on 'transitionend', (event) ->
    if event.propertyName == 'width' || event.propertyName == 'opacity'
      Gator(@).off 'transitionend'
      @.classList.remove('js-toggling')
      toggle.innerHTML = 'Cancel'
      if (!/iPad|iPhone|iPod/g.test(navigator.userAgent))
        @.querySelectorAll('input[type="text"]')[0].focus()
      

Gator(document).on 'click', '[data-toggle]', (e) ->
  menu = @.nextSibling

  @.setAttribute('data-toggle-label', @.innerHTML) unless @.getAttribute('data-toggle-label')

  # if @.classList.contains('js-open') then @.classList.remove('js-open') else @.classList.add('js-open')

  return if menu.classList.contains('js-toggling')

  if menu.classList.contains('js-toggle-off') 
    show(menu, @) 
  else 
    hide(menu, @)

document.documentElement.classList.add('js')


Gator(document).on 'mousedown', (e) ->
  document.documentElement.classList.add('js-no-outline')

Gator(document).on 'keydown', (e) ->
  document.documentElement.classList.remove('js-no-outline')

