// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"
//

$('#choose-existing .form-group').hide();
$('#choose-existing .form-error').hide();
$('#create-new .form-group').hide();
$('#create-new .form-error').hide();

$('#choose-existing a').on('click', function() {
  $(this).toggleClass('active');
  $('#create-new a').removeClass('active');
  $('#choose-existing .form-group').toggle();
  $('#choose-existing .form-error').toggle();
  $('#create-new .form-group').hide();
  $('#create-new .form-error').hide();
});

$('#create-new a').on('click', function() {
  $(this).toggleClass('active');
  $('#choose-existing a').removeClass('active');
  $('#create-new .form-group').toggle();
  $('#create-new .form-error').toggle();
  $('#choose-existing .form-group').hide();
  $('#choose-existing .form-error').hide();
});
