function getElementsList() {
  var list = localStorage.getItem('elementsList')
  return (list ? JSON.parse(localStorage.getItem('elementsList')) : {})
}

function generateDescription(element) {
  if (element === null || element === undefined || element === {}) {
    return ''
  }
  var dataset = JSON.parse(element.datasets)[0]
  return [dataset, element.npdAlias].join('.')
}

function checkboxToLabel(element) {
  var label = element.parentElement.previousElementSibling
  element.parentElement.className = element.parentElement.className + ' hidden'
  label.className = label.className.replace(/hidden/, '')
}

function labelToCheckbox(element) {
  if (element === null) {
    return
  }

  var label = element.parentElement.previousElementSibling
  element.checked = false
  element.parentElement.className = element.parentElement.className.replace(/hidden/, '')
  label.className = label.className + ' hidden'
}

function checkAll(event) {
  var checked = event.currentTarget.checked
  if (checked) {
    document.querySelector('#save-to-list').removeAttribute('disabled')
  } else {
    document.querySelector('#save-to-list').setAttribute('disabled', true)
  }
  document.querySelectorAll('.basket-checkbox').forEach(function(element) {
    element.checked = checked
  })
}

function removeFromMetadata(event) {
  event.preventDefault()

  var target = event.currentTarget
  var elementsList = getElementsList()
  delete elementsList[target.id]
  target.parentElement.parentElement.remove()
  labelToCheckbox(document.querySelector('#data-element-' + target.id))

  document.querySelector('#npd-counter').innerText = Object.keys(elementsList).length
  localStorage.setItem('elementsList', JSON.stringify(elementsList))
}

function removeAllFromMetadata(event) {
  event.preventDefault()
  if (!confirm('This will remove all saved items in this list')) {
    return
  }

  var elementsList = getElementsList()
  var buttons = document.querySelectorAll('.item-remove')

  for(var i = 0; i < buttons.length; i++) {
    var id = buttons[i].id
    if (id === '') {
      continue
    }

    delete elementsList[id]
    buttons[i].parentElement.parentElement.remove()
    labelToCheckbox(document.querySelector('#data-element-' + id))
  }

  document.querySelector('#npd-counter').innerText = Object.keys(elementsList).length
  localStorage.setItem('elementsList', JSON.stringify(elementsList))
}

function enableSaveButton(event) {
  var list = document.querySelectorAll('.basket-checkbox')
  var enable = false
  var count = 0
  for(var i = 0; i < list.length; i++) {
    enable = enable || list[i].checked
    if (list[i].checked) { count = count + 1 }
  }

  if (!enable) {
    document.querySelector('#data-element-all').checked = false
    document.querySelector('#save-to-list').setAttribute('disabled', true)
  } else {
    document.querySelector('#save-to-list').removeAttribute('disabled')
    if (count === length)
      document.querySelector('#data-element-all').checked = true
  }
}

function addToMetadata(event) {
  var elementsList = getElementsList()
  document.querySelector('#save-to-list').setAttribute('disabled', true)

  document.querySelectorAll('.basket-checkbox').forEach(function(element) {
    if (element.checked && !elementsList[element.dataset.id]) {
      elementsList[element.dataset.id] = element.dataset
      checkboxToLabel(element)
    }
  })
  var count = Object.keys(elementsList).length
  document.querySelector('#npd-counter').innerText = count

  localStorage.setItem('elementsList', JSON.stringify(elementsList))
  localStorage.setItem('countElements', count)
}

function copyToClipboard(event) {
  var elementsList = getElementsList()
  var success = document.querySelector('.npd-copy-success-container')
  var textarea = document.createElement('textarea')
  textarea.textContent = Object.values(elementsList)
                               .map(function(e) { return generateDescription(e) })
                               .join("\n")
  event.currentTarget.append(textarea)
  textarea.focus()
  textarea.select()
  document.execCommand('copy')
  textarea.remove()

  success.className = success.className.replace(/invisible */g, 'visible ')

  setTimeout(function() {
    success.className = success.className.replace(/visible */g, 'invisible ')
  }, 5000)
}

export { addToMetadata, checkAll, checkboxToLabel, copyToClipboard, enableSaveButton,
         getElementsList, removeAllFromMetadata, removeFromMetadata }
