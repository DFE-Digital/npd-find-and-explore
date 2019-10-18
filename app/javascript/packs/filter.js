
function submitFilter(event) {
  var target = event.currentTarget
  var name = target.name
  var value = target.value
  var query = window.location.search.replace(/^\?/, '').split('&')
  var regexp = new RegExp('^' + name.replace(/\[/g, '\\[').replace(/\]/g, '\\]') + '=' + value)

  var newQuery
  if (target.checked) {
    query.push(name + '=' + value)
    newQuery = query.filter(function(value, index, self) { return self.indexOf(value) === index } )
  } else {
    newQuery = query.filter(function (element) { return !regexp.test(element) })
  }

  window.location.search = '?' + newQuery.join('&')
}

$(document).ready(function() {
  document.querySelectorAll('.govuk-checkboxes__input').forEach(function(element) {
    element.addEventListener('change', submitFilter)
  })
})
