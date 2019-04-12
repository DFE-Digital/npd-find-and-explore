$(document).ready(function() {
  $('.overlay-parent > a').on('click', function(event) {
    event.preventDefault()
    $(event.target).siblings('.overlay').show()
  })

  $('.overlay-close').on('click', function(event) {
    event.preventDefault()

    $(event.target).parents('.overlay').hide()
  })
})
