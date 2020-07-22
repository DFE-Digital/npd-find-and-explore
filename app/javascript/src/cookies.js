import $ from 'jquery'

function unwrapCookies() {
  var allCookies = (!document.cookie ? [] : document.cookie.split(';'));
  var cookies = {};

  for (var i = 0; i < allCookies.length; i++) {
    var cookie = allCookies[i].split('=');
    cookies[cookie[0].replace(/^ +/g, '').replace(/ +$/g, '')] = cookie[1];
  }
  return cookies;
}

function getCookie(cookie) {
  var cookies = unwrapCookies();

  return cookies[cookie];
}

function setCookie(cookie, value) {
  document.cookie = [cookie, value].join('=');
}

// Closure to make sure the $ function is the jQuery one
var hideConfirmation = (function ($) {
  return function() {
    $('.gem-c-cookie-banner__confirmation').hide();
    $('.gem-c-cookie-banner').hide();
  }
})($);

// Closure to make sure the $ function is the jQuery one
var initUsageChoice = (function ($) {
  return function() {
    var cookiesPolicy = getCookie('cookies_policy');

    try {
      cookiesPolicy = JSON.parse(cookiesPolicy);
    } catch(error) {
      cookiesPolicy = null;
    }

    if (cookiesPolicy && (cookiesPolicy.usage == true || cookiesPolicy.usage == 'true' || cookiesPolicy.usage == 1)) {
      $('input[type="radio"][value="on"]').attr('checked', true);
    } else {
      $('input[type="radio"][value="off"]').attr('checked', true);
    }
  }
})($);

// Closure to make sure the $ function is the jQuery one
var cookiePreferencesSubmit = (function($) {
  return function (event) {
    event.preventDefault();
    var status = { 'on': 'true', 'off': 'false' };
    var radios = $(event.target).find('input[type="radio"][name="survey"]')
    var usage = 'false';

    for (var i = 0; i < radios.length; i++) {
      if (radios[i].checked) {
        usage = status[radios[i].value];
      }
    }

    setCookie('cookies_policy', '{"essential":true,"usage":' + usage + '}');
    setCookie('cookies_preferences_set', 'true');
    $('.success-message').show();
    $('html, body').animate({
      scrollTop: $('.success-message').offset().top
    });
  }
})($);

// Closure to make sure the $ function is the jQuery one
var acceptAllCookies = (function($) {
  return function() {
    setCookie('cookies_policy', '{"essential":true,"usage":true}');
    setCookie('cookies_preferences_set', 'true');
    $('.gem-c-cookie-banner__confirmation').show();
    $('.gem-c-cookie-banner__wrapper').hide();
  }
})($);

// Closure to make sure the $ function is the jQuery one
var initCookies = (function($) {
  return function() {
    var preferencesSet = getCookie('cookies_preferences_set');

    if ($('#cookie-manager-form').length) {
      $('.success-message').hide();
      initUsageChoice();
      $('#cookie-manager-form').submit(cookiePreferencesSubmit);
    } else {
      if (!preferencesSet) {
        $('.gem-c-cookie-banner__confirmation').hide();
        $('.gem-c-cookie-banner__button-accept').click(acceptAllCookies);
        $('.gem-c-cookie-banner__hide-button').click(hideConfirmation);
        setCookie('cookies_policy', '{"essential":true,"usage":false}');
      } else {
        $('.gem-c-cookie-banner__confirmation').hide();
        $('.gem-c-cookie-banner__wrapper').hide();
        $('.gem-c-cookie-banner').hide();
      }
    }
  }
})($);

export { setCookie, initCookies }
