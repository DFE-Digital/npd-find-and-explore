import { showModal, hideModal } from '../src/toggle_modal.js'
import { getElementsList, removeAllFromMetadata } from '../src/basket.js'

// Accessible Modal
$(document).ready(function() {
  var selectedElements = getElementsList()
  var selectedElementKeys = Object.keys(selectedElements)

  // set the counter
  if(document.querySelector('#npd-counter')) {
    document.querySelector('#npd-counter').innerText = selectedElementKeys.length
  }
});
