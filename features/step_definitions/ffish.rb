Given(/^the directory "(.*?)" doesn't exist$/) do |directory|
  # puts "PWD 1: #{File.expand_path directory}"
  FileUtils.rm_rf(File.expand_path directory) if File.directory? File.expand_path directory
end

Then(/^the file "(.*?)" should exist$/) do |file|
  # puts "PWD 2: #{File.expand_path file}"
  File.exist?(File.expand_path file).should eq true
end

Then(/^the directory "(.*?)" should exist$/) do |directory|
  # puts "PWD 3: #{File.expand_path directory}"
  File.directory?(File.expand_path directory).should eq true
end
