class ActiveRecord::Base
  
  def clone!(attributes_to_override = { })
    clone.tap { |copy| copy.update_attributes!(attributes_to_override) }
  end

end
