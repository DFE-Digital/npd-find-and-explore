import { showModal, hideModal } from '../src/toggle_modal.js'
import { addItemToList, copyToClipboard, getElementsList } from '../src/basket.js'

// Accessible Modal
$(document).ready(function() {
  var selectedElements = getElementsList()
  var selectedElementKeys = Object.keys(selectedElements)

  // set the counter
  document.querySelector('#npd-counter').innerText = selectedElementKeys.length

  // copy to clipboard
  document.querySelector('#copy-to-clipboard').addEventListener('click', copyToClipboard)

  // fill the modal
  selectedElementKeys.forEach(function(key) {
    addItemToList(selectedElements[key])
  })

  // show modal and overlay and lock scroll
  $('.show-modal').click(showModal);

  // hide modal and overlay
  $('.close-modal').click(hideModal);
});
