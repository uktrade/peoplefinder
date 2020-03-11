/* global moj, $ */
//= require jquery
//= require jquery_ujs
//= require lodash
//= require govuk_toolkit
//= require moj
//= require_tree ./modules
//= require_tree ./peoplefinder
//= require Jcrop/js/jquery.Jcrop.min
//= require select2/js/select2.min


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


/* global $, document, teamSelector */

$(function() {
  $(document).on('click', '#add_membership', function(e) {
    e.preventDefault();
    $.ajax({
      url: this,
      success: function(data) {
        var el_to_add = $(data).html();
        $('#memberships').append(el_to_add);
        var team = new teamSelector(true, $('#memberships').find('.membership').last());
        moj.Helpers.selectionButtons();
        team.initEvents();
      }
    });
  });

  $(document).on('click', 'a.remove-new-membership', function(e) {
    e.preventDefault();
    $(this).parents('.membership').remove();
  });

  // set val of _destroy param to 1 and hide the membership
  $(document).on('click', 'a.remove-existing-membership', function(e) {
    e.preventDefault();
    $(this).prev("input[type=hidden]").val("1");
    $(this).parents('.membership').hide();
  });

  // TODO: This was implemented as an urgent requirement that had to be done
  // in the old frontend code. It needs to be done properly once we transition
  // people to the new frontend code.
  $(document).ready(function() {
    $('.js-line-manager-select').select2({
      ajax: {
        url: '/search/people.json',
        data: function (params) {
          return { query: params.term };
        },
        processResults: function (data) {
          return {
            results: data
          };
        },
        dataType: 'json',
      },
      placeholder: 'Choose a new line manager',
      minimumInputLength: 4,
      templateResult: formatPerson,
      templateSelection: formatPersonSelection,
      selectOnClose: true
    });

    function formatPerson(person) {
      if(person.loading || person.name == null) {
        return person.text;
      }

      var $container = $(
        '<div class="select2-result-person">' +
        person.name +
        '<span class="select2-result-person__role">' +
        person.role_and_group +
        '</span>' +
        '</div>'
      );

      return $container;
    }

    function formatPersonSelection(person) {
      if(person.loading || person.name == null) {
        return person.text;
      }

      return person.name + ' (' + person.role_and_group + ')';
    }
  });

});
