import '../src/loader.scss'
import displayLoader from '../src/loader-display.js'
import $ from 'jquery'

window.loader = new GOVUK.Loader()

$(document).ready(function() {
  $('.loader-on-submit').submit(displayLoader);
});
