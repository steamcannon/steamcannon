Factory.sequence :email do |n|
  "email+#{n}@example.com"
end

Factory.define :user do |u|
  u.email { Factory.next(:email)}
  u.password 'sekret1@'
  u.password_confirmation 'sekret1@'
end

Factory.define :superuser, :parent => :user do |u|
  u.superuser true
end

