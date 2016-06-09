$(document).ready(function() {
  var DEFAULT_SHOW_CHAR = 400;
  var ellipsestext = "...";
  var moretext = "Mostrar mais";
  var lesstext = "Mostrar menos";


  $('.artigo-abstract').each(function() {
    var content = $(this).html();
    var showChar = $(this).data('limit') || DEFAULT_SHOW_CHAR;

    if(content.length > showChar + 5) {
      var c = content.substr(0, showChar);
      var h = content.substr(showChar, content.length - showChar);
      var html = c +
        '<span class="more-ellipses">' + ellipsestext + '&nbsp;</span>' +
        '<span><span class="more-content">' + h + '</span>&nbsp;&nbsp;' +
        '<span href="" class="more-link">' + moretext + '</span></span>';

      $(this).html(html);
    }
  });

  $(".more-link").on('click', function(){
    if($(this).hasClass("less")) {
      $(this).removeClass("less");
      $(this).html(moretext);
    } else {
      $(this).addClass("less");
      $(this).html(lesstext);
    }
    $(this).parent().prev().toggle();
    $(this).prev().toggle();
    return false;
  });
});
