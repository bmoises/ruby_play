module Remote
  class Client

    def initialize(address=nil,port=nil)
      @address = address || MULTICAST_ADDR
      @port    = port || PORT
    end

    def send(args=[])
      begin
        socket = UDPSocket.open
        socket.setsockopt(Socket::IPPROTO_IP, Socket::IP_TTL, [1].pack('i'))
        socket.send(args.join(' '), 0, @address, @port)
      ensure
        socket.close 
      end
    end
  end
end
