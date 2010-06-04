// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(function() {
    $('.changing').each(function() { checkup(this.id); });
    $('td.changing').pulsate();
});

function checkup(id) {
    setTimeout(function() {
	$.ajax({
	    url: '/instances/'+id, 
	    dataType: 'script', 
	    success: function() { 
		var e = $('#'+id);
		if (e.length && e.hasClass('changing')) {
		    e.find('td.changing').pulsate();
		    checkup(id);
		}
	    }
	});
    }, 5000);
}

jQuery.fn.pulsate = function() {
    this.pulse({opacity: [1,.2]}, 500, 10);
}
