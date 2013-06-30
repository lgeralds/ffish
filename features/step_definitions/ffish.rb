Given(/^the directory "(.*?)" doesn't exist$/) do |directory|
  FileUtils.rm_rf(directory) if File.directory? directory
end

Then(/^the file "(.*?)" should exist$/) do |file|
  File.exist?(file).should eq true
end
