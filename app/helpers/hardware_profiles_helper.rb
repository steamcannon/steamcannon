module HardwareProfilesHelper
  # These are annoying, but necessary since rails routes barf if an ID has a '.' in it
  def pathify(profile_id)
    profile_id.sub('.', '-')
  end

  def deltacloudify(profile_id)
    profile_id.sub('-', '.')
  end

end
