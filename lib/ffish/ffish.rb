module Ffish
  class Ffish
      @naked_chunk = {
        :context => {},
        :fetch => ['url goes here'],
        :extra => [],

        :configure => ['./configure'],
        :make => ['make'],
        :test => ['make check'],
        :install => ['make install'],
        :clean => ['make clean'],
        :scrub => ['if [ -e "%{chunk_dir}" ]; then rm -rf "%{chunk_dir}"; fi'],
        :'build-macro' => ['fetch', 'extra', 'configure', 'clean', 'make', 'test', 'install']
      }

      @naked_ffish = {
        :context => {},
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

    def self.list_ffish(g_opt, ffish)
      if ffish.class == Array && ffish.count != 0
        chunks = []
        File.open(File.join(g_opt[:ffish_dir], "#{ffish[0]}.ffish"), "r") do |file|
          chunks = YAML::load(file)[:chunks]
        end

        chunks.each do |chunk|
          puts chunk
        end
      else
        Dir.glob(File.join(g_opt[:ffish_dir], "*.ffish")) do |item|
          if ffish.class != String || File.basename(item, '.ffish') =~ /^#{ffish}/
            puts File.basename(item, '.ffish')
          end
        end
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

    def self.ffish_each(g_opt, phase=nil, chunks=nil)
      current_ffish = get_current_ffish(g_opt[:state_file])
      ffish = {}

      if chunks.class != Array || chunks.count == 0
        File.open(File.join(g_opt[:ffish_dir], "#{current_ffish}.ffish"), "r") do |file|
          chunks = YAML::load(file)[:chunks]
        end
      end

      chunks.each do |chunk|
        yield g_opt, current_ffish, chunk, phase
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

    def self.fetch_chunk(g_opt, current_ffish, name, phase)
      # fetch stuff needs to be logged
      puts "FETCH"
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

      if !fetches.count
        puts "NOTHING TO FETCH: #{name}"
        return
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
      ext = File.extname(full_file_name).upcase

      if ext == '.ZIP'
        log g_opt, current_ffish, name, phase, Executive.exe("unzip -o -qq '#{full_file_name}' -d '#{packages_dir}'")
      end

      if ext == '.GZ' || ext == '.TGZ' || ext == '.BZ2'
        log g_opt, current_ffish, name, phase, Executive.exe("tar -xf '#{full_file_name}' -C '#{packages_dir}'")
      end
    end

    def self.do_ffish(g_opt, phase, chunks=nil)
      ffish_each(g_opt, phase, chunks) do |g_opt, current_ffish, chunk, phase|
        File.open(File.join(g_opt[:ffish_dir], current_ffish, "#{chunk}.chunk"), "r") do |file|
          list = YAML::load(file)

          if list.has_key? phase.to_sym
            do_chunk(g_opt, current_ffish, chunk, phase)
          elsif list.has_key? "#{phase}-macro".to_sym
            do_macro(g_opt, current_ffish, chunk, phase)
          end
        end
      end
    end

    def self.do_macro(g_opt, current_ffish, chunk, phase)
      File.open(File.join(g_opt[:ffish_dir], current_ffish, "#{chunk}.chunk"), "r") do |file|
        list = YAML::load(file)["#{phase}-macro".to_sym]
        list.each do |item|
          puts "|#{item}| #{item.class}"
          do_chunk(g_opt, current_ffish, chunk, item)
        end
      end
    end

    def self.do_chunk(g_opt, current_ffish, chunk, phase)
      (self.methods - Object.methods).each do |method|
        if method =~ /^#{phase}_/
          puts "NATIVE: #{phase}"
          self.send("#{phase}_chunk".to_sym ,g_opt, current_ffish, chunk, phase)

          return
        end
      end

      list = []

      File.open(File.join(g_opt[:ffish_dir], current_ffish, "#{chunk}.chunk"), "r") do |file|
        list = YAML::load(file)[phase.to_sym]
      end

      g_opt[:context][:chunk_dir] = File.join(g_opt[:ffarm_dir], current_ffish, g_opt[:packages_dir], chunk)
      g_opt[:context][:lib_dir] = File.join(g_opt[:ffarm_dir], current_ffish, "lib")

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
      if list.class == Array
        list.each do |item|
          # puts "|#{item}|"
          cmd += item.to_str
        end
      else
        cmd += list.to_str
      end

      cmd = cmd % get_context(g_opt, chunk)

      pwd = Dir.pwd
      Dir.chdir g_opt[:context][:chunk_dir] if Dir.exists? g_opt[:context][:chunk_dir]

      log g_opt, current_ffish, chunk, phase, Executive.exe(cmd)
      Dir.chdir pwd
    end

    def self.get_context(g_opt, chunk)
      # order: default, init file, ffish, chunk
      current_ffish = get_current_ffish(g_opt[:state_file])
      g_opt[:context][:prefix] = File.join(g_opt[:ffarm_dir], current_ffish)
      g_opt[:context][:aux_dir] = g_opt[:aux_dir]

      File.open(File.join(g_opt[:ffish_dir], "#{current_ffish}.ffish"), "r") do |file|
        c = YAML::load(file)[:context]

        if c.class == Hash
          g_opt[:context].merge! c
        end
      end

      File.open(File.join(g_opt[:ffish_dir], current_ffish, "#{chunk}.chunk"), "r") do |file|
        c = YAML::load(file)[:context]

        if c.class == Hash
          g_opt[:context].merge! c
        end
      end

      g_opt[:context]
    end

# localize the exe call to capture the exception and doing general logging

    def self.log(g_opt, current_ffish, chunk, phase, text)
      logs_dir = File.join(g_opt[:ffarm_dir], current_ffish, g_opt[:logs_dir])

      if !File.directory?(logs_dir)
        FileUtils.mkdir_p logs_dir
      end

      File.open(File.join(logs_dir, "#{Time.now}-#{chunk}-#{phase}.log"), "w+") do |file|
        text.each do |line|
          file.write line
        end
      end
    end

  end # class
end # module