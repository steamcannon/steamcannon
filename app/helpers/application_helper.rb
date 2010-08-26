# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def class_for status
    if %w{ running terminated staged }.include? status
      status
    else
      'changing'
    end
  end

  def dom_class_for_body
    %(#{params[:controller]}_controller #{params[:action]}_action #{current_user and current_user.superuser? ? 'superuser' : 'account_user'})
  end
end
