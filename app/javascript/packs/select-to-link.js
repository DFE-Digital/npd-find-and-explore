import $ from 'jquery';
var tail = { select: require('tail.select') }

function hideSelect(element) {
  $(element).parent('.select').hide();
}

function resetSelect(element) {
  const selectKeys = Object.keys(tail.select.inst);
  const current = $(element).parents('.select-to-link').find('select')[0];
  let select = null;
  for (let i = 0; i < selectKeys.length; i++) {
    if (tail.select.inst[selectKeys[i]].e == current) {
      select = selectKeys[i];
    }
  }
  if (select) {
    $(element).parents('.select-to-link').find('select').find('option:selected').prop('selected', false);
    tail.select.inst[select].reload();
  }
  $(element).parents('.select-to-link').find('.select').show();
}

function addSelectionLink(element) {
  const selectedOption = $(element).children('option:selected').text();
  $(element).parents('.select-to-link').find('.text').text(selectedOption);
  $(element).parents('.select-to-link').children('.link').show();
}

function hideSelectionLink(element) {
  $(element).parents('.select-to-link').find('.text').text('');
  $(element).parents('.select-to-link').children('.link').hide();
}

$(document).ready(function () {
  $('.select-to-link select').on('change', function (event) {
    const element = event.currentTarget;
    hideSelect(element);
    addSelectionLink(element);
  });
  $('.select-to-link .link-to-select').on('click', function (event) {
    event.preventDefault();
    const element = event.currentTarget;
    resetSelect(element);
    hideSelectionLink(element);
  });
});
