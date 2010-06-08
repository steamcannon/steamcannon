# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def class_for status
    if %w{ running terminated staged }.include? status
      status
    else
      'changing'
    end
  end

end
