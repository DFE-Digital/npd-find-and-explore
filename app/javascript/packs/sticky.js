$(document).ready(function() {
  var header = document.querySelector('#page-header')
  header.className = header.className + ' sticky-page-header'

  var button = document.querySelector('#save-to-list-header')
  button.className = button.className + ' sticky-save-to-list'

  var elementsHeader = document.querySelector('#data-elements-header')
  elementsHeader.className = elementsHeader.className + ' sticky-data-elements-header'
})
