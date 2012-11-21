class Player
  attr_accessor :player, :thread, :process_pid, :current_file
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

    @current_file = file
    stop # Call stop to avoid any problems
    cmd = "#{self.to_s} #{@current_file.inspect}"

    @thread = Thread.new {
      POpen4.popen4(cmd){ |pout, perr, pin, pid| 
        @process_pid =  pid
      }
    }
  end

  def quit
    @quit = true
  end

  def done?
    @quit
  end

  def next
    stop
  end

  def stop
    # First killed process
    begin
      Process.kill('INT', @process_pid) if @process_pid
    rescue Errno::ESRCH
      # Do nothing, song finished
    end
    # Then kill thread
    @thread.kill if @thread
  end

  def status
    @thread.status
  end
end
