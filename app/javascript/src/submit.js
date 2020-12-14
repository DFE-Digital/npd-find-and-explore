import $ from 'jquery';

$(document).ready(function () {
  $('[data-submit]').click(function (event) {
    let target = event.currentTarget;
    $(target)
      .parents('form')
      .append("<input type='hidden' name='submit' value='" + target.value + "'/>");
  });
});
