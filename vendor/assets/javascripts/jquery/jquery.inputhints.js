﻿// jQuery Input Hints plugin
// Copyright (c) 2009 Rob Volk
// http://www.robvolk.com
jQuery.fn.inputHints=function() {
  $(this).each(function(i) {
    $(this).val($(this).attr('title')).addClass('hint');
  });
  return $(this).focus(function() {
    if ($(this).val() == $(this).attr('title'))
      $(this).val('').removeClass('hint');
  }).blur(function() {
    if ($(this).val() == '')
      $(this).val($(this).attr('title')).addClass('hint');
  });    
};
