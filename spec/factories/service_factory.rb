Factory.sequence(:service_name) { |n| "service_#{n}" }

Factory.define(:service) do |service|
  service.name { Factory.next(:service_name)}
  service.full_name 'full name'
end
