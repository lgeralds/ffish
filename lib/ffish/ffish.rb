module Ffish
  class Ffish
      @naked_chunk = {
        :fetch => [],
        :extra => [],
        :config => [],
        :make => [],
        :install => []
      }

      @naked_ffish = {
        :context => [],
        :chunks => []
      }


    def self.new_ffish(g_opt, new_names)
      new_names.each do |name|
        FileUtils.mkdir_p File.join(g_opt[:ffish_dir], name)

        File.open(File.join(g_opt[:ffish_dir], "#{name}.ffish"), "w+") do |file|
          file.puts YAML::dump(@naked_ffish)
        end

        set_current_ffish(g_opt[:state_file], name)
        add_chunk(g_opt, [name])
      end
    end

    def self.list_ffish(g_opt)
      Dir.glob(File.join(g_opt[:ffish_dir], "*.ffish")) do |item|
        puts File.basename(item, '.ffish')
      end
    end

    def self.current_ffish(g_opt, current_ffish=nil)
      if current_ffish
        set_current_ffish(g_opt[:state_file], current_ffish)
      else
        puts get_current_ffish(g_opt[:state_file])
      end
    end

    def self.add_chunk(g_opt, new_names)
      current_ffish = get_current_ffish(g_opt[:state_file])

      new_names.each do |name|
        new_chunk(File.join(g_opt[:ffish_dir], "#{current_ffish}/#{name}.chunk"), name)

        ffish = {}

        File.open(File.join(g_opt[:ffish_dir], "#{current_ffish}.ffish"), "r") do |file|
          ffish = YAML::load(file)
        end

        ffish[:chunks] << name

        File.open(File.join(g_opt[:ffish_dir], "#{current_ffish}.ffish"), "w") do |file|
          file.puts YAML::dump(ffish)
        end
      end
    end

    def self.ffish_each(g_opt)
      current_ffish = get_current_ffish(g_opt[:state_file])
      ffish = {}

      File.open(File.join(g_opt[:ffish_dir], "#{current_ffish}.ffish"), "r") do |file|
        ffish = YAML::load(file)
      end

      ffish[:chunks].each do |chunk|
        yield g_opt, current_ffish, chunk
      end
    end

    def self.fetch_ffish(g_opt)
      ffish_each(g_opt) do |g_opt, current_ffish, chunk|
        fetch_chunk(g_opt, current_ffish, chunk)
      end
    end

    def self.get_current_ffish(state_file)
      File.open(state_file, "r") do |file|
        YAML::load(file)[:current_ffish]
      end
    end

    def self.set_current_ffish(state_file, ffish)
      File.open(state_file, "w+") do |file|
        file.puts YAML::dump(:current_ffish => ffish)
      end
    end

    def self.new_chunk(chunk_file, name)
      File.open(chunk_file, "w+") do |file|
        file.puts YAML::dump(@naked_chunk)
      end
    end

    def self.fetch_chunk(g_opt, current_ffish, name)
      require 'open-uri'

      fetches = []
      full_file_name = ''
      packages_dir = File.join(g_opt[:ffarm_dir], current_ffish, g_opt[:packages_dir])

      File.open(File.join(g_opt[:ffish_dir], current_ffish, "#{name}.chunk"), "r") do |file|
        fetches = YAML::load(file)[:fetch]
      end

      if fetches.count && !File.directory?(packages_dir)
        FileUtils.mkdir_p packages_dir
      end

      puts "FETCHING FOR: #{name}"
      fetches.each do |fetch|
        file_name = File.basename(fetch)
        puts "\t#{file_name}"
        full_file_name = File.join g_opt[:ffiles_dir], file_name

        unless File.exists? full_file_name
          puts "\t#{fetch}"
          begin
            open(full_file_name, 'wb') do |file|
              file << open(fetch).read
            end
          rescue Exception => ex
            puts "\tFAILED: #{ex.message}"
            FileUtils.rm full_file_name
          else
            puts "\tSUCCESS"
            break
          end
        else
          puts "\tWE ALREADY GOT IT"
          break
        end
      end

      # unpack it
      ext = File.extname full_file_name
      puts "EXT: #{ext}"

      if ext.upcase == '.ZIP'
        Executive.exe "unzip -o -qq '#{full_file_name}' -d '#{packages_dir}'"

        # require 'zip/zip'

        # Zip::ZipFile.open(full_file_name) do |zip_file|
        #   zip_file.each do |f|
        #     f_path = File.join(g_opt[:ffarm_dir], current_ffish, g_opt[:packages_dir], f.name)
        #     FileUtils.mkdir_p File.dirname(f_path)
        #     unless File.exist?(f_path)
        #       zip_file.extract(f, f_path)
        #     end
        #   end
        # end
      end

      if ext.upcase == '.GZ' || ext.upcase == '.TGZ'
        # Executive.exe 'tar -xzf ' + full_file_name + ' --strip 1 -C ' + packages_dir
        Executive.exe "tar -xf '#{full_file_name}' -C '#{packages_dir}'"

        # require 'zlib'
        # require 'tmpdir'
        # require 'archive/tar/minitar'
        # include Archive::Tar

        # tmp_dir = Dir.tmpdir
        # tmp_file = File.join(tmp_dir, File.basename(full_file_name, '.*'))
        # puts "TMP: #{tmp_file}"

        # begin
        #   Zlib::GzipReader.open(full_file_name) do |gz|
        #     File.open(tmp_file, "w") do |file|
        #       file.write gz.read
        #     end
        #   end
        #   #untar
        #   Minitar.unpack(tmp_file, File.join(g_opt[:ffarm_dir], current_ffish, g_opt[:packages_dir]))
        # ensure
        #   FileUtils.remove_entry tmp_file
        # end
      end

      if ext.upcase == '.BZ2'
        puts "BZIP2 broken in Ruby 2.0"
        exit 1
        # require 'bzip2'
        # require 'tmpdir'
        # require 'archive/tar/minitar'
        # include Archive::Tar

        # tmp_dir = Dir.tmpdir
        # tmp_file = File.join(tmp_dir, File.basename(full_file_name, '.*'))
        # puts "TMP: #{tmp_file}"

        # begin
        #   Bzip2::Reader.open(full_file_name) do |bz2| 
        #     File.open(tmp_file, "w") do |file|
        #       file.write bz2.read
        #     end
        #   end
        #   #untar
        #   Minitar.unpack(tmp_file, File.join(g_opt[:ffarm_dir], current_ffish, g_opt[:packages_dir]))
        # ensure
        #   FileUtils.remove_entry tmp_file
        # end
      end
    end

    def self.configure_ffish(g_opt)
      ffish_each(g_opt) do |g_opt, current_ffish, chunk|
        config_chunk(g_opt, current_ffish, chunk)
      end
    end

    def self.config_chunk(g_opt, current_ffish, chunk)
      config = []

      File.open(File.join(g_opt[:ffish_dir], current_ffish, "#{chunk}.chunk"), "r") do |file|
        config = YAML::load(file)[:config]
      end

      # if isinstance(value, list):
      #   tp = ''
      #   for v in value:
      #     tp += str(v)
      #   p = tp.strip()
      #   if quoted:
      #       p = '"' + p + '"'
      # else:
      #   p += str(value)

      cmd = ''
      if config.class == Array
        config.each do |item|
          cmd += item.to_str
        end
      else
        cmd += config.to_str
      end

      cmd = cmd % get_context(g_opt)
      puts "CMD: |#{cmd}|"

      pwd = Dir.pwd
      Dir.chdir File.join(g_opt[:ffarm_dir], current_ffish, g_opt[:packages_dir], chunk)
      puts Executive.exe cmd
      Dir.chdir pwd

    end

    def self.get_context(g_opt)
      g_opt[:context][:prefix] = File.join(g_opt[:ffarm_dir], get_current_ffish(g_opt[:state_file]))

      g_opt[:context]
    end
  end # class
end # module