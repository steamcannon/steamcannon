class AppController < ApplicationController

  def upload
    input = params[:archive]
    if input
      File.open(Rails.root.join('public', 'uploads', input.original_filename), 'w') do |file| 
        file.write(input.read)
      end 
    else
      flash[:error] = 'Application archive required'
    end
    respond_to do |format|
      format.html { redirect_to(instances_url) }
      format.xml  { head :ok }
    end
  end

end
