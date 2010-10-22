# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require 'rbconfig'
def ruby_exec(arguments)
  bindir = RbConfig::CONFIG['bindir']
  ruby = RbConfig::CONFIG['ruby_install_name']
  puts "#{File.join(bindir, ruby)} -S #{arguments}"
  puts `#{File.join(bindir, ruby)} -S #{arguments}`
end

# Install latest gems before running Rake tasks on CI server
if ENV['TEAMCITY']
  ruby_exec("bundler install")
end

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'
