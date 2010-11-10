class ActiveRecord::Base

  named_scope :sorted_by, lambda { |sort_column, sort_direction|
    { :order => "#{sort_column} #{sort_direction}" }
  }

end
