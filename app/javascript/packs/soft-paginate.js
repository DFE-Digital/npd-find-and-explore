import $ from 'jquery';

$(document).ready(function () {
  const $container = $('.soft-paginate-container');
  const perPage = parseInt($container[0].dataset.perPage) || 10;
  const $items = $container.find('.soft-paginate-item');

  for (let i = 0; i < $items.length; i = i + perPage) {
    let n = Math.ceil(i / perPage);
    $($items.slice(i, i + perPage)).wrapAll('<div class="soft-pagination-page" data-page="' + n + '">');
  }

  const toPage = function (event) {
    event.preventDefault();
    const totalPages = $('.soft-pagination-page').length;
    const currentPage = parseInt(/\?page=(.+)$/.exec($('.soft-pagination__item').find('a.current').attr('href'))[1]);
    let page = /\?page=(.+)$/.exec($(event.currentTarget).attr('href'))[1];

    if (page == 'prev') {
      page = currentPage > 0 ? currentPage - 1 : 0;
    } else if (page == 'next') {
      page = currentPage >= (totalPages - 1) ? (totalPages - 1) : currentPage + 1;
    }

    $('.soft-pagination__item').find('a').removeClass('current');
    $('.soft-pagination__item').find('a[href="?page=' + page + '"]').addClass('current');
    $('.soft-pagination-page').hide();
    $('.soft-pagination-page[data-page="' + page + '"]').show();
  }

  const $pages = $('.soft-pagination-page');
  const $paginationLink = $('.soft-pagination__item.page');
  const $paginationNext = $('.soft-pagination__item.next');
  for (let i = 0; i < $pages.length; i++) {
    if (i > 0) {
      $($pages[i]).hide();
      let $link = $paginationLink.clone();
      $link.find('a').text(i + 1);
      $link.find('a').attr('href', '?page=' + i);
      $paginationNext.before($link[0]);
    }
  }

  $('.soft-pagination__item').find('a').click(toPage);
  $paginationLink.find('a').addClass('current');
});
