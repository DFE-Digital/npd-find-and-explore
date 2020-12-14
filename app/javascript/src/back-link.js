import $ from 'jquery';

$(document).ready(function() {
  $('.govuk-back-link[href="#"]').click(function(event) {
    event.preventDefault();
    window.history.back();
  });
});
