require 'socket'


module SysLogger
  module Creators
    def self.unix_dgram_socket(socket_path)
      Proc.new {
        client = Socket.new(Socket::Constants::AF_LOCAL, Socket::Constants::SOCK_DGRAM, 0)
        client.connect(Socket.pack_sockaddr_un(socket_path))
        client
      }
    end

    def self.unix_stream_socket(socket_path)
      Proc.new {
        UnixSocket.new(socket_path)
      }
    end
  end
end
