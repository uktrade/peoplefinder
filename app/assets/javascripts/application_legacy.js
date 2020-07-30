/* global moj, $ */
//= require jquery
//= require jquery_ujs
//= require lodash
//= require govuk_toolkit
//= require moj
//= require_tree ./modules
//= require_tree ./peoplefinder
//= require Jcrop/js/jquery.Jcrop.min

$(function() {
  moj.init();

  // init the selection buttons
  moj.Helpers.selectionButtons();

});

$(function() {
  $('#problem_report_browser').val(navigator.userAgent);
  $('#new_problem_report').hide();
  $('#feedbackToggle').click(function() {
    $(this).toggleClass('open');
    $('#new_problem_report').slideToggle('slow');
  });
});
