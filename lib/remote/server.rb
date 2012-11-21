module Remote
  class Server

    attr_accessor :remote

    def initialize(address=nil,port=nil)
      @address = address || MULTICAST_ADDR
      @port    = port || PORT

      @remote = Thread.new {
        ip =  IPAddr.new(@address).hton + IPAddr.new("0.0.0.0").hton
        sock = UDPSocket.new
        sock.setsockopt(Socket::IPPROTO_IP, Socket::IP_ADD_MEMBERSHIP, ip)
        sock.bind(Socket::INADDR_ANY, @port)
        loop do
          msg, info = sock.recvfrom(1024)
          # Handle messages
          yield msg, info
        end
      }
    end
  end
end
