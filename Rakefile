require 'rubygems/package_task'
require 'cucumber'
require 'cucumber/rake/task'

spec = eval(File.read('ffish.gemspec'))

Gem::PackageTask.new(spec) do |pkg|
end

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "features --format pretty -x"
  t.fork = false
end