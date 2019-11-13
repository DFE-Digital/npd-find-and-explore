function findModal(element) {
  var tabbable = element.find('select, input, textarea, button, a').filter(':visible');
  var firstTabbable = tabbable.first();
  var lastTabbable = tabbable.last();

  // set focus on first tabbable element
  firstTabbable.focus();

  // send last tabbable back to first
  lastTabbable.on('keydown', function (event) {
    if ((event.which === 9 && !event.shiftKey)) {
      event.preventDefault();
      firstTabbable.focus();
    }
  });

  // send last shift tabbable back to last
  firstTabbable.on('keydown', function (event) {
    if ((event.which === 9 && event.shiftKey)) {
      event.preventDefault();
      lastTabbable.focus();
    }
  });

  // allow esc to close Modal
  element.on('keyup', function(event){
    if (event.keyCode === 27 ) {
      closeModal(event)
    };
  });
};

function showModal(event) {
  event.preventDefault();

  $('.npd-basket-modal').show();
  $('.npd-basket-modal-overlay').show();
  $('html').addClass('noscroll');
  findModal($('.npd-basket-modal'));
}

function hideModal(event){
  event.preventDefault();

  $('.npd-basket-modal').hide();
  $('.npd-basket-modal-overlay').hide();
  $('html').removeClass('noscroll');
}

export { findModal, showModal, hideModal }
