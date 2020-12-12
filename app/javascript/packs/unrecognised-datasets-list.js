import $ from 'jquery';

$('document').ready(function () {
  $('input[type="radio"].dataset-choice-radio').change(function (event) {
    const action = $(event.currentTarget).val();
    const $list = $('ul.unrecognised-datasets-list');
    const $radioGroup = $(event.currentTarget).parents('.govuk-radios');
    const id = $radioGroup.find('input[type="hidden"].data_tab_id').val();
    const name = $radioGroup.find('input[type="hidden"].data_tab_name').val();

    if (action == 'match' || action == 'create') {
      if ($list.find('li#data_tab_' + id).length == 0) {
        $list.append('<li id="data_tab_' + id + '">' + name + '</li>');
      }
    } else if (action == 'ignore') {
      $list.find('li#data_tab_' + id).remove();
    }
  });
});
