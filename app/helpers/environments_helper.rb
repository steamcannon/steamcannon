module EnvironmentsHelper

  def platform_version_options(platform_versions)
    platform_versions.collect do |pv|
      [pv.to_s, pv.id]
    end
  end

  def platform_version_images_json
    PlatformVersion.all.inject({}) do |json, platform_version|
      json[platform_version.id] = platform_version.images
      json
    end.to_json
  end

  def environment_images_json(environment_images)
    environment_images.inject({}) do |json, env_image|
      json[env_image.image_id] = env_image
      json
    end.to_json
  end

  def hardware_profile_options
    current_user.cloud.hardware_profiles
  end

end
