namespace :ci do
  desc 'Run RSpecs and generate RCov report'
  task :specs => ['gems:install', 'db:test:load', 'spec:rcov'] do
  end
end
