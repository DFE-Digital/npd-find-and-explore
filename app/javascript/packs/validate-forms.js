import $ from 'jquery';

function validateForm(event) {
  var form = event.currentTarget;

  if (!form.checkValidity()) {
    $('.govuk-error-summary').removeClass('hidden');

    form.querySelectorAll('input').forEach(function(element) {
      if (!element.checkValidity()) {
        var errorMessage = $(element).parents('.govuk-form-group').children('.error-message');
        var errorField = errorMessage.children('.govuk-error-message').attr('id');

        $(element).parents('.govuk-form-group').addClass('govuk-form-group--error');
        errorMessage.removeClass('hidden');
        $('.govuk-error-summary__list')
          .children('[data-reference="' + errorField + '"]')
          .removeClass('hidden');
      }
    });
  }
}

function revalidateItem(event) {
  var element = event.currentTarget;
  var form = element.form;

  // WIP - re-validate on input change
}

$(document).ready(function() {
  if (document.querySelector('[data-js-validate=true]')) {
    document.querySelector('[data-js-validate=true]').addEventListener('click', validateForm);
    form.querySelectorAll('input').forEach(function(element) {
      element.addEventListener(change, revalidateItem);
    });
  }
})
