require 'aruba/cucumber'

require 'fileutils'

ENV['PATH'] = "#{File.expand_path(File.dirname(__FILE__) + '/../../bin')}#{File::PATH_SEPARATOR}#{ENV['PATH']}"
ENV['GLI_DEBUG'] = 'true'
LIB_DIR = File.join(File.expand_path(File.dirname(__FILE__)),'..','..','lib')

Before do
  @real_home = ENV['HOME']
  fake_home = File.join('/tmp','fake_home')
  FileUtils.rm_rf fake_home, :secure => true
  ENV['HOME'] = fake_home

  @original_rubylib = ENV['RUBYLIB']
  ENV['RUBYLIB'] = LIB_DIR + File::PATH_SEPARATOR + ENV['RUBYLIB'].to_s
end

After do
  ENV['HOME'] = @real_home
  config_file = File.join('/tmp','.todo.rc.yaml')
  FileUtils.rm config_file if File.exists? config_file
  ENV['RUBYLIB'] = @original_rubylib
end
