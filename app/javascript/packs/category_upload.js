import $ from 'jquery'
import '../src/govuk-frontend.js'

$(document).on('ajax:success', function(event) {
  var detail = event.detail
  var data = detail[0], status = detail[1], xhr = detail[2]

  setTimeout(function() {
    document.querySelector('#form-group').outerHTML = detail[0].body.innerHTML
    document.getElementById('submit-upload').removeAttribute('disabled')
  }, 500)
})
