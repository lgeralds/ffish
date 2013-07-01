module Ffish
  class Ffish
    def self.new_ffish(g_opt, new_names)
      new_names.each do |name|
        FileUtils.mkdir_p "#{g_opt[:ffish_dir]}/#{name}"
        FileUtils.touch "#{g_opt[:ffish_dir]}/#{name}.ffish"
      end
    end

    def self.list_ffish(g_opt)
      Dir.glob("#{g_opt[:ffish_dir]}/*.ffish") do |item|
        puts File.basename(item, '.ffish')
      end
    end

    def self.current_ffish(g_opt, current_ffish=nil)
      if current_ffish
        File.open(g_opt[:state_file], "w+") do |file|
          file.puts YAML::dump(:current_ffish => current_ffish)
        end
      else
        File.open(g_opt[:state_file], "r") do |file|
          puts YAML::load(file)[:current_ffish]
        end
      end
    end
  end  
end