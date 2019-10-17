function hideOverflow(element) {
  element.className = element.className + ' collapsed'
}

function showOverflow(element) {
  element.className = element.className.replace(/collapsed/, '')
}

function addExpandLink(element) {
  var link = document.createElement('a', { href: '#' })
  link.className = 'expand'
  link.innerHTML = 'Show more'
  element.parentNode.appendChild(link)

  link.addEventListener('click', function(event) {
    var target = event.currentTarget
    showOverflow(target.previousElementSibling)
    addCollapseLink(target.previousElementSibling)
    target.parentNode.removeChild(target)
  })
}

function addCollapseLink(element) {
  var link = document.createElement('a', { href: '#' })
  link.className = 'collapse'
  link.innerHTML = 'Show less'
  element.parentNode.appendChild(link)

  link.addEventListener('click', function(event) {
    var target = event.currentTarget
    hideOverflow(target.previousElementSibling)
    addExpandLink(target.previousElementSibling)
    target.parentNode.removeChild(target)
  })
}

$( document ).ready(function() {
  document.querySelectorAll('.collapsible').forEach(function(element) {
    hideOverflow(element)
    addExpandLink(element)
  })
})
