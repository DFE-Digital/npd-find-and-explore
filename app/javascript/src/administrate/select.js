var tail = { select: require('tail.select') }

$(document).ready(function() {
  tail.select('select', {
    deselect: true,
    multiContainer: true,
    search: true,
    width: '100%',
  })
})
