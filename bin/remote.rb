require "rubygems"
require "bundler/setup"

$:.unshift File.join(File.dirname(__FILE__),'..')
require 'ruby_play'
require 'optparse'

# Option parser
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: remote.rb command[next|quit]"

end.parse!

client = Remote::Client.new
client.send ARGV
