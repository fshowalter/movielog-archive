//= require _jquery
//= require _jquery.liblink
//= require _nouislider-8.0.1
//= require _sorter
//= require _filterer
//= require _text-filter
//= require _range-filter

getQueryParameters = (str) ->
  (str or document.location.search).replace(/(^\?)/, '').split('&').map(((n) ->
    n = n.split('=')
    @[n[0]] = n[1]
    this
  ).bind({}))[0]

params = getQueryParameters()


for key, value of params
  filter = $('[data-filter-attribute=data-' + key.toLowerCase() + ']').first()
  next unless filter
  filter.val(decodeURI(value));
  filter.trigger('keyup')
  