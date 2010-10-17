# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

puts "Loading services..."
Service.load_from_yaml_file('db/fixtures/services/jboss_services.yml')

Dir.glob("db/fixtures/platforms/*.yml") do |platform|
  puts "Loading platform from #{platform}..."
  Platform.load_from_yaml_file(platform)
end


