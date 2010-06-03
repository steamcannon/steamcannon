module AppsHelper
  def render_app_link app 
    if app.url && app.status == 'running' 
      link_to(app.url, app.url)
    else
      app.url 
    end
  end
end
