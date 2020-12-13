import $ from 'jquery';

function validateForm(event) {
  const button = event.currentTarget;
  const form = $(button).parents('form')[0];

  if (button.dataset.skipValidation) {
    $('form').attr('novalidate', 'true')
  } else {
    if (!form.checkValidity()) {
      event.preventDefault();

      form.querySelectorAll('input').forEach(function(element) {
        if (!element.checkValidity()) {
          const errorMessage = $(element).parents('.govuk-form-group').children('.error-message');
          const errorField = errorMessage.children('.govuk-error-message').attr('id');
          const point = errorMessage.children('li')[0];

          $(element).parents('.govuk-form-group').addClass('govuk-form-group--error');
          errorMessage.removeClass('hidden');
          $('.govuk-error-summary__list')
            .append(point);
        }
      });

      $('.govuk-error-summary').removeClass('hidden');
      $('body,html').animate({ scrollTop: $('.govuk-error-summary').offset().top }, 800);
      $('.govuk-error-summary').find('li').removeClass('hidden');
    }
  }
}

function revalidateItem(event) {
  const element = event.currentTarget;
  const form = element.form;
  const errorMessage = $(element).parents('.govuk-form-group').children('.error-message');
  const id = errorMessage.find('.govuk-error-message').attr('id');

  if (element.checkValidity()) {
    $(element).parents('.govuk-form-group').removeClass('govuk-form-group--error');
    if (errorMessage.length) { errorMessage.addClass('hidden'); }
    if (id) { $('[data-reference="' + id + '"]').remove(); }
  } else {
    const errorField = errorMessage.children('.govuk-error-message').attr('id');
    const point = errorMessage.children('li')[0];

    $(element).parents('.govuk-form-group').addClass('govuk-form-group--error');
    errorMessage.removeClass('hidden');
    if ($('[data-reference="' + id + '"]').length == 0) {
      $('.govuk-error-summary__list')
        .append(point);
    }
  }

  $('.govuk-error-summary').find('li').removeClass('hidden')

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
    document.querySelector('[data-js-validate=true]').querySelectorAll('input[required]').forEach(function(element) {
      element.addEventListener('change', revalidateItem);
    });
  }
})
