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

function populateEnvironmentImages(versionImages, environmentImages) {
  var versionId = $('#environment_platform_version_id').val();
  $.each(versionImages[versionId], function(index, value) {
    var image = value['image'];
    var template = $('#environment_image_template').clone();
    template.find('.name').text(image['name']);
    template.find('.image_id').val(image['id']);
    template.find('.image_num_instances').val('6');

    var html = template.html();
    // Make sure the field ids and names have the correct index
    html = html.replace(/(_|\[)0(_|\])/g, '$1'+index+'$2');

    if (typeof(environmentImages[image['id']]) != 'undefined') {
      var environmentImage = environmentImages[image['id']]['environment_image'];
      var hardwareProfile = environmentImage['hardware_profile'];
      // for whatever reason changing the values via the template didn't work
      // for the select and text fields
      html = html.replace('value="'+hardwareProfile+'"', 'value="'+hardwareProfile+'" selected="selected"');
      html = html.replace('{{image_num_instances}}', environmentImage['num_instances']);
    } else {
      // For now, always default to one instance
      html = html.replace('{{image_num_instances}}', '1');
    }
    $("#environment_images_container").append(html);
  });
}
