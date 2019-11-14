import { showModal, hideModal } from '../src/toggle_modal.js'

// Accessible Modal
$(document).ready(function() {
  // show modal and overlay and lock scroll
  $('.show-modal').click(showModal);

  //hide modal and overlay
  $('.close-modal').click(hideModal);
});
