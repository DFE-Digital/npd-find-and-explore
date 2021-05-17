import '../src/loader.scss'

import '../src/loader.js'
import $ from 'jquery'

window.loader = new GOVUK.Loader()

$(document).ready(function() {
  var downloadTimer;

  $('#download-link').on('click', function(event) {
    if ($(event.currentTarget).attr('disabled')) {
      return;
    }

    $('#download-link').attr('disabled', true)
    $('.main-content__header').hide()
    $('fieldset').hide()
    $('.govuk-breadcrumbs').hide()
    $('#govuk-box-container').show();

    window.loader.init({
      container: 'govuk-box-message',
      label: true,
      labelText: '',
      size: '175px',
    })

    downloadTimer = window.setInterval(function() {
      if(/download=download-ia-table/.test(document.cookie)) { finishDownload(); }
    }, 500);
  })

  var finishDownload = function() {
    $('#download-link').removeAttr('disabled')
    window.loader.stop()
    $('#govuk-box-container').hide();
    $('#govuk-box-success').show();
    window.clearInterval(downloadTimer);
    document.cookie = document.cookie.replace(/download=download-ia-table/, 'download=download-ia-table;path=/;max-age=1');
  }
})
