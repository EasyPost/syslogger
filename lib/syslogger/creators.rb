require 'socket'


module SysLogger
  module Creators
    def self.unix_dgram_socket(socket_path)
      proc {
        client = Socket.new(Socket::Constants::AF_LOCAL, Socket::Constants::SOCK_DGRAM, 0)
        client.connect(Socket.pack_sockaddr_un(socket_path))
        client
      }
    end

    def self.unix_stream_socket(socket_path)
      proc {
        UNIXSocket.new(socket_path)
      }
    end
  end
end
