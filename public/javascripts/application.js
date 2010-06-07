// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(function() {
    $('tr.changing').each(function() { checkup($(this)); });
});

function checkup(e) {
    if (e.is('.changing')) {
	e.find('.changing').pulsate();
	var id = e[0].id;
	setTimeout(function() {
	    $.ajax({
		url: (e.is('.app') ? '/apps/' : '/instances/') + id, 
		dataType: 'script', 
		success: function() { 
		    checkup($('#'+id));
		}
	    });
	}, 5000);
    }
}

jQuery.fn.pulsate = function() {
    this.pulse({opacity: [1,.2]}, 500, 10);
}
