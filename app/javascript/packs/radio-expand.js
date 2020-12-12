import $ from 'jquery';

$(document).ready(function () {
  $('.radio-expand-group').each(function (idx, element) {
    const checked = $(element).find('input[type="radio"]').prop('checked');
    const $block = $(element).find('.radio-expand-hidden');

    if (checked) {
      $block.show();
    } else {
      $block.hide();
    }

    $(element).find('input[type="radio"]').change(function (event) {
      const $block = $(event.currentTarget).parents('.govuk-radios');
      // $block.find('input[data-js-validate-input]').prop('required', false);
      $block.find('.radio-expand-hidden').hide();

      const $current = $(event.currentTarget).parents('.radio-expand-group');
      // $current.find('input[data-js-validate-input]').prop('required', true);
      $current.find('.radio-expand-hidden').show();
    });
  });
});
