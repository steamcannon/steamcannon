module ServicesHelper
  def options_for_service_select(selected = nil)
    options_from_collection_for_select(Service.all, :id, :full_name, selected)
  end
end
