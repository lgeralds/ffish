module Ffish
  class Ffish
    def self.new_ffish(new_names)
      new_names.each do |name|
        FileUtils.mkdir_p "/tmp/ffish/#{name}"
        FileUtils.touch "/tmp/ffish/#{name}.ffish"
      end
    end

    def self.list_ffish
      Dir.glob('/tmp/ffish/*.ffish') do |item|
        puts File.basename(item, '.ffish')
      end
    end
  end  
end