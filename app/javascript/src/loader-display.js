import '../src/loader.js'

const displayLoader = function(event) {
  if ($(event.currentTarget).attr('disabled')) {
    return
  }

  const message = event.currentTarget.dataset.loaderMessage
  $(event.currentTarget).parents('.govuk-form-group').removeClass('govuk-form-group--error')
  $(event.currentTarget).find('.govuk-error-message').hide()
  $('button').attr('disabled', true)
  $('.main-content__header').hide()
  $('fieldset').hide()
  $('.govuk-breadcrumbs').hide()
  if (message != undefined) {
    $('#govuk-box-container').find('.govuk-heading-l').html(message)
  }
  $('#govuk-box-container').show()

  if ($('#loader')[0] == undefined) {
    window.loader.init({
      container: 'govuk-box-message',
      label: true,
      labelText: '',
      size: '175px',
    })
  }
}

export default displayLoader
