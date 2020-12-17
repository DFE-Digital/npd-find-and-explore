import { getFromLocalStorage, addToLocalStorage } from './local_storage.js'

function removeFromMetadata(event) {
  event.preventDefault()
  var target = event.currentTarget

  $('tr#' + target.id + '_data').remove()
  $('tr#' + target.id + '_description').remove()
  removeElementFromMetadata(target)
}

function removeElementFromMetadata(target) {
  var elementsList = getFromLocalStorage('elementsList')
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
  var elementsList = getFromLocalStorage('elementsList')
  $('.item-remove').each(function(idx, element) {
    removeElementFromMetadata(element)
  })
  $(target).parents('form').siblings('.no-elements').removeClass('hidden')
  $(target).parents('form').remove()
}

function toggleMetadata(event) {
  var elementsList = getFromLocalStorage('elementsList')
  var element = event.currentTarget

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

export { toggleMetadata, removeAllFromMetadata, removeDatasetFromMetadata,
         removeFromMetadata }
