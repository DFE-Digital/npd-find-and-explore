import $ from 'jquery'

function hideOverflow(element) {
  element.className = element.className + ' collapsed'
}

function showOverflow(element) {
  element.className = element.className.replace(/collapsed/, '')
}

function appendLink(element, className, innerHTML) {
  var link = document.createElement('a', { href: '#' })
  link.className = className
  link.innerHTML = innerHTML
  element.parentNode.appendChild(link)
  return link
}

function addExpandLink(element) {
  var link = appendLink(element, 'expand', 'Show more')

  link.addEventListener('click', function(event) {
    var target = event.currentTarget
    showOverflow(target.previousElementSibling)
    addCollapseLink(target.previousElementSibling)
    target.parentNode.removeChild(target)
  })
}

function addCollapseLink(element) {
  var link = appendLink(element, 'collapse', 'Show less')

  link.addEventListener('click', function(event) {
    var target = event.currentTarget
    hideOverflow(target.previousElementSibling)
    addExpandLink(target.previousElementSibling)
    target.parentNode.removeChild(target)
  })
}

function submitFilter(event) {
  var target = event.currentTarget
  var name = target.name
  var value = target.value
  var query = window.location.search.replace(/^\?/, '').split('&')
  var regexp = new RegExp('^' + name + '[]=' + value)

  var newQuery
  if (target.checked) {
    query.push(name + '[]=' + value)
    newQuery = query.filter(function(value, index, self) { return self.indexOf(value) === index } )
  } else {
    newQuery = query.filter(function (element) { return !regexp.test(element) })
  }

  window.location.search = '?' + newQuery.join('&')
}

$(document).ready(function() {
  document.querySelectorAll('.collapsible').forEach(function(element) {
    hideOverflow(element)
    addExpandLink(element)
  })

  document.querySelectorAll('.govuk-checkboxes__input').forEach(function(element) {
    element.addEventListener('change', submitFilter)
  })
})
