$ = window.jQuery

toggle = (value) -> if value then 'addClass' else 'removeClass'

$(document).on('input', '.clearable-wrap', (e) ->
  target = e.target
  $(@)[toggle target.value]('has-value')
)

$(document).on('mousemove', '.has-value', (e) ->
  $(@)[toggle(@.offsetWidth - 22 < e.clientX - @.getBoundingClientRect().left)]('is-on-clear-button');
)

$(document).on('click', '.is-on-clear-button', (e) ->
  $(@).removeClass('has-value is-on-clear-button')
  $(@).find('input').val('').trigger('keyup')
)