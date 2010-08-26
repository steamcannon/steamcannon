# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)


unless Platform.find_by_name("JBoss Enterprise 3-Tier")
  Platform.create_from_yaml_file("db/fixtures/platforms/jboss_enterprise_3_tier.yml")
end
