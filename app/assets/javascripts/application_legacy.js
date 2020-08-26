/* global moj, $ */
//= require jquery
//= require jquery_ujs
//= require govuk_toolkit
//= require_tree ./modules
//= require_tree ./peoplefinder

$(function() {
  $('#problem_report_browser').val(navigator.userAgent);
  $('#new_problem_report').hide();
  $('#feedbackToggle').click(function() {
    $(this).toggleClass('open');
    $('#new_problem_report').slideToggle('slow');
  });
});
