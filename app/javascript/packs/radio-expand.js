import $ from 'jquery';

$(document).ready(function () {
  $('.radio-expand-group').each(function (idx, element) {
    const checked = $(element).find('input[type="radio"]').prop('checked');

    if (checked) {
      $(element).find('.radio-expand-hidden').show();
    } else {
      $(element).find('.radio-expand-hidden').hide();
    }

    $(element).find('input[type="radio"]').change(function (event) {
      $(event.currentTarget).parents('.govuk-radios').find('.radio-expand-hidden').hide();
      $(event.currentTarget).parents('.radio-expand-group').find('.radio-expand-hidden').show();
    });
  });
});
