import $ from 'jquery'
import '../src/govuk-frontend.js'
import '../src/step-by-step-navigation.js'

$(document).ready(function () {
  var $element = $('#step-by-step-navigation')
  var stepByStepNavigation = new GOVUK.Modules.StepByStepNavigation()
  stepByStepNavigation.start($element)
})
