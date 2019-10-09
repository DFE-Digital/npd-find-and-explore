import '../src/loader.scss'

import '../src/loader.js'
import $ from 'jquery'

window.loader = new GOVUK.Loader()

$(document).ready(function() {
  var downloadTimer;

  $('#download-link').on('click', function() {
    $('#download-link').attr('disabled', true)

    window.loader.init({
      container: 'govuk-box-message',
      label: true,
      labelText: 'We are generating the file you requested, please wait'
    })

    downloadTimer = window.setInterval(function() {
      if(/download=download-ia-table/.test(document.cookie)) { finishDownload(); }
    }, 500);
  })

  var finishDownload = function() {
    $('#download-link').removeAttr('disabled')
    window.loader.stop()
    window.clearInterval(downloadTimer);
    document.cookie = document.cookie.replace(/download=download-ia-table/, 'download=download-ia-table;path=/;max-age=1');
  }
})
