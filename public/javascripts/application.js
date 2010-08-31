// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// Make jQuery play nice with Rails respond_to format.js
$.ajaxSetup({
    'beforeSend': function(xhr) {
        xhr.setRequestHeader("Accept", "text/javascript");
    }
});


function monitor_changing(selector) {
    $(selector).each(function() {
	var id = this.id;
	var e = $(this);
        e.find('.pulsate').pulsate();
        setTimeout(function() {
            $.get((e.is('.app') ? '/apps/' : '/instances/') + id, function() {
                monitor_changing("#"+id+".changing");
            });
        }, 5000);
    });
}

function redeploy_staged(selector) {
    $(selector).each(function() {
	var id = this.id;
        $(this).find('.pulsate').pulsate();
	setTimeout(function() {
            $.post("/apps/"+id+"/redeploy", function(data) {
		redeploy_staged("#"+id+".staged");
		monitor_changing("#"+id+".changing");
            });
	}, 5000);
    });
}

jQuery.fn.pulsate = function() {
    this.pulse({opacity: [1,.2]}, 500, 10);
};

jQuery(document).ready(function($) {
    $('#environment_form #environment_platform_version_id').change(function() {
        $('.platform_version_block').hide()
        $('#platform_version_' + this.value).show()
    })
    
    //show the correct data on load
    $('#environment_form #environment_platform_version_id').trigger('change')

    /*
     * remove other, unused platform versions, since some versions of IE 
     * will still submit form fields within hidden content.
     */  
    $('body.environments_controller form').submit(function() {
        $('.platform_version_block:hidden').remove()
    })
})
