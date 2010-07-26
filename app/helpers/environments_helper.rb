module EnvironmentsHelper

  def platform_version_options(platform_versions)
    platform_versions.collect do |pv|
      [pv.to_s, pv.id]
    end
  end
end
