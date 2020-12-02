import $ from 'jquery';

function checkAll(event) {
  var checked = event.currentTarget.checked;
  var targets = event.currentTarget.dataset.checkClass;

  $('.' + targets).each(function(idx, element) {
    if (element.checked != checked) {
      $(element).trigger('click');
    }
  })
}

$(document).ready(function() {
  if (document.querySelector('[data-check-all=true]')) {
    document.querySelector('[data-check-all=true]').addEventListener('change', checkAll);
  }
})
