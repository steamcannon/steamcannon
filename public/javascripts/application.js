// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(function() {
    $('.changing').each(function() { checkup(this.id); });
});

function checkup(id) {
    setTimeout(function() {
	$.ajax({
	    url: '/instances/'+id, 
	    dataType: 'script', 
	    success: function() { 
		var e = $('#'+id);
		if (e.length && e.hasClass('changing')) {
		    checkup(id);
		}
	    }
	});
    }, 5000);
    
}