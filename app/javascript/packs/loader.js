import '../src/loader.scss'
import '../src/loader.js'
import $ from 'jquery'

window.loader = new GOVUK.Loader()

$(document).ready(function() {
  $('.loader-on-submit').submit(function(event) {
    if ($(event.currentTarget).attr('disabled')) {
      return;
    }

    $(event.currentTarget).parents('.govuk-form-group').removeClass('govuk-form-group--error');
    $(event.currentTarget).find('.govuk-error-message').hide();
    $('button').attr('disabled', true);
    $('#govuk-box-container').show();

    window.loader.init({
      container: 'govuk-box-message',
      label: true,
      labelText: '',
      size: '175px',
    });
  });
});
