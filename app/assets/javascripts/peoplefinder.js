$(function() {
  return $(document).on("click", "#add_membership", function(e) {
    e.preventDefault();
    return $.ajax({
      url: this,
      success: function(data) {
        var el_to_add;
        el_to_add = $(data).html();
        return $('#memberships').append(el_to_add);
      },
      error: function(data) {
        return alert("Sorry, There Was An Error!");
      }
    });
  });
});

$(function() {
  return $(document).on("click", "#hide_people_link", function(e) {
    e.preventDefault();
    $('#all_people').remove();
    $('#show_people_link').show();
  });
});
