module CloudProfilesHelper
  
  def cloud_profile_options
    options_from_collection_for_select(current_user.cloud_profiles, :id, :name_with_details)
  end

  def cloud_profiles_available_to_environment(environment)
    if environment.new_record?
      current_user.cloud_profiles
    else
      [environment.cloud_profile]
    end
  end
end
