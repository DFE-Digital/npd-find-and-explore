import $ from 'jquery'

$(document).ready(function () {
  $('#sort').on('change', function (event) {
    var query = window.location.search.replace(/^\?/, '').split('&')

    var newQuery = query.filter(function (element) { return !/^sort/.test(element) })
    newQuery.push('sort=' + event.currentTarget.selectedOptions[0].value)

    window.location.search = '?' + newQuery.join('&')
  })
})
