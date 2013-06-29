require File.join([File.dirname(__FILE__),'lib','ffish_version.rb'])
spec = Gem::Specification.new do |s| 
  s.name = 'ffish'
  s.version = Ffish::VERSION

  s.author = 'lgeralds'
  s.email = 'lgeralds+ffish@gmail.com'
  s.homepage = 'http://lgeralds.com'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Large scale application building tool.'
  #START:lib
  s.files = %w(
bin/ffish
lib/ffish_version.rb
  )
  #START_HIGHLIGHT
  s.require_paths << 'lib'
  #END_HIGHLIGHT
  #END:lib
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc','ffish.rdoc']
  s.rdoc_options << '--title' << 'ffish' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'ffish'
  s.add_development_dependency('aruba', '~> 0.4.6')
  s.add_dependency('gli')
end
