import $ from 'jquery'
import '../src/govuk-frontend.js'
import '../src/step-by-step-navigation.js'

$(document).on('ajax:success', function(event) {
  var detail = event.detail
  var data = detail[0], status = detail[1], xhr = detail[2]

  setTimeout(function() {
    document.querySelector('#upload-file-container').innerHTML = detail[0].body.innerHTML
    document.getElementById('submit-upload').removeAttribute('disabled')

    var $element = $('#step-by-step-navigation')
    var stepByStepNavigation = new GOVUK.Modules.StepByStepNavigation()
    stepByStepNavigation.start($element)
  }, 500)
})
