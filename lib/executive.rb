class ExecutionException < StandardError
end

class Executive
    def self.exe( command )
      if DEBUG
        print command,"\n"
      end
      r = ''
      IO.popen( "#{command} 2>&1" ) { |io|
        r = io.readlines
      }

      if $? && $?.exitstatus != 0
          raise ExecutionException, r.unshift( command + "\n" ).to_s
      end

      return r
    end
end
