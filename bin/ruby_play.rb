require "rubygems"
require "bundler/setup"

$:.unshift File.join(File.dirname(__FILE__),'..')
require 'ruby_play'

require 'optparse'

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
