jQuery(document).ready(function($) {
    $('body #platform_form').delegate('.add_nested_item', 'click', function() {
      template = eval($(this).attr('href').replace(/.*#/, ''));
      $($(this).attr('rel')).append(template);
    })
})



