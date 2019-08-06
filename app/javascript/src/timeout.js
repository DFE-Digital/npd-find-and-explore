var timeoutId;

function startTimer() {
  // window.setTimeout returns an Id that can be used to start and stop a timer
  timeoutId = window.setTimeout(doInactive, document.getElementById('timer-ms').value)
}

function resetTimer() {
  window.clearTimeout(timeoutId)
  startTimer();
}

function doInactive() {
  // Reload the page
  location.reload()
}

function setupTimers () {
  document.addEventListener('mousemove', resetTimer, false);
  document.addEventListener('mousedown', resetTimer, false);
  document.addEventListener('keypress', resetTimer, false);
  document.addEventListener('touchmove', resetTimer, false);

  resetTimer();
}

document.addEventListener('DOMContentLoaded', function() {
  setupTimers();
})

document.addEventListener('turbolinks:load', function() {
  setupTimers();
})

