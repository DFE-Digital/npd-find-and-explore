function getElementsList() {
  var list = localStorage.getItem('elementsList')
  return (list ? JSON.parse(localStorage.getItem('elementsList')) : {})
}

function addDetailToList(id, name, value) {
  if (!id) {
    return
  }

  var elementsList = getElementsList()
  elementsList[id][name] = value
  localStorage.setItem('elementsList', JSON.stringify(elementsList))
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

  removeElementFromMetadata(event.currentTarget)
}

function removeElementFromMetadata(target) {
  var elementsList = getElementsList()
  delete elementsList[target.id]
  target.parentElement.parentElement.remove()
  labelToCheckbox(document.querySelector('#data-element-' + target.id))

  if (document.querySelector('#npd-counter')) {
    document.querySelector('#npd-counter').innerText = Object.keys(elementsList).length
  }
  localStorage.setItem('elementsList', JSON.stringify(elementsList))
}

function removeDatasetFromMetadata(event) {
  event.preventDefault()
  var target = event.currentTarget

  document.querySelectorAll('.item-remove[data-dataset-id="' + target.id + '"]').forEach(function(element) {
    removeElementFromMetadata(element)
  })
  if (document.querySelector('table[data-dataset-id="' + target.id + '"]')) {
    document.querySelector('table[data-dataset-id="' + target.id + '"]').remove()
  }
}

function removeAllFromMetadata(event) {
  event.preventDefault()
  if (!confirm('This will remove all saved items in this list')) {
    return
  }

  var elementsList = getElementsList()
  document.querySelectorAll('.item-remove').forEach(function(element) {
    removeElementFromMetadata(element)
  })
  document.querySelectorAll('table[data-dataset-id]').forEach(function(element) {
    element.remove()
  })
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

function validateDateRange(event) {
  var target = event.currentTarget
  var id = target.id
  var match = /elements_(.+)_years_(from|to)/.exec(id)
  if (!match) {
    return
  }

  var elementId = match[1]
  var selectFrom = document.querySelector('#' + id.replace(/(from|to)/, 'from'))
  var selectTo = document.querySelector('#' + id.replace(/(from|to)/, 'to'))

  if (match[2] === 'from' && !!selectFrom.value) {
    var fromValue = parseInt(selectFrom.value)
    addDetailToList(elementId, 'yearFrom', selectFrom.value)

    selectTo.querySelectorAll('option').forEach(function(option) {
      if (!option.value) { return }

      parseInt(option.value) >= fromValue
        ? option.disabled = false
        : option.disabled = true
    })
  } else if(match[2] === 'to' && !!selectTo.value) {
    var toValue = parseInt(selectTo.value)
    addDetailToList(elementId, 'yearTo', selectTo.value)

    selectFrom.querySelectorAll('option').forEach(function(option) {
      if (!option.value) { return }

      parseInt(option.value) <= toValue
        ? option.disabled = false
        : option.disabled = true
    })
  }

  if (!selectFrom.value || !selectTo.value) {
    return
  }

  if (parseInt(selectFrom.value) > parseInt(selectTo.value)) {
    selectFrom.setCustomValidity('Must be before the end year')
    selectTo.setCustomValidity('Must be after the start year')
    target.reportValidity()
  } else {
    addDetailToList(elementId, 'yearFrom', selectFrom.value)
    addDetailToList(elementId, 'yearTo', selectTo.value)
    selectFrom.setCustomValidity('')
    selectTo.setCustomValidity('')
  }
}

function persistAdditionalNotes(event) {
  var id = event.currentTarget.id
  var match = /elements_(.+)_notes/.exec(id)
  var elementId = match[1]

  addDetailToList(elementId, 'notes', event.currentTarget.value)
}

export { addToMetadata, checkAll, checkboxToLabel, enableSaveButton,
         getElementsList, persistAdditionalNotes, removeAllFromMetadata,
         removeDatasetFromMetadata, removeFromMetadata, validateDateRange }
