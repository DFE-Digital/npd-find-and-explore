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

$(document).ready(function() {
  $('.collapsible').each(function(element) {
    if (element.clientHeight >= 144) {
      hideOverflow(element)
      addExpandLink(element)
    }
  })
})
