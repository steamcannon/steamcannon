namespace :app do
  namespace :platforms do
    desc "loads platform from yaml specifed in FILE. If the file is just a filename (no /), then it is assumed to be in db/fixtures/platforms/"
    task :load_from_yaml => :environment do
      if ENV['FILE']
        file = ENV['FILE']
        file = File.join(Rails.root, 'db', 'fixtures', 'platforms', file) if File.dirname(file) == '.'
        Platform.load_from_yaml_file(file)
      else
        puts "Please specify a FILE"
      end
      
    end
  end
end
