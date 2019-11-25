import '../src/loader.scss'
import '../src/loader.js'
import $ from 'jquery'

window.loader = new GOVUK.Loader()

$(document).ready(function() {
  $('#govuk-box-message').show()
  window.loader.init({
    container: 'govuk-box-message',
    label: true,
    labelText: 'Your data is being loaded'
  })

  $.ajax({
    type: 'GET',
    url: location.pathname.replace(/datasets/, 'datasets/data_elements'),
    dataType: 'html',
    success: function(response, status, xhr) {
      setTimeout(function() {
        $('#govuk-box-message').hide()
        window.loader.stop()

        $('.govuk-table__body').html(response)
      }, 500)
    }
  })
})
