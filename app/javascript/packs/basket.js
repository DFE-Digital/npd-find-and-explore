function checkAll(event) {
  var checked = event.currentTarget.checked
  if (checked) {
    document.querySelector('#save-to-metadata').removeAttribute('disabled')
  } else {
    document.querySelector('#save-to-metadata').setAttribute('disabled', true)
  }
  document.querySelectorAll('.basket-checkbox').forEach(function(element) {
    element.checked = checked
  })
}

function activateAdd(event) {
  var list = document.querySelectorAll('.basket-checkbox')
  var enable = false
  var count = 0
  for(var i = 0; i < list.length; i++) {
    enable = enable || list[i].checked
    if (list[i].checked) { count = count + 1 }
  }
  if (!enable) {
    document.querySelector('#data-element-all').checked = false
    document.querySelector('#save-to-metadata').setAttribute('disabled', true)
  } else {
    document.querySelector('#save-to-metadata').removeAttribute('disabled')
    if (count === list.length)
      document.querySelector('#data-element-all').checked = true
  }
}

$(document).ready(function() {
  document.querySelector('#data-element-all').addEventListener('change', checkAll)
  document.querySelectorAll('.basket-checkbox').forEach(function(element) {
    element.addEventListener('change', activateAdd)
  })
})
