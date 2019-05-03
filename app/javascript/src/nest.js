import 'jquery'
import './jquery.nestable'

jQuery(function() {
  const updateNodes = function(tree_nodes) {
    const serialized_tree = tree_nodes.nestable('serialize')

    return $.ajax({
      url: tree_nodes.data('update-path'),
      type: 'POST',
      data: {
        tree_nodes: serialized_tree
      },
      headers: {
        'x-csrf-token': $('meta[name="csrf-token"]').attr('content')
      },
      success(data) {
        const $flash = $('<div>')
          .addClass('nestable-flash alert alert-success')
          .append( $('<button>').addClass('close').data('dismiss', 'alert').html('&times;') )
          .append( $('<span>').addClass('body').html( data ) )

        $('#nestable')
          .append( $flash )

        return $flash.fadeIn(200)
          .delay(2000).fadeOut(200, function() {
            return $(this).remove()
          })
      }
    })
  }

  const $tree_nodes = $('#tree_nodes')
  const $tree_nodes_options = {}
  const $tree_nodes_max_depth = $tree_nodes.data('max-depth')
  const $live_update = $('#nestable input[type=checkbox]')
  const $update_button = $('#nestable button')
  let live_update_mode = (!$live_update.length && !$update_button.length) ? true : $live_update.prop('checked')
  $('#nestable button').prop('disabled', $live_update.prop('checked'))

  $live_update.change(function() {
    live_update_mode = $(this).prop('checked')
    return $update_button.prop('disabled', live_update_mode)
  })

  $update_button.click(() => updateNodes($tree_nodes))

  if ($tree_nodes_max_depth && ($tree_nodes_max_depth !== 'false')) {
    $tree_nodes_options['maxDepth'] = $tree_nodes_max_depth
  }

  return $tree_nodes
    .nestable( $tree_nodes_options )
    .on({
      change(event) {
        if (live_update_mode) {
          return updateNodes($tree_nodes)
        }
      }
    })
})
