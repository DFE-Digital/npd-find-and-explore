import $ from 'jquery';
import { getFromLocalStorage, toggleFromList } from '../src/local_storage.js'

$(document).ready(function() {
  $('[data-save-to-local-storage]').each(function(id, element) {
    var list = getFromLocalStorage(element.dataset.saveToLocalStorage);
    if (list[element.id]) {
      element.checked = true;
    }

    element.addEventListener('click', toggleFromList);
  })
});
