Factory.define :environment do |env|
  env.name 'Environment'
  env.association :user
  env.association :platform_version
end
