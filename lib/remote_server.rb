require 'socket'
require 'ipaddr'

class RemoteServer

  MULTICAST_ADDR = "225.4.5.6" 
  PORT = 5000

  attr_accessor :remote

  def initialize(player)
    @remote = Thread.new(player) {
      ip =  IPAddr.new(MULTICAST_ADDR).hton + IPAddr.new("0.0.0.0").hton
      sock = UDPSocket.new
      sock.setsockopt(Socket::IPPROTO_IP, Socket::IP_ADD_MEMBERSHIP, ip)
      sock.bind(Socket::INADDR_ANY, PORT)
      loop do
        msg, info = sock.recvfrom(1024)
        # Handle messages
        case msg
        when "next"
          player.next
        when "quit"
          player.quit
          player.stop
        else
          puts "MSG: #{msg} from #{info[2]} (#{info[3]})/#{info[1]} len #{msg.size}"
        end
      end
    }
  end

end
