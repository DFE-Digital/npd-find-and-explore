import '../src/loader.scss'
import '../src/loader.js'
import $ from 'jquery'

window.loader = new GOVUK.Loader()

$(document).ready(function() {
  $('.loader-on-submit').submit(function(event) {
    $(event.currentTarget).parents('.govuk-form-group').removeClass('govuk-form-group--error');
    $(event.currentTarget).find('.govuk-error-message').hide();
    $('button').attr('disabled', true);
    $('#govuk-box-message').show();

    window.loader.init({
      container: 'govuk-box-message',
      label: true,
      labelText: 'We are processing the file you uploaded, please wait'
    });
  });
});
