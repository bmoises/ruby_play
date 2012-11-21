class Player
  attr_accessor :player, :thread, :process_pid
  def initialize
    case RUBY_PLATFORM.downcase
    when /darwin/
      @player = "afplay -d"
    when /mswin/
    when /linux/
    else
      raise ":( no platform/os support at this time"
    end
  end

  def to_s
    "#{@player}"
  end

  def play(file)
    stop # Call stop to avoid any problems
    cmd = "#{self.to_s}  #{file.inspect}"

    @thread = Thread.new {
      POpen4.popen4(cmd){ |pout, perr, pin, pid| 
        @process_pid =  pid
      }
    }
  end

  def stop
    # First killed process
    Process.kill('INT', @process_pid) if @process_pid
    # Then kill thread
    @thread.kill if @thread
  end

  def status
    @thread.status
  end
end
