import $ from 'jquery';

function validateForm(event) {
  const button = event.currentTarget;
  const form = $(button).parents('form')[0];

  if (button.dataset.skipValidation) {
    $('form').attr('novalidate', 'true')
  } else {
    if (!form.checkValidity()) {
      event.preventDefault();

      form.querySelectorAll('[data-js-validate-input="true"]')
        .forEach(function(element) {
        let $parentGroup = $($(element).parents('.govuk-form-group')[0]);
        let errorMessage = $parentGroup.children('.error-message');
        let id = errorMessage.find('.govuk-error-message').attr('id');
        let bulletPoint = $(errorMessage.children('li')[0]).clone();

        if (!element.checkValidity()) {
          $parentGroup.addClass('govuk-form-group--error');
          errorMessage.removeClass('hidden');
          if ($('.govuk-error-summary__list').find('[data-reference="' + id + '"]').length == 0) {
            $('.govuk-error-summary__list').append(bulletPoint);
          }
          $('.govuk-error-summary__list').find('[data-reference="' + id + '"]').show();
        } else if ((element.required && element.checkValidity()) ||
                   (element.dataset.jsValidateInput && !element.required)) {
          $parentGroup.removeClass('govuk-form-group--error');
          if (errorMessage.length) { errorMessage.addClass('hidden'); }
          if (id) { $('.govuk-error-summary__list').find('[data-reference="' + id + '"]').remove(); }
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
  const $parentGroup = $($(element).parents('.govuk-form-group')[0]);
  const errorMessage = $parentGroup.children('.error-message');
  const id = errorMessage.find('.govuk-error-message').attr('id');
  const bulletPoint = $(errorMessage.children('li')[0]).clone();

  if (!element.checkValidity()) {
    $parentGroup.addClass('govuk-form-group--error');
    errorMessage.removeClass('hidden');
    if ($('.govuk-error-summary__list').find('[data-reference="' + id + '"]').length == 0) {
      $('.govuk-error-summary__list').append(bulletPoint);
    }
    $('.govuk-error-summary__list').find('[data-reference="' + id + '"]').show();
  } else if ((element.required && element.checkValidity()) ||
             (element.dataset.jsValidateInput && !element.required == false)) {
    $parentGroup.removeClass('govuk-form-group--error');
    if (errorMessage.length) { errorMessage.addClass('hidden'); }
    if (id) { $('.govuk-error-summary__list').find('[data-reference="' + id + '"]').remove(); }
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
    document.querySelector('[data-js-validate=true]').querySelectorAll('input,select,textarea').forEach(function(element) {
      element.addEventListener('change', revalidateItem);
    });
  }
})
