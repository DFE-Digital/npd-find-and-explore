function getElementsList() {
  var list = localStorage.getItem('elementsList')
  return (list ? JSON.parse(localStorage.getItem('elementsList')) : {})
}

function checkboxToLabel(element) {
  element.parentElement.outerHTML = '<a href="" class="show-modal"><strong class="saved govuk-tag govuk-!-font-size-14">saved</strong></a>'
}

function addToMetadata(event) {
  var elementsList = getElementsList()
  document.querySelector('#save-to-metadata').setAttribute('disabled', true)

  document.querySelectorAll('.basket-checkbox').forEach(function(element) {
    if (element.checked) {
      elementsList[element.dataset.id] = element.dataset
      checkboxToLabel(element)
    }
  })
  count = Object.keys(elementsList).length
  document.querySelector('#npd-counter').innerText = count

  localStorage.setItem('elementsList', JSON.stringify(elementsList))
  localStorage.setItem('countElements', count)
}

function checkAll(event) {
  var checked = event.currentTarget.checked
  if (checked) {
    document.querySelector('#save-to-metadata').removeAttribute('disabled')
  } else {
    document.querySelector('#save-to-metadata').setAttribute('disabled', true)
  }
  document.querySelectorAll('.basket-checkbox').forEach(function(element) {
    element.checked = checked
  })
}

function activateAdd(event) {
  var list = document.querySelectorAll('.basket-checkbox')
  var enable = false
  var count = 0
  for(var i = 0; i < list.length; i++) {
    enable = enable || list[i].checked
    if (list[i].checked) { count = count + 1 }
  }
  enableSaveButton(enable, count, list.length)
}

function enableSaveButton(enable, count, length) {
  if (!enable) {
    document.querySelector('#data-element-all').checked = false
    document.querySelector('#save-to-metadata').setAttribute('disabled', true)
  } else {
    document.querySelector('#save-to-metadata').removeAttribute('disabled')
    if (count === length)
      document.querySelector('#data-element-all').checked = true
  }
}

$(document).ready(function() {
  var selectedElements = Object.keys(getElementsList())

  document.querySelector('#npd-counter').innerText = selectedElements.length

  document.querySelector('#save-to-metadata').addEventListener('click', addToMetadata)
  document.querySelector('#data-element-all').addEventListener('change', checkAll)
  document.querySelectorAll('.basket-checkbox').forEach(function(element) {
    if (selectedElements.indexOf(element.dataset.id) > -1) {
      checkboxToLabel(element)
    } else {
      element.addEventListener('change', activateAdd)
    }
  })
})
