require "rubygems"
require "bundler/setup"

require 'optparse'
require 'popen4'

# Option parser
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: ruby_play.rb [options]"

  opts.on("-s", "--shuffle", "Shuffle") do |v|
    options[:shuffle] = true
  end

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end
end.parse!

module Music
  module Errors
    class DirectoryDoesNotExist < StandardError; end
  end

  class Files
    attr_accessor :files
    def initialize(directory, options)

      @options = options
      if !File.exists?(directory)
        raise Music::Errors::DirectoryDoesNotExist.new("Directory: #{directory} does not exist")
      end

      @files = Dir.glob("#{directory}/**/*").reject{|f| 
        !(f =~ /.mp3$/)
      }
      if @options[:shuffle]
        @files.shuffle!
      end
    end

    def each
      @files.each do |file|
        yield file
      end
    end
  end

end

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


player = Player.new
music_files = Music::Files.new(ARGV.shift, options)

# Trap Signals
trap("INT") do
  player.stop
end


music_files.each do |file|
  $stdout.puts "Playing: #{file}" if options[:verbose]
  player.play(file)

  while(status = player.status)
    puts status
    sleep 1
  end

  player.thread.join
end
