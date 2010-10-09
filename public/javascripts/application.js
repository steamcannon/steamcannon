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

jQuery(document).ready(function($) {
    $('body.users_controller form .js-cloud_password_toggle').click(function() {
        $("#cloud_password_field").slideToggle();
        $("#cloud_password_prompt").slideToggle();
    });

    $('#environment_images_container .image_row .start_another a').click(function() {
        $($(this).closest('.start_another').next('.start_another_dialog')).show();
    })

    $('#environment_images_container .image_row .start_another_dialog .close a').click(function() {
        $($(this).closest('.start_another_dialog')).hide();
    })
})


function remote_stop_instance(url) {
  $.post(url, function(data){
    alert(data.message);
  }, "json");
}

function update_environment_status(url, selector) {
  $.post(url, function(data) {
    elem = $(selector + ' .environment_status');
    if (elem.text() != data.message) {
      elem.text(data.message);
    }
  }, "json");
  setTimeout("update_environment_status('" + url + "', '" + selector + "')", 30000);
}

function monitor_environment(url, selector) {
  jQuery(document).ready(function($) {
    update_environment_status(url, selector);
  });
}

function update_deployment_status(url, selector) {
  $.post(url, function(data) {
    services = "<ul>";
    if (data.services.length == 0) { data.services.push("Pending Deployment"); }
    $.each(data.services, function(index, value){ services += "<li>" + value + "</li>"; });
    services += "</ul>";
    $(selector + ' .deployment_status ul').replaceWith(services);
  }, "json");
  setTimeout("update_deployment_status('" + url + "', '" + selector + "')", 30000);
}

function monitor_deployment(url, selector) {
  jQuery(document).ready(function($) {
    update_deployment_status(url, selector);
  });
}

function update_artifact_status(url, selector) {
  $.post(url, function(data) {
    deployments = "<ul class='deployments'>";
    $.each(data.deployments, function(index, value){ if (value != undeployed) {deployments += "<li>" + value + "</li>"}; });
    deployments += "</ul>";
    $(selector + ' ul.deployments').replaceWith(deployments);
    $(selector + ' .status').text(data.message)
  }, "json");
  setTimeout("update_artifact_status('" + url + "', '" + selector + "')", 30000);
}

function monitor_artifact(url, selector) {
  jQuery(document).ready(function($) {
    update_artifact_status(url, selector);
  });
}

function update_instance_status(url, selector) {
  $.post(url, function(data) {
    $(selector).html(data.html);
  }, "json");
  setTimeout("update_instance_status('" + url + "', '" + selector + "')", 30000);
}

function monitor_instance(url, selector) {
  jQuery(document).ready(function($) {
    update_instance_status(url, selector);
  });
}

function tail_log(url, num_lines, offset, tailing) {
  var params = {num_lines: num_lines, offset: offset};
  $.get(url, params, function(data) {
    logs = $('#log_output');
    if (logs.text().trim() == 'Fetching log...') {
      logs.html('');
    }
    if (data.lines.length > 0) {
      logs.html(logs.html() + "<br />" + data.lines.join("<br />"));
      if (tailing) {
        $("html, body").animate({scrollTop: $(document).height()}, 10);
      }
    }
    if (tailing) {
      setTimeout("tail_log('" + url + "', " + num_lines + ", " + data.offset + ", true)", 5000);
    }
  }, "json");
}
