import { showModal, hideModal } from '../src/toggle_modal.js'
import { toggleMetadata, checkAll, getElementsList } from '../src/basket.js'

$(document).ready(function() {
  var selectedElements = getElementsList()
  var selectedElementKeys = Object.keys(selectedElements)

  $('#data-element-all').change(checkAll);

  $('.basket-checkbox').each(function(idx, element) {
    if (selectedElementKeys.indexOf(element.dataset.id) > -1) {
      element.checked = true
    }

    element.addEventListener('change', toggleMetadata)
  })
})
