import $ from 'jquery';

const images = require.context('../images', true)
const imagePath = (name) => images(name, true)

import '../src/nest.scss'
import { initializeSortable, initializeChangeLog, initializeCommitChanges,
         initializeViewDetails, initializeCollapsible, importTree } from '../src/nest.js'

$(document).ready(function() {
  $('#govuk-box-message').show()
  initializeChangeLog();
  initializeCommitChanges();
  importTree();
})
