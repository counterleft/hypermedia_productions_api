require 'rake'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new :spec do |t|
  t.rspec_opts = %w[--color]
  t.verbose = false
end

task :default  => :spec