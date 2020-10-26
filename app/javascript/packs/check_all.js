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
  document.querySelector('[data-check-all=true]').addEventListener('change', checkAll);
})
