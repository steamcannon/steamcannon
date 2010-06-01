class AppController < ApplicationController

  def upload
    input = params[:archive]
    backend = Instance.backend
    if Instance.backend.nil?
      flash[:error] = 'At least one backend instance must be running'
    elsif input.nil?
      flash[:error] = 'Application archive required'
    else
      path = Rails.root.join('public', 'uploads', input.original_filename)
      File.open(path, 'w') do |file| 
        file.write(input.read)
      end
      backend.deploy path
    end
    respond_to do |format|
      format.html { redirect_to(instances_url) }
      format.xml  { head :ok }
    end
  end

end
