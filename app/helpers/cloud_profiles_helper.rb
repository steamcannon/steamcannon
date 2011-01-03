module CloudProfilesHelper
  
  def cloud_profile_options
    
    options_for_select('Select...' => nil) + options_from_collection_for_select(current_user.cloud_profiles, :id, :name_with_details)
  end

  def cloud_profiles_available_to_environment(environment)
    if environment.new_record?
      current_user.cloud_profiles
    else
      [environment.cloud_profile]
    end
  end

  def cloud_ssh_key_select_options(cloud_profile, environment)
    options = [nil]
    options += cloud_profile.cloud.attempt(:keys, []).collect(&:id) if cloud_profile
    options_for_select(options, environment.try(:ssh_key_name))
  end
  
  def cloud_realm_select_options(cloud_profile, environment)
    options = []
    options += cloud_profile.cloud.attempt(:realms, []).collect(&:id) if cloud_profile
    options_for_select(options, environment.try(:realm))
  end

  def available_clouds
    Cloud::Specifics::Base.available_clouds
  end
  
  def available_cloud_names
    options_for_select(available_clouds.values.collect { |c| [c[:display_name], c[:name]]}.sort_by(&:first))
  end

  def cloud_providers(cloud, selected)
    options_for_select(cloud[:providers], selected)
  end
end
