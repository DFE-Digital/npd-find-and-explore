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

function checkAll(event) {
  var checked = event.currentTarget.checked
  $('.basket-checkbox').each(function(idx, element) {
    if (element.checked != checked) {
      $(element).trigger('click')
    }
  })
}

function removeFromMetadata(event) {
  event.preventDefault()
  var target = event.currentTarget

  $('tr#' + target.id + '_data').remove()
  $('tr#' + target.id + '_description').remove()
  removeElementFromMetadata(target)
}

function removeElementFromMetadata(target) {
  var elementsList = getElementsList()
  delete elementsList[target.id]

  if (document.querySelector('#npd-counter')) {
    document.querySelector('#npd-counter').innerText = Object.keys(elementsList).length
  }
  localStorage.setItem('elementsList', JSON.stringify(elementsList))
}

function removeDatasetFromMetadata(event) {
  event.preventDefault()
  var target = event.currentTarget

  $('.item-remove[data-dataset-id="' + target.id + '"]').each(function(idx, element) {
    removeElementFromMetadata(element)
  })
  $(target).parents('table[data-dataset-id="' + target.id + '"]').remove()
}

function removeAllFromMetadata(event) {
  event.preventDefault()
  if (!confirm('This will remove all saved items in this list')) {
    return
  }

  var target = event.currentTarget
  var elementsList = getElementsList()
  $('.item-remove').each(function(idx, element) {
    removeElementFromMetadata(element)
  })
  $(target).parents('form').siblings('.no-elements').removeClass('hidden')
  $(target).parents('form').remove()
}

function toggleMetadata(event) {
  var elementsList = getElementsList()
  var element = event.currentTarget

  console.log('toggle metadata for', element.dataset.id)
  if (!element.checked) {
    removeElementFromMetadata(element.dataset)
  } else if (!elementsList[element.dataset.id]) {
    elementsList[element.dataset.id] = element.dataset

    var count = Object.keys(elementsList).length
    document.querySelector('#npd-counter').innerText = count

    localStorage.setItem('elementsList', JSON.stringify(elementsList))
    localStorage.setItem('countElements', count)
  }
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

    $(selectTo).children('option').each(function(idx, option) {
      if (!option.value) { return }

      parseInt(option.value) >= fromValue
        ? option.disabled = false
        : option.disabled = true
    })
  } else if(match[2] === 'to' && !!selectTo.value) {
    var toValue = parseInt(selectTo.value)
    addDetailToList(elementId, 'yearTo', selectTo.value)

    $(selectFrom).children('option').each(function(idx, option) {
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

export { toggleMetadata, checkAll, getElementsList, persistAdditionalNotes,
         removeAllFromMetadata, removeDatasetFromMetadata, removeFromMetadata,
         validateDateRange }
