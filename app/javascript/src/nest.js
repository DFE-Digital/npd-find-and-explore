import $ from 'jquery';
import Sortable from 'sortablejs';

function initializeSortable() {
  const nestedSortables = document.querySelectorAll('.nested-sortable');

  // Loop through each nested sortable element
  for (var i = 0; i < nestedSortables.length; i++) {
    new Sortable(nestedSortables[i], {
      group: 'nested',
      handle: '.dd-handle',
      animation: 150,
      fallbackOnBody: true,
      swapThreshold: 0.65,
      onSort: function(event) {
        const text = $($(event.item).find('.dd3-content .dd-label')[0]).text();
        const sortLog = (localStorage.getItem('sortLog') || '').split('|');

        if (text && text != sortLog[sortLog.length - 1]) {
          sortLog.push(text);
          localStorage.setItem('sortLog', sortLog.join('|'));
          $('[data-changes-log]').append(
            '<li>"' + text + '" moved</li>'
          );
        }
      },
      store: {
        /**
         * Get the order of elements. Called once during initialization.
         * @param   {Sortable}  sortable
         * @returns {Array}
         */
        get: function (sortable) {
          const parent_id = sortable.el.dataset.id;
          const savedSort = localStorage.getItem(['sort', sortable.options.group.name, parent_id].join('-'));

          if (savedSort) {
            const order = /^(\(\d+\))(.*)$/.exec(savedSort);
            return order.length == 3 ? order[2].split('|') : [];
          } else {
            return [];
          }
        },

        /**
         * Save the order of elements. Called onEnd (when the item is dropped).
         * @param {Sortable}  sortable
         */
        set: function (sortable) {
          const order = sortable.toArray();
          const orderStorageId = ['sort', sortable.options.group.name, sortable.el.dataset.id].join('-');
          const sequence = parseInt(localStorage.getItem('sequence') || '0');

          localStorage.setItem(orderStorageId, '(' + sequence + ')' + order.join('|'));
          localStorage.setItem('sequence', sequence + 1);
        }
      }
    });
  }
}

function initializeChangeLog() {
  // Recreate the list of changes
  (localStorage.getItem('sortLog') || '').split('|').forEach(function (text) {
    if (text) {
      $('[data-changes-log]').append(
        '<li>"' + text + '" moved</li>'
      );
    }
  });
}

function initializeCommitChanges() {
  // Set up the "cancel" button action
  $('[data-cancel-changes]').click(function (event) {
    // Clear the order saved into localStorage
    const sortKeys = Object.keys(localStorage).filter(function(val) { return /^sort-[a-z]+-.*$/.test(val) });
    sortKeys.forEach(function (key) { localStorage.removeItem(key) });
    localStorage.setItem('sequence', '0')
    localStorage.removeItem('sortLog')

    // Fastest way to reset the tree
    window.location.reload();
  });

  // Set up the "confirm" button action
  $('[data-confirm-changes]').click(function (event) {
    if (!$('#changes-approved')[0].checked) {
      $('#changes-approved').parents('.govuk-form-group').addClass('govuk-form-group--error');
      $('#changes-approved').parents('.govuk-form-group').find('.govuk-error-message').show();
    } else {
      const path = document.getElementById('tree_nodes').dataset.updatePath;
      const sortKeys = Object.keys(localStorage).filter(function(val) { return /^sort-[a-z]+-.*$/.test(val) });
      const sortedChanges = {}

      $('#changes-approved').parents('.govuk-form-group').removeClass('govuk-form-group--error');
      $('#changes-approved').parents('.govuk-form-group').find('.govuk-error-message').hide();

      for (let i = 0; i < sortKeys.length; i++) {
        let order = /^\((\d+)\)(.*)$/.exec(localStorage.getItem(sortKeys[i]));
        if (order && order.length == 3) {
          sortedChanges[order[1]] = [sortKeys[i], order[2]];
        }
      }

      const ids = Object.keys(sortedChanges);
      for (let i = 0; i < ids.length; i++) {
        let parent_id = sortedChanges[ids[i]][0].replace(/sort-[a-z]+-/, '');
        let order = sortedChanges[ids[i]][1].split('|');

        console.log('parent_id ' + parent_id);
        if (parent_id) {
          /**
           * Send the order of elements to the backend
           */
          $.ajax({
            url: path,
            type: 'POST',
            data: {
              parent: parent_id,
              tree_nodes: order
            },
            headers: {
              'x-csrf-token': $('meta[name="csrf-token"]').attr('content')
            },
            success(data) {
              localStorage.removeItem(sortedChanges[ids[i]][0]);
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
          });
        }
      }
      localStorage.setItem('sequence', '0')
      localStorage.removeItem('sortLog')
      $('[data-changes-log]').empty();
    }
  });
}

function initializeViewDetails() {
  $('.view-detail').click(function (event) {
    event.preventDefault();
    const link = $(event.currentTarget);
    const details = link.parents('.dd3-content').siblings('.dd-details');
    if (details.hasClass('hidden')) {
      details.removeClass('hidden');
      link.text('Hide details');
    } else {
      details.addClass('hidden');
      link.text('View details');
    }
  });
}

function initializeCollapsible() {
  $('[data-action="collapse"]').click(function (event) {
    $(event.currentTarget).parent('.dd-item').addClass('dd-collapsed');
  });
  $('[data-action="expand"]').click(function (event) {
    $(event.currentTarget).parent('.dd-item').removeClass('dd-collapsed');
  });
  $('#expand-categories').change(function (event) {
    if (event.currentTarget.checked) {
      $('.dd-item').removeClass('dd-collapsed');
    } else {
      $('.dd-item').addClass('dd-collapsed');
    }
  });
}

jQuery(function() {
  initializeSortable();
  initializeChangeLog();
  initializeCommitChanges();
  initializeViewDetails();
  initializeCollapsible();
})
