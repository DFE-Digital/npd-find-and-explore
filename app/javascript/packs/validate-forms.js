import $ from 'jquery';

function validateForm(event) {
  const button = event.currentTarget;
  const form = $(button).parents('form')[0];

  if (!form.checkValidity()) {
    event.preventDefault();
    $('.govuk-error-summary').removeClass('hidden');

    form.querySelectorAll('input').forEach(function(element) {
      if (!element.checkValidity()) {
        const errorMessage = $(element).parents('.govuk-form-group').children('.error-message');
        const errorField = errorMessage.children('.govuk-error-message').attr('id');

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

  form.querySelectorAll('input').forEach(function(element) {
    if (element.checkValidity()) {
      const errorMessage = $(element).parents('.govuk-form-group').children('.error-message');

      $(element).parents('.govuk-form-group').removeClass('govuk-form-group--error');
      errorMessage.addClass('hidden');
    } else {
      const errorMessage = $(element).parents('.govuk-form-group').children('.error-message');
      const errorField = errorMessage.children('.govuk-error-message').attr('id');

      $(element).parents('.govuk-form-group').addClass('govuk-form-group--error');
      errorMessage.removeClass('hidden');
      $('.govuk-error-summary__list')
        .children('[data-reference="' + errorField + '"]')
        .removeClass('hidden');
    }
  });
  if (form.checkValidity()) {
    $('.govuk-error-summary').addClass('hidden');
    $('.govuk-error-summary__list')
      .children('[data-reference]')
      .addClass('hidden');
  }
}

$(document).ready(function() {
  if (document.querySelector('[data-js-validate=true]')) {
    document.querySelector('[data-js-validate=true]').querySelectorAll('submit,button').forEach(function(element) {
      element.addEventListener('click', validateForm);
    });
    document.querySelector('[data-js-validate=true]').querySelectorAll('input').forEach(function(element) {
      element.addEventListener('change', revalidateItem);
    });
  }
})
