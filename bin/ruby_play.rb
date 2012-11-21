require "rubygems"
require "bundler/setup"

$:.unshift File.join(File.dirname(__FILE__),'..')
require 'ruby_play'

require 'optparse'

# Option parser
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: ruby_play.rb directory [options]"

  opts.on("-s", "--shuffle", "Shuffle") do |v|
    options[:shuffle] = true
  end

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end
end.parse!

player = Player.new
music_files = Music::Files.new(ARGV.shift, options)

# listen to remote
remote = RemoteServer.new(player)

# Trap Signals
trap("INT") do
  player.quit
end

music_files.each do |file|
  if player.done?
    $stdout.puts "Finished"
    break
  end
  $stdout.puts "Playing: #{file}" if options[:verbose]
  player.play(file)

  while(status = player.status)
    #puts status
    sleep 0.5
  end

  player.thread.join
end
