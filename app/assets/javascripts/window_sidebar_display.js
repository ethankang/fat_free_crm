$(function(){
    var window_width= $(window).width();
    var window_height = $(window).height();
    if(window_width <=500){
      $(".sidebar").css("display",'none');
    }
});