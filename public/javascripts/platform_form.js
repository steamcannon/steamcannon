jQuery(document).ready(function($) {
    $('body #platform_form').delegate('.add_nested_item', 'click', function() {
      template = eval($(this).attr('href').replace(/.*#/, ''));
      $($(this).attr('rel')).append(template);
    });
    
    $('body #platform_form').delegate('.remove', 'click', function() {
      target = $(this).attr('href').replace(/.*#/, '.');
      $(this).closest(target).hide();
      if (hidden_input = $(this).prev('input[type=hidden]')) { $(hidden_input).attr("value", 1); }
    })
})



