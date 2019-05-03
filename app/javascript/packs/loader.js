import '../src/loader.scss'

import '../src/loader.js'
import $ from 'jquery'

window.loader = new GOVUK.Loader()

$(document).on('ajax:send', function() {
  if (/import/.test(event.target.action)) {
    $('.govuk-form-group').removeClass('govuk-form-group--error')
    $('#upload-file-error span.message').html('')
    $('#upload-file-success').addClass('govuk-visually-hidden')
    $('#govuk-box-message').show()
    window.loader.init({
      container: 'govuk-box-message',
      label: true,
      labelText: 'We are processing the file you uploaded, please wait'
    })
  }
})

$(document).on('ajax:complete', function() {
  setTimeout(function() {
    $('#govuk-box-message').hide()
    window.loader.stop()
  }, 500)
})
