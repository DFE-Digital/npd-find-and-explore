import '../src/loader.scss'
import '../src/loader.js'
import { getElementsList, checkboxToLabel, enableSaveButton } from '../src/basket.js'
import { initializeOverlays } from '../src/overlay.js'
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
      var selectedElements = getElementsList()
      var selectedElementKeys = Object.keys(selectedElements)

      setTimeout(function() {
        $('#govuk-box-message').hide()
        window.loader.stop()

        $('.govuk-table__body').html(response)
        initializeOverlays()
        document.querySelectorAll('.basket-checkbox').forEach(function(element) {
          if (selectedElementKeys.indexOf(element.dataset.id) > -1) {
            checkboxToLabel(element)
          } else {
            element.addEventListener('change', enableSaveButton)
          }
        })
      }, 500)
    }
  })
})
