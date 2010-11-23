module StorageVolumesHelper
  def volume_status_for_environment_row(volume)
    volume.current_state.titleize
  end
end

