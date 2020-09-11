import $ from 'jquery';
import Sortable from 'sortablejs';

jQuery(function() {
  const nestedSortables = document.querySelectorAll('.nested-sortable');

  // Loop through each nested sortable element
  for (var i = 0; i < nestedSortables.length; i++) {
    new Sortable(nestedSortables[i], {
      group: 'nested',
      handle: '.dd-handle',
      animation: 150,
      fallbackOnBody: true,
      swapThreshold: 0.65,
      store: {
        /**
         * Get the order of elements. Called once during initialization.
         * @param   {Sortable}  sortable
         * @returns {Array}
         */
        get: function (sortable) {
          const order = localStorage.getItem(sortable.options.group.name);
          return order ? order.split('|') : [];
        },

        /**
         * Save the order of elements. Called onEnd (when the item is dropped).
         * @param {Sortable}  sortable
         */
        set: function (sortable) {
          const path = document.getElementById('tree_nodes').dataset.updatePath;
          const order = sortable.toArray();
          const parent = sortable.el.parentElement.dataset.id;

          localStorage.setItem(sortable.options.group.name, order.join('|'));

          /**
           * Send the order of elements to the backend
           */
          $.ajax({
            url: path,
            type: 'POST',
            data: {
              parent: parent,
              tree_nodes: order
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
      }
    });
  }
})
