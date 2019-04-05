/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import '../src/application.scss'

import $ from 'jquery'

import '../src/govuk-frontend.js'
import '../src/sort.js'
import '../src/step-by-step-navigation.js'

$(document).ready(function() {
  var $element = $('#step-by-step-navigation')
  var stepByStepNavigation = new GOVUK.Modules.StepByStepNavigation()
  stepByStepNavigation.start($element)
})
