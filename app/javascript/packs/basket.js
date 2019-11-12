function checkAll(event) {
  document.querySelectorAll('.basket-checkbox').forEach(function(element) {
    element.checked = event.currentTarget.checked
  })
}

$(document).ready(function() {
  document.querySelector('#data-element-all').addEventListener('change', checkAll)
})
