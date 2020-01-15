import { showModal, hideModal } from '../src/toggle_modal.js'
import { addToMetadata, checkAll, checkboxToLabel, enableSaveButton,
         getElementsList } from '../src/basket.js'

$(document).ready(function() {
  var selectedElements = getElementsList()
  var selectedElementKeys = Object.keys(selectedElements)

  document.querySelector('#save-to-list').addEventListener('click', addToMetadata)
  document.querySelector('#data-element-all').addEventListener('change', checkAll)

  document.querySelectorAll('.basket-checkbox').forEach(function(element) {
    if (selectedElementKeys.indexOf(element.dataset.id) > -1) {
      checkboxToLabel(element)
    } else {
      element.addEventListener('change', enableSaveButton)
    }
  })
})
