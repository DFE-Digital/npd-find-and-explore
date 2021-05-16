import '../src/loader.scss'

import displayLoader from '../src/loader-display.js'
import $ from 'jquery'
import '../src/govuk-frontend.js'

$(document).on('ajax:success', function(event) {
  var detail = event.detail
  var data = detail[0], status = detail[1], xhr = detail[2]

  setTimeout(function() {
    $('#govuk-box-container').hide()
    $('.main-content__header').show()
    $('fieldset').show()
    $('.govuk-breadcrumbs').show()
    document.querySelector('#form-group').outerHTML = detail[0].body.innerHTML
    document.getElementById('submit-upload').removeAttribute('disabled')
    $('.loader-on-submit').submit(displayLoader)
  }, 500)
})
