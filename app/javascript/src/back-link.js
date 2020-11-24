import $ from 'jquery';

$(document).ready(function() {
  if (document.querySelector('.govuk-back-link')) {
    document.querySelector('.govuk-back-link').addEventListener('click', function(event) {
      event.preventDefault();
      window.history.back();
    });
  }
});
