//= require _gator

hide = (menu, body, toggle) ->
  # return if body.classList.contains('js-nav-closed')

  body.classList.remove('js-nav-open')
  menu.setAttribute('aria-expanded', false)
  toggle.setAttribute('aria-expanded', false)

  # Gator(menu).on 'transitionend', (event) ->
  #   if event.propertyName == 'height'
  #     Gator(@).off 'transitionend'
  #     @.classList.remove('js-collapsing')

show = (menu, body, toggle) ->
  body.classList.add('js-nav-open')
  menu.setAttribute('aria-expanded', true)
  toggle.setAttribute('aria-expanded', true)
  
  # Gator(menu).on 'transitionend', (event) ->
  #   if event.propertyName == 'height'
  #     Gator(@).off 'transitionend'
  #     @.classList.remove('js-collapsing')

document.documentElement.classList.add('js-nav')

Gator(document).on 'click', '[data-nav-toggle]', (e) ->
  menu = @.nextSibling
  body = document.body
 
  # return if body.classList.contains('js-nav-collapsing')

  if body.classList.contains('js-nav-open') 
    hide(menu, body, @)
  else 
    show(menu, body, @) 
    

